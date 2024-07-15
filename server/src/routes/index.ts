import { Router } from 'express'
import { vehicle } from './vehicle'
import { location } from './location'
import { fleet } from './fleet'
import { user } from './user'

export const router = Router()

router.get('/', (_, res) => {
  res.send('ON')
})

router.use('/location', location)
router.use('/vehicle', vehicle)
router.use('/fleet', fleet)
router.use('/user', user)
