CREATE TABLE IF NOT EXISTS rastreamento (
    id SERIAL PRIMARY KEY,
    latitude DECIMAL(10, 7) NOT NULL,
    longitude DECIMAL(10, 7) NOT NULL,
    velocidade DECIMAL(5, 2),
    horario_rastreador TIMESTAMP NOT NULL,
    bateria DECIMAL(5, 2),
    bateria_veiculo DECIMAL(5, 2),
    ignicao BOOLEAN,
    altitude DECIMAL(7, 2),
    direcao DECIMAL(5, 2),
    odometro DECIMAL(10, 2),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO rastreamento (
    latitude, longitude, velocidade, horario_rastreador,
    bateria, bateria_veiculo, ignicao, altitude,
    direcao, odometro
) VALUES
(37.774929, -122.419418, 55.5, '2024-06-04 12:34:56', 80.5, 12.6, TRUE, 15.3, 180.0, 123456.7),
(34.052235, -118.243683, 45.0, '2024-06-04 13:00:00', 79.8, 12.4, FALSE, 20.1, 90.0, 123789.1);


