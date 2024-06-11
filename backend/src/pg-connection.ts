import { Pool } from 'pg'

class Database {
  private static instance: Database
  public pool: Pool

  private constructor() {
    this.pool = new Pool({
      connectionString: process.env.DATABASE_URL
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
