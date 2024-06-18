import * as amqp from 'amqplib'

export async function rabbitmq({ queueName }: { queueName: string }) {
  const RABBITMQ_USER = 'admin'
  const RABBITMQ_PASS = 'admin'
  const RABBITMQ_HOST = 'localhost'
  const RABBITMQ_PORT = 5672

  const RABBITMQ_URL = `amqp://${RABBITMQ_USER}:${RABBITMQ_PASS}@${RABBITMQ_HOST}:${RABBITMQ_PORT}`

  try {
    const connection = await amqp.connect(RABBITMQ_URL)
    const channel = await connection.createChannel()
    await channel.assertQueue(queueName, { durable: true })
    return channel
  } catch (error) {
    console.error('Failed to setup RabbitMQ:', error)
    process.exit(1)
  }
}
