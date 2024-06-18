import { Pool } from 'pg'

class PostgresRespository {
  private static instance: PostgresRespository
  public pool: Pool

  private constructor() {
    this.pool = new Pool({
      connectionString: 'postgresql://iago:iago@localhost:5432/Projeto'
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
