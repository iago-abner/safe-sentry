CREATE DATABASE Projeto;

CREATE TABLE IF NOT EXISTS Usuario (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Veiculo (
    id SERIAL PRIMARY KEY,
    usuario_id INT,
    placa VARCHAR(20) NOT NULL UNIQUE,
    modelo VARCHAR(100),
    ano INT,
    cor VARCHAR(50),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Frota (
    id SERIAL PRIMARY KEY,
    usuario_id INT,
    nome VARCHAR(100) NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS FrotaVeiculo (
    frota_id INT,
    veiculo_id INT,
    PRIMARY KEY (frota_id, veiculo_id),
    FOREIGN KEY (frota_id) REFERENCES Frota(id) ON DELETE CASCADE,
    FOREIGN KEY (veiculo_id) REFERENCES Veiculo(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Rastreador (
    id SERIAL PRIMARY KEY,
    veiculo_id INT,
    identificador VARCHAR(100) NOT NULL UNIQUE,
    data_instalacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (veiculo_id) REFERENCES Veiculo(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Localizacao (
    id SERIAL PRIMARY KEY,
    rastreador_id INT,
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
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rastreador_id) REFERENCES Rastreador(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Trajeto (
    id SERIAL PRIMARY KEY,
    veiculo_id INT,
    data_inicio TIMESTAMP,
    data_fim TIMESTAMP,
    FOREIGN KEY (veiculo_id) REFERENCES Veiculo(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ConfiguracaoAlerta (
    id SERIAL PRIMARY KEY,
    veiculo_id INT,
    tipo_alerta VARCHAR(50) NOT NULL,
    valor DECIMAL(10, 2),
    mensagem TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (veiculo_id) REFERENCES Veiculo(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Alerta (
    id SERIAL PRIMARY KEY,
    veiculo_id INT,
    localizacao_id INT,
    configuracaoAlerta_id INT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (veiculo_id) REFERENCES Veiculo(id) ON DELETE CASCADE,
    FOREIGN KEY (localizacao_id) REFERENCES Localizacao(id) ON DELETE CASCADE,
    FOREIGN KEY (configuracaoAlerta_id) REFERENCES ConfiguracaoAlerta(id) ON DELETE CASCADE
);

-- INSERTS --

INSERT INTO Localizacao (
    latitude, longitude, velocidade, horario_rastreador,
    bateria, bateria_veiculo, ignicao, altitude,
    direcao, odometro
) VALUES
(37.774929, -122.419418, 55.5, '2024-06-04 12:34:56', 80.5, 12.6, TRUE, 15.3, 180.0, 123456.7),
(34.052235, -118.243683, 45.0, '2024-06-04 13:00:00', 79.8, 12.4, FALSE, 20.1, 90.0, 123789.1);



-- VIEWS --

CREATE VIEW DescricaoTrajeto AS
SELECT
    t.id AS trajeto_id,
    v.id AS veiculo_id,
    v.placa,
    l.latitude,
    l.longitude,
    l.horario_rastreador
FROM
    Trajeto t
JOIN
    Veiculo v ON t.veiculo_id = v.id
JOIN
    Rastreador r ON v.id = r.veiculo_id
JOIN
    Localizacao l ON r.id = l.rastreador_id
ORDER BY
    t.id, l.horario_rastreador;


CREATE VIEW UsuariosComMaisDeDezVeiculos AS
SELECT
    u.id AS usuario_id,
    u.nome,
    u.email,
    COUNT(v.id) AS quantidade_veiculos
FROM
    Usuario u
JOIN
    Veiculo v ON u.id = v.usuario_id
GROUP BY
    u.id, u.nome, u.email
HAVING
    COUNT(v.id) > 10;


CREATE VIEW TotalRastreadoresVinculados AS
SELECT
    COUNT(r.id) AS total_rastreadores
FROM
    Rastreador r
WHERE
    r.veiculo_id IS NOT NULL;


CREATE VIEW VeiculosPorUsuario AS
SELECT
    u.id AS usuario_id,
    u.nome,
    v.id AS veiculo_id,
    v.placa,
    v.modelo,
    v.ano,
    v.cor,
    v.data_criacao
FROM
    Usuario u
JOIN
    Veiculo v ON u.id = v.usuario_id;


CREATE VIEW VeiculosPorDataCriacao AS
SELECT
    v.id AS veiculo_id,
    v.placa,
    v.modelo,
    v.ano,
    v.cor,
    v.data_criacao,
    u.id AS usuario_id,
    u.nome
FROM
    Veiculo v
JOIN
    Usuario u ON v.usuario_id = u.id
WHERE
    v.data_criacao >= '2024-06-14';
