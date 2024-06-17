import express from 'express'
import { Queue } from 'bullmq'
import Redis from 'ioredis'
import db from './pg-connection'

const app = express()
const PORT = 4242

app.use(express.json())

const connection = new Redis()

app.post('/rastreamento', async (req, res) => {
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

  const myQueue = new Queue('myqueue', { connection })

  myQueue.add('rastreamento', {
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
  })

  try {
    const result = await db.pool.query(
      'INSERT INTO rastreamento (latitude, longitude, velocidade, horario_rastreador, bateria, bateria_veiculo, ignicao, altitude, direcao, odometro) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *',
      [
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
      ]
    )

    res.status(201).json(result.rows[0])
  } catch (error) {
    res.status(500).json({ error: 'Erro ao inserir dados no banco de dados' })
  }
})

app.get('/', (_, res) => {
  res.send('Hello World!')
})

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`)
})
