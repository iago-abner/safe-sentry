import express from 'express'
import { Pool } from 'pg'

const app = express()
app.use(express.json())

const pool = new Pool({
  user: 'iago',
  host: 'localhost',
  database: 'trafego',
  password: 'iago',
  port: 5432
})

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

  try {
    const result = await pool.query(
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
    console.error('Erro ao inserir dados no banco de dados:', error)
    res.status(500).json({ error: 'Erro ao inserir dados no banco de dados' })
  }
})

app.get('/', (_, res) => {
  res.send('Hello World!')
})

app.listen(3000, () => {
  console.log('Server is running on port 3000')
})
