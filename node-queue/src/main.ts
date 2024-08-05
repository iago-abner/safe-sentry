import 'dotenv/config'
import express from 'express'
import { locationWorker } from './location-worker';
import RabbitmqRepository from './repositories/rabbitmq'
import PostgresRespository from './repositories/pg'

const app = express()
const PORT = 4242

app.use(express.json())
app.use(express.urlencoded({ extended: true }))

const setup = async () => {
  const pg = PostgresRespository.getInstance().pool
  const channel = await RabbitmqRepository.getInstance('location_queue');
  locationWorker(channel, pg)
}

app.listen(PORT, async () => {
  await setup()
  console.log(`Server is running on port ${PORT}`)
})
