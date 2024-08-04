import 'dotenv/config'
import express from 'express'
import * as amqp from 'amqplib'
import { Pool } from 'pg'

class PostgresRespository {
  private static instance: PostgresRespository
  public pool: Pool

  private constructor() {
    this.pool = new Pool({
      connectionString: process.env.DATABASE_URL
    })
  }

  public static getInstance(): PostgresRespository {
    if (!PostgresRespository.instance) {
      PostgresRespository.instance = new PostgresRespository()
    }
    return PostgresRespository.instance
  }
}

const pg = PostgresRespository.getInstance().pool

type TLocation = {
  latitude: number
  longitude: number
  velocidade: number
  horario_rastreador: string
  bateria: number
  bateria_veiculo: number
  ignicao: boolean
  altitude: number
  direcao: number
  odometro: number
}

const app = express()
const PORT = 4242

app.use(express.json())
app.use(express.urlencoded({ extended: true }))

export let channel: amqp.Channel

const setup = async () => {
  channel = await rabbitmq({ queueName: 'location_queue' })
  locationWorker(channel)
}

app.post('/location', async (req, res) => {
  try {
    const message = req.body

    const registerQueue = channel.sendToQueue(
      'location_queue',
      Buffer.from(JSON.stringify(message)),
      {
        persistent: false
      }
    )

    res.status(201).json({
      registerQueue
    })
  } catch (error) {
    console.error('Erro ao enviar mensagem para o RabbitMQ:', error)
    res.status(500).json({ error: 'Erro ao enviar dados para a fila' })
  }
})

const processBatch = async (messages: TLocation[]) => {
  const values = messages.map((msg) => [
    msg.latitude,
    msg.longitude,
    msg.velocidade,
    msg.horario_rastreador,
    msg.bateria,
    msg.bateria_veiculo,
    msg.ignicao,
    msg.altitude,
    msg.direcao,
    msg.odometro
  ])

  const query =
    'INSERT INTO localizacao (latitude, longitude, velocidade, horario_rastreador, bateria, bateria_veiculo, ignicao, altitude, direcao, odometro) VALUES ' +
    values
      .map(
        (_, i) =>
          `($${i * 10 + 1}, $${i * 10 + 2}, $${i * 10 + 3}, $${i * 10 + 4}, $${i * 10 + 5}, $${i * 10 + 6}, $${i * 10 + 7}, $${i * 10 + 8}, $${i * 10 + 9}, $${i * 10 + 10})`
      )
      .join(', ')

  const flattenedValues = values.flat()

  try {
    await pg.query(query, flattenedValues)
  } catch (error) {
    console.error('Error inserting batch into the database:', error)
  }
}


const locationWorker = async (channel: amqp.Channel) => {
  const QUEUE_NAME = 'location_queue'
  const BATCH_SIZE = 100
  let messagesBuffer: TLocation[] = []
  let messageObjects: amqp.Message[] = []
  let isProcessing = false;


  channel.consume(
    QUEUE_NAME,
    async (msg) => {
      if (msg !== null) {

        const message = JSON.parse(msg.content.toString())
        messagesBuffer.push(message)
        messageObjects.push(msg)


        if (messagesBuffer.length >= BATCH_SIZE && !isProcessing) {
          isProcessing = true;
          await processMessages()

        }
      }
    },
    {
      noAck: false
    }
  )

  const processMessages = async () => {
    if (messagesBuffer.length > 0) {
      try {

        await processBatch(messagesBuffer)
        messageObjects.forEach((msgObj) => {
          channel.ack(msgObj)
        })

      } catch (error) {

        messageObjects.forEach((msgObj) => {
          channel.nack(msgObj)

        })
      } finally {
        messagesBuffer = []
        messageObjects = []
        isProcessing = false;
      }
    }
  }

  process.on('SIGTERM', async () => {
    console.log('SIGTERM signal received: closing RabbitMQ connection')
    await processMessages()
    process.exit(0)
  })

  process.on('SIGINT', async () => {
    console.log('SIGINT signal received: closing RabbitMQ connection')
    await processMessages()
    process.exit(0)
  })
}

async function rabbitmq({ queueName }: { queueName: string }) {
  try {
    const connection = await amqp.connect(process.env.RABBITMQ_URL)
    const channel = await connection.createChannel()
    await channel.assertQueue(queueName, { durable: true })
    return channel
  } catch (error) {
    console.error('Failed to setup RabbitMQ:', error)
    process.exit(1)
  }
}

app.listen(PORT, async () => {
  await setup()
  console.log(`Server is running on port ${PORT}`)
})
