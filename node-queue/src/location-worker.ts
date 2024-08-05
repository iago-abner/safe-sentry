import { Pool } from 'pg'
import * as amqp from 'amqplib';
import { TLocation } from './types/location';

export const locationWorker = async (channel: amqp.Channel, pg: Pool) => {
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


