import { Router } from 'express'
import { location } from './location'

export const router = Router()

router.get('/', (_, res) => {
  res.send('ON')
})

router.use('/location', location)
