import 'dotenv/config'
import express from 'express'
import { router } from './routes'

const app = express()
const PORT = 4242

app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use(router)

app.listen(PORT, async () => {
  console.log(`Server is running on port ${PORT}`)
})
