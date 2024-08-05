import 'dotenv/config'
import express from 'express'
import { Pool } from 'pg'
import * as amqp from 'amqplib';
import RabbitmqRepository from './repositories/rabbitmq'
import PostgresRespository from './repositories/pg'

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

const setup = async () => {
  const pg = PostgresRespository.getInstance().pool
  const channel = await RabbitmqRepository.getInstance('location_queue');
  locationWorker(channel, pg)
}

const processBatch = async (messages: TLocation[], pg: Pool) => {
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

const locationWorker = async (channel: amqp.Channel, pg: Pool) => {
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

        await processBatch(messagesBuffer, pg)
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

app.listen(PORT, async () => {
  await setup()
  console.log(`Server is running on port ${PORT}`)
})
