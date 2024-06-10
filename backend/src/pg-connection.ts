import { Pool } from 'pg'

class Database {
  private static instance: Database
  public pool: Pool

  private constructor() {
    this.pool = new Pool({
      user: 'iago',
      host: 'localhost',
      database: 'trafego',
      password: 'iago',
      port: 5432
    })
  }

  public static getInstance(): Database {
    if (!Database.instance) {
      Database.instance = new Database()
    }
    return Database.instance
  }
}

export default Database.getInstance()
