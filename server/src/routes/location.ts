import { Router } from 'express'
import pg from '../repositories/pg'
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

location.get('/:vehicleId', async (req, res) => {
  const { vehicleId } = req.params
  const { startDate, endDate } = req.query

  try {
    const result = await pg.query(
      `SELECT l.*
       FROM Localizacao l
       JOIN Rastreador r ON l.rastreador_id = r.id
       WHERE r.veiculo_id = $1
         AND l.horario_rastreador >= $2
         AND l.horario_rastreador <= $3`,
      [vehicleId, startDate, endDate]
    )

    if (result.rows.length === 0) {
      res.status(404).json({
        message: 'Nenhuma localização encontrada para este intervalo de tempo'
      })
    }

    res.status(200).json(result.rows)
  } catch (error) {
    res.status(500).json({ message: 'Erro ao buscar localizações', error })
  }
})

location.get('/trajeto/:userId', async (req, res) => {
  const { userId } = req.params

  try {
    const result = await pg.query(
      `SELECT l.*
       FROM Localizacao l
       JOIN Rastreador r ON l.rastreador_id = r.id
       JOIN Veiculo v ON r.veiculo_id = v.id
       WHERE v.usuario_id = $1`,
      [userId]
    )

    if (result.rows.length === 0) {
      res.status(404).json({
        message: 'Nenhuma localização encontrada para os veículos deste usuário'
      })
    }

    res.status(200).json(result.rows)
  } catch (error) {
    res.status(500).json({ message: 'Erro ao buscar localizações', error })
  }
})

location.get('/trajeto/:vehicleId', async (req, res) => {
  const { vehicleId } = req.params

  try {
    const result = await pg.query(
      'SELECT * FROM Trajeto WHERE veiculo_id = $1',
      [vehicleId]
    )

    if (result.rows.length === 0) {
      res
        .status(404)
        .json({ message: 'Nenhum trajeto encontrado para este veículo' })
    }

    res.status(200).json(result.rows)
  } catch (error) {
    res.status(500).json({ message: 'Erro ao buscar trajetos', error })
  }
})
