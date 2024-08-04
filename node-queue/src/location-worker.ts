import * as amqp from 'amqplib';
import pg from './repositories/pg';
import { TLocation } from './types/location';

const processBatch = async (messages: TLocation[]) => {
  console.log('Processing batch of messages:', messages.length);
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
    msg.odometro,
  ]);

  const query =
    'INSERT INTO localizacao (latitude, longitude, velocidade, horario_rastreador, bateria, bateria_veiculo, ignicao, altitude, direcao, odometro) VALUES ' +
    values
      .map(
        (_, i) =>
          `($${i * 10 + 1}, $${i * 10 + 2}, $${i * 10 + 3}, $${i * 10 + 4}, $${i * 10 + 5}, $${i * 10 + 6}, $${i * 10 + 7}, $${i * 10 + 8}, $${i * 10 + 9}, $${i * 10 + 10})`
      )
      .join(', ');

  const flattenedValues = values.flat();

  console.log('Executing query:', query);
  console.log('With values:', flattenedValues);

  try {
    await pg.query(query, flattenedValues);
    console.log('Batch processed successfully');
  } catch (error) {
    console.error('Error inserting batch into the database:', error);
    throw error;
  }
};

export const locationWorker = async (channel: amqp.Channel) => {
  const QUEUE_NAME = 'location_queue';
  const BATCH_SIZE = 100;
  let messagesBuffer: TLocation[] = [];
  let messageObjects: amqp.Message[] = [];

  console.log('Starting location worker, listening to queue:', QUEUE_NAME);

  channel.consume(
    QUEUE_NAME,
    async (msg) => {
      if (msg !== null) {

        const message = JSON.parse(msg.content.toString());
        messagesBuffer.push(message);
        messageObjects.push(msg);

        console.log('Buffer size:', messagesBuffer.length);

        if (messagesBuffer.length >= BATCH_SIZE) {
          console.log('Buffer reached batch size. Processing batch.');
          try {
            await processBatch(messagesBuffer);
            messageObjects.forEach((msgObj) => channel.ack(msgObj));
            console.log('Batch acknowledged.');
          } catch (error) {
            console.error('Error processing batch:', error);
            messageObjects.forEach((msgObj) => channel.nack(msgObj));
          } finally {
            messagesBuffer = [];
            messageObjects = [];
          }
        }
      }
    },
    {
      noAck: false,
    }
  );
};
