CREATE KEYSPACE IF NOT EXISTS projeto
WITH replication = { 'class' : 'SimpleStrategy', 'replication_factor' : '1' };

CREATE TABLE IF NOT EXISTS projeto.Localizacao (
    rastreador_id INT,
    data DATE,
    horario_rastreador TIMESTAMP,
    latitude DECIMAL,
    longitude DECIMAL,
    velocidade DECIMAL,
    bateria DECIMAL,
    bateria_veiculo DECIMAL,
    ignicao BOOLEAN,
    altitude DECIMAL,
    direcao DECIMAL,
    odometro DECIMAL,
    criado_em TIMESTAMP,
    PRIMARY KEY ((rastreador_id, data), horario_rastreador, id)
) WITH CLUSTERING ORDER BY (horario_rastreador DESC);

INSERT INTO projeto.Localizacao (rastreador_id, data, horario_rastreador, latitude, longitude, velocidade, bateria, bateria_veiculo, ignicao, altitude, direcao, odometro, criado_em) VALUES
(1, '2024-06-14', '2024-06-14 10:00:00', -23.5505, -46.6333, 60.5, 85.5, 95.5, true, 760.0, 180.0, 12345.67, toTimestamp(now()));
