CREATE KEYSPACE IF NOT EXISTS projeto
WITH replication = { 'class' : 'SimpleStrategy', 'replication_factor' : '1' };

CREATE TABLE IF NOT EXISTS projeto.Localizacao (
    rastreador_id INT,
    data DATE,
    horario_rastreador  timestamp,
    latitude FLOAT,
    longitude FLOAT,
    velocidade FLOAT,
    bateria FLOAT,
    bateria_veiculo FLOAT,
    ignicao BOOLEAN,
    altitude FLOAT,
    direcao INT,
    odometro FLOAT,
    criado_em timestamp,
    PRIMARY KEY ((rastreador_id, data), horario_rastreador)
) WITH CLUSTERING ORDER BY (horario_rastreador DESC);
