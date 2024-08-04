import * as amqp from 'amqplib'

export async function rabbitmq({ queueName }: { queueName: string }) {
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
