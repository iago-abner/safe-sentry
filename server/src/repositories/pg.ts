import { Pool } from 'pg'

class PostgresRespository {
  private static instance: PostgresRespository
  public pool: Pool

  private constructor() {
    this.pool = new Pool({
      connectionString: process.env.DATABASE_URL
    })
  }

  public static getInstance(): PostgresRespository {
    if (!PostgresRespository.instance) {
      PostgresRespository.instance = new PostgresRespository()
    }
    return PostgresRespository.instance
  }
}

export default PostgresRespository.getInstance().pool
