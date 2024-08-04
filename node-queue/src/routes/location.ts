import { Router } from 'express'
import { channel } from '../main'

export const location = Router()

location.post('/', async (req, res) => {
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
