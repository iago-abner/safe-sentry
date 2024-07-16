import { Router } from 'express'
import pg from '../repositories/pg'

export const location = Router()

const batchSize = 100
let recordsBuffer = []

location.post('/', async (req, res) => {
  try {
    const {
      latitude,
      longitude,
      velocidade,
      horario_rastreador,
      bateria,
      bateria_veiculo,
      ignicao,
      altitude,
      direcao,
      odometro
    } = req.body

    recordsBuffer.push([
      latitude,
      longitude,
      velocidade,
      horario_rastreador,
      bateria,
      bateria_veiculo,
      ignicao,
      altitude,
      direcao,
      odometro
    ])

    if (recordsBuffer.length >= batchSize) {
      const query =
        'INSERT INTO localizacao (latitude, longitude, velocidade, horario_rastreador, bateria, bateria_veiculo, ignicao, altitude, direcao, odometro) VALUES ' +
        recordsBuffer
          .map(
            (_, i) =>
              `($${i * 10 + 1}, $${i * 10 + 2}, $${i * 10 + 3}, $${i * 10 + 4}, $${i * 10 + 5}, $${i * 10 + 6}, $${i * 10 + 7}, $${i * 10 + 8}, $${i * 10 + 9}, $${i * 10 + 10})`
          )
          .join(', ')

      const flattenedValues = recordsBuffer.flat()

      await pg.query(query, flattenedValues)

      recordsBuffer = []

      res.status(201).json({
        message: 'batch'
      })
    } else {
      res.status(201).json({ message: 'Dados recebidos' })
    }

  } catch (error) {
    console.error('Erro ao enviar dados para o banco:', error)
    res.status(500).json({ error: 'Erro ao processar os dados' })
  }
})
