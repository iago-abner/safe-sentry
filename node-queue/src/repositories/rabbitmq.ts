import * as amqp from 'amqplib';

class RabbitmqRepository {
  private static instance: RabbitmqRepository;
  private channel: amqp.Channel | null = null;

  private constructor() {}

  public static async getInstance(queueName: string): Promise<amqp.Channel> {
    if (!RabbitmqRepository.instance) {
      RabbitmqRepository.instance = new RabbitmqRepository();
    }
    return RabbitmqRepository.instance.getChannel(queueName);
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
