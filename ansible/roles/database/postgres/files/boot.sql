CREATE DATABASE Projeto;

CREATE TABLE IF NOT EXISTS Localizacao (
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

INSERT INTO Localizacao (latitude, longitude, velocidade, horario_rastreador, bateria, bateria_veiculo, ignicao, altitude, direcao, odometro) VALUES
(-23.5505, -46.6333, 60.5, '2024-06-14 10:00:00', 85.5, 95.5, TRUE, 760.0, 180.0, 12345.67),
(-23.5506, -46.6334, 62.0, '2024-06-14 10:05:00', 84.5, 94.5, TRUE, 762.0, 182.0, 12350.67),
(-23.5510, -46.6340, 50.0, '2024-06-15 09:00:00', 90.0, 98.0, TRUE, 700.0, 170.0, 12360.67),
(-23.5520, -46.6350, 70.0, '2024-06-16 11:00:00', 75.0, 85.0, FALSE, 780.0, 190.0, 12400.67),
(-23.5530, -46.6360, 55.0, '2024-06-17 08:00:00', 80.0, 90.0, TRUE, 720.0, 175.0, 12450.67);
