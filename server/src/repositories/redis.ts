import IOredis from 'ioredis'

class Redis {
  private static instance: Redis
  public client: IOredis

  private constructor() {
    this.client = new IOredis({
      host: 'localhost',
      port: 6379
    })
      .on('connect', () => {
        console.log('Conectado ao Redis com sucesso!')
      })
      .on('error', (err) => {
        console.error('Erro na conexão com o Redis:', err)
      })
  }

  public static getInstance(): Redis {
    if (!Redis.instance) {
      Redis.instance = new Redis()
    }

    return Redis.instance
  }
}

export default Redis.getInstance().client
