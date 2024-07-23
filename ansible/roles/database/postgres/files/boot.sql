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
