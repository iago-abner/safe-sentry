import 'dotenv/config'
import express from 'express'
import * as amqp from 'amqplib'
import { rabbitmq } from './repositories/rabbitmq'
import { locationWorker } from './location-worker'
import { router } from './routes'

const app = express()
const PORT = 4242

app.use(express.json())
app.use(express.urlencoded({ extended: true }))

app.use(router)

export let channel: amqp.Channel

const setup = async () => {
  channel = await rabbitmq({ queueName: 'location_queue' })
  locationWorker(channel)
}

app.listen(PORT, async () => {
  console.log(`Server is running on port ${PORT}`)
  await setup()
})
