import { Router } from 'express'
import pg from '../repositories/pg'

export const vehicle = Router()

vehicle.get('/:userId', async (req, res) => {
  const { userId } = req.params

  try {
    const result = await pg.query(
      'SELECT * FROM Veiculo WHERE usuario_id = $1',
      [userId]
    )

    if (result.rows.length === 0) {
      res
        .status(404)
        .json({ message: 'Nenhum veículo encontrado para este usuário' })
    }

    res.status(200).json(result.rows)
  } catch (error) {
    res.status(500).json({ message: 'Erro ao buscar veículos', error })
  }
})

vehicle.get('/:vehicleId', async (req, res) => {
  const { vehicleId } = req.params

  try {
    const result = await pg.query('SELECT * FROM Veiculo WHERE id = $1', [
      vehicleId
    ])

    if (result.rows.length === 0) {
      res.status(404).json({ message: 'Veículo não encontrado' })
    }

    res.status(200).json(result.rows[0])
  } catch (error) {
    res.status(500).json({ message: 'Erro ao buscar veículo', error })
  }
})

vehicle.post('/:userId', async (req, res) => {
  const { userId } = req.params
  const { placa, modelo, ano, cor } = req.body

  if (!placa || !modelo || !ano || !cor)
    res.status(400).json({ message: 'All fields are required' })

  try {
    const result = await pg.query(
      'INSERT INTO Veiculo (usuario_id, placa, modelo, ano, cor) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [userId, placa, modelo, ano, cor]
    )

    res.status(201).json(result.rows[0])
  } catch (error) {
    res.status(500).json({ message: 'Error creating vehicle', error })
  }
})

vehicle.put('/:vehicleId', async (req, res) => {
  const { vehicleId } = req.params
  const { placa, modelo, ano, cor } = req.body

  try {
    const result = await pg.query(
      'UPDATE Veiculo SET placa = $1, modelo = $2, ano = $3, cor = $4 WHERE id = $5 RETURNING *',
      [placa, modelo, ano, cor, vehicleId]
    )

    if (result.rows.length === 0) {
      res.status(404).json({ message: 'Veículo não encontrado' })
    }

    res.status(200).json(result.rows[0])
  } catch (error) {
    res.status(500).json({ message: 'Erro ao atualizar veículo', error })
  }
})

vehicle.delete('/:vehicleId', async (req, res) => {
  const { vehicleId } = req.params

  try {
    const result = await pg.query(
      'DELETE FROM Veiculo WHERE id = $1 RETURNING *',
      [vehicleId]
    )

    if (result.rows.length === 0) {
      res.status(404).json({ message: 'Veículo não encontrado' })
    }

    res.status(200).json({ message: 'Veículo deletado com sucesso' })
  } catch (error) {
    res.status(500).json({ message: 'Erro ao deletar veículo', error })
  }
})
