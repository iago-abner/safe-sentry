import { Router } from 'express'
import pg from '../repositories/pg'

export const fleet = Router()

fleet.get('/:userId', async (req, res) => {
  const { userId } = req.params

  try {
    const result = await pg.query('SELECT * FROM Frota WHERE usuario_id = $1', [
      userId
    ])

    if (result.rows.length === 0) {
      res
        .status(404)
        .json({ message: 'Nenhuma frota encontrada para este usuário' })
    }

    res.status(200).json(result.rows)
  } catch (error) {
    res.status(500).json({ message: 'Erro ao buscar frotas', error })
  }
})

fleet.get('/:frotaId', async (req, res) => {
  const { frotaId } = req.params

  try {
    const result = await pg.query('SELECT * FROM Frota WHERE id = $1', [
      frotaId
    ])

    if (result.rows.length === 0) {
      res.status(404).json({ message: 'Frota não encontrada' })
    }

    res.status(200).json(result.rows[0])
  } catch (error) {
    res.status(500).json({ message: 'Erro ao buscar frota', error })
  }
})

fleet.put('/:frotaId', async (req, res) => {
  const { frotaId } = req.params
  const { nome } = req.body

  try {
    const result = await pg.query(
      'UPDATE Frota SET nome = $1 WHERE id = $2 RETURNING *',
      [nome, frotaId]
    )

    if (result.rows.length === 0) {
      res.status(404).json({ message: 'Frota não encontrada' })
    }

    res.status(200).json(result.rows[0])
  } catch (error) {
    res.status(500).json({ message: 'Erro ao atualizar frota', error })
  }
})

fleet.post('/', async (req, res) => {
  const { name, userId } = req.body

  if (!name) {
    res.status(400).json({ message: 'Nome da frota é obrigatório' })
  }

  try {
    const result = await pg.query(
      'INSERT INTO Frota (usuario_id, nome) VALUES ($1, $2) RETURNING *',
      [userId, name]
    )

    res.status(201).json(result.rows[0])
  } catch (error) {
    res.status(500).json({ message: 'Erro ao criar frota', error })
  }
})

fleet.delete('/:frotaId', async (req, res) => {
  const { frotaId } = req.params

  try {
    const result = await pg.query(
      'DELETE FROM Frota WHERE id = $1 RETURNING *',
      [frotaId]
    )

    if (result.rows.length === 0) {
      res.status(404).json({ message: 'Frota não encontrada' })
    }

    res.status(200).json({ message: 'Frota deletada com sucesso' })
  } catch (error) {
    res.status(500).json({ message: 'Erro ao deletar frota', error })
  }
})

fleet.post('/:frotaId/:vehicleId', async (req, res) => {
  const { frotaId, vehicleId } = req.params

  try {
    const result = await pg.query(
      'INSERT INTO FrotaVeiculo (frota_id, veiculo_id) VALUES ($1, $2) RETURNING *',
      [frotaId, vehicleId]
    )

    res.status(201).json(result.rows[0])
  } catch (error) {
    res
      .status(500)
      .json({ message: 'Erro ao adicionar veículo à frota', error })
  }
})

fleet.delete('/:frotaId/:vehicleId', async (req, res) => {
  const { frotaId, vehicleId } = req.params

  try {
    const result = await pg.query(
      'DELETE FROM FrotaVeiculo WHERE frota_id = $1 AND veiculo_id = $2 RETURNING *',
      [frotaId, vehicleId]
    )

    if (result.rows.length === 0) {
      res.status(404).json({ message: 'Veículo não encontrado na frota' })
    }

    res.status(200).json({ message: 'Veículo removido da frota com sucesso' })
  } catch (error) {
    res.status(500).json({ message: 'Erro ao remover veículo da frota', error })
  }
})
