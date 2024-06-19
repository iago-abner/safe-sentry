import 'dotenv/config'
import express from 'express'
import * as amqp from 'amqplib'
import { rabbitmq } from './repositories/rabbitmq'
import { locationWorker } from './location-worker'

const app = express()

const PORT = 4242
app.use(express.json())

let channel: amqp.Channel

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
        persistent: true
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

app.get('/', (_, res) => {
  res.send('Hello World!')
})

app.listen(PORT, async () => {
  console.log(`Server is running on port ${PORT}`)
  await setup()
})
