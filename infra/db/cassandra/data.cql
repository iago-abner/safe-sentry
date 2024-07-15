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

INSERT INTO projeto.Localizacao (rastreador_id, data, horario_rastreador, latitude, longitude, velocidade, bateria, bateria_veiculo, ignicao, altitude, direcao, odometro, criado_em) VALUES
(1, '2024-06-14', '2024-07-15T17:52:14.944Z', -23.5505, -46.6333, 60.5, 85.5, 95.5, true, 760.0, 180.0, 12345.67, '2024-06-25T17:52:14.944Z');
