import { Router } from 'express'
import pg from '../repositories/pg'

export const user = Router()

user.post('/', async (req, res) => {
  const { nome, email, senha, telefone } = req.body

  if (!nome || !email || !senha)
    res.status(400).json({ message: 'Nome, email e senha são obrigatórios' })

  try {
    const result = await pg.query(
      'INSERT INTO Usuario (nome, email, senha, telefone) VALUES ($1, $2, $3, $4) RETURNING *',
      [nome, email, senha, telefone]
    )

    res.status(201).json(result.rows[0])
  } catch (error) {
    res.status(500).json({ message: 'Erro ao criar usuário', error })
  }
})

user.get('/:userId', async (req, res) => {
  const { userId } = req.params

  try {
    const result = await pg.query('SELECT * FROM Usuario WHERE id = $1', [
      userId
    ])

    if (result.rows.length === 0) {
      res.status(404).json({ message: 'Usuário não encontrado' })
    }

    res.status(200).json(result.rows[0])
  } catch (error) {
    res.status(500).json({ message: 'Erro ao buscar usuário', error })
  }
})

user.put('/:userId', async (req, res) => {
  const { userId } = req.params
  const { nome, email, telefone } = req.body

  try {
    const result = await pg.query(
      'UPDATE Usuario SET nome = $1, email = $2, telefone = $3 WHERE id = $4 RETURNING *',
      [nome, email, telefone, userId]
    )

    if (result.rows.length === 0)
      res.status(404).json({ message: 'Usuário não encontrado' })

    res.status(200).json(result.rows[0])
  } catch (error) {
    res.status(500).json({ message: 'Erro ao atualizar usuário', error })
  }
})

user.delete('/:userId', async (req, res) => {
  const { userId } = req.params

  try {
    const result = await pg.query(
      'DELETE FROM Usuario WHERE id = $1 RETURNING *',
      [userId]
    )

    if (result.rows.length === 0)
      res.status(404).json({ message: 'Usuário não encontrado' })

    res.status(200).json({ message: 'Usuário deletado com sucesso' })
  } catch (error) {
    res.status(500).json({ message: 'Erro ao deletar usuário', error })
  }
})
