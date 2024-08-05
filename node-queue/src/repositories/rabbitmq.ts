import amqp from 'amqplib';

class RabbitmqRepository {
  private static instance: RabbitMQ;
  private channel: amqp.Channel | null = null;

  private constructor() {}

  public static async getInstance(queueName: string): Promise<amqp.Channel> {
    if (!RabbitMQ.instance) {
      RabbitMQ.instance = new RabbitMQ();
    }
    return RabbitMQ.instance.getChannel(queueName);
  }

  private async getChannel(queueName: string): Promise<amqp.Channel> {
    if (!this.channel) {
      try {
        const connection = await amqp.connect(process.env.RABBITMQ_URL);
        this.channel = await connection.createChannel();
        await this.channel.assertQueue(queueName, { durable: true });
      } catch (error) {
        console.error('Failed to setup RabbitMQ:', error);
        process.exit(1);
      }
    }
    return this.channel;
  }
}

export default RabbitmqRepository;
