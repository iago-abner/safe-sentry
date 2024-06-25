CREATE DATABASE Projeto;

CREATE TABLE NaoNormalizado (
    usuario_id INT,
    nome_usuario VARCHAR(100),
    email_usuario VARCHAR(100),
    senha_usuario VARCHAR(255),
    telefone_usuario VARCHAR(20),
    data_criacao_usuario TIMESTAMP,
    veiculo_id INT,
    placa VARCHAR(20),
    modelo VARCHAR(100),
    ano INT,
    cor VARCHAR(50),
    data_criacao_veiculo TIMESTAMP,
    frota_id INT,
    nome_frota VARCHAR(100),
    data_criacao_frota TIMESTAMP,
    rastreador_id INT,
    identificador_rastreador VARCHAR(100),
    data_instalacao_rastreador TIMESTAMP,
    localizacao_id INT,
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    velocidade DECIMAL(5, 2),
    horario_rastreador TIMESTAMP,
    bateria DECIMAL(5, 2),
    bateria_veiculo DECIMAL(5, 2),
    ignicao BOOLEAN,
    altitude DECIMAL(7, 2),
    direcao DECIMAL(5, 2),
    odometro DECIMAL(10, 2),
    criado_em_localizacao TIMESTAMP,
    trajeto_id INT,
    data_inicio_trajeto TIMESTAMP,
    data_fim_trajeto TIMESTAMP,
    configuracao_alerta_id INT,
    tipo_alerta VARCHAR(50),
    valor_alerta DECIMAL(10, 2),
    mensagem_alerta TEXT,
    ativo_alerta BOOLEAN,
    data_criacao_alerta TIMESTAMP,
    alerta_id INT,
    localizacao_alerta_id INT,
    configuracao_alerta_alerta_id INT,
    data_hora_alerta TIMESTAMP
);

INSERT INTO NaoNormalizado (
    usuario_id, nome_usuario, email_usuario, senha_usuario, telefone_usuario, data_criacao_usuario,
    veiculo_id, placa, modelo, ano, cor, data_criacao_veiculo,
    frota_id, nome_frota, data_criacao_frota,
    rastreador_id, identificador_rastreador, data_instalacao_rastreador,
    localizacao_id, latitude, longitude, velocidade, horario_rastreador, bateria, bateria_veiculo, ignicao, altitude, direcao, odometro, criado_em_localizacao,
    trajeto_id, data_inicio_trajeto, data_fim_trajeto,
    configuracao_alerta_id, tipo_alerta, valor_alerta, mensagem_alerta, ativo_alerta, data_criacao_alerta,
    alerta_id, localizacao_alerta_id, configuracao_alerta_alerta_id, data_hora_alerta
) VALUES
(
    1, 'João Silva', 'joao@email.com', 'senha123', '123456789', '2023-01-01 10:00:00',
    1, 'ABC-1234', 'Gol', 2020, 'Preto', '2023-01-01 10:00:00',
    1, 'Frota A', '2023-01-01 10:00:00',
    1, 'RAST-001', '2023-01-01 10:00:00',
    1, -23.5505, -46.6333, 80, '2023-01-01 10:00:00', 90, 85, true, 700, 180, 1500, '2023-01-01 10:00:00',
    1, '2023-01-01 10:00:00', '2023-01-01 10:30:00',
    1, 'Velocidade', 100, 'Alerta de velocidade', true, '2023-01-01 10:00:00',
    1, 1, 1, '2023-01-01 10:05:00'
),
(
    2, 'Maria Oliveira', 'maria@email.com', 'senha456', '987654321', '2023-01-02 11:00:00',
    2, 'XYZ-5678', 'Uno', 2021, 'Branco', '2023-01-02 11:00:00',
    2, 'Frota B', '2023-01-02 11:00:00',
    2, 'RAST-002', '2023-01-02 11:00:00',
    2, -22.9068, -43.1729, 60, '2023-01-02 11:00:00', 95, 90, false, 500, 90, 1200, '2023-01-02 11:00:00',
    2, '2023-01-02 11:00:00', '2023-01-02 11:30:00',
    2, 'Bateria', 50, 'Alerta de bateria', true, '2023-01-02 11:00:00',
    2, 2, 2, '2023-01-02 11:05:00'
);


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

-- INDECES

CREATE INDEX idx_localizacao_horario_rastreador ON Localizacao(horario_rastreador);

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
WHERE
    l.horario_rastreador BETWEEN t.data_inicio AND t.data_fim
ORDER BY
    t.id, l.horario_rastreador;

-- VIEW UsuariosComMaisDeDezVeiculos
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

-- VIEW TotalRastreadoresVinculados
CREATE VIEW TotalRastreadores AS
SELECT
    (SELECT COUNT(*) FROM Rastreador) AS total_rastreadores,
    (SELECT COUNT(*) FROM Rastreador WHERE veiculo_id IS NOT NULL) AS total_rastreadores_vinculados,
    (SELECT COUNT(*) FROM Rastreador WHERE veiculo_id IS NULL) AS total_rastreadores_sem_vinculo;



CREATE VIEW VeiculosPorUsuario AS
SELECT
    u.id AS usuario_id,
    u.nome,
    COUNT(v.id) AS quantidade_total_veiculos
FROM
    Usuario u
LEFT JOIN
    Veiculo v ON u.id = v.usuario_id
GROUP BY
    u.id, u.nome;


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

CREATE VIEW FrotasEQuantidadeVeiculos AS
SELECT
    f.id AS frota_id,
    f.nome AS frota_nome,
    COUNT(fv.veiculo_id) AS quantidade_veiculos
FROM
    Frota f
LEFT JOIN
    FrotaVeiculo fv ON f.id = fv.frota_id
GROUP BY
    f.id, f.nome;


-- INSERTS --
INSERT INTO Usuario (nome, email, senha, telefone) VALUES
('João Silva', 'joao.silva@example.com', 'senha123', '11987654321'),
('Maria Oliveira', 'maria.oliveira@example.com', 'senha123', '11987654322'),
('Carlos Pereira', 'carlos.pereira@example.com', 'senha123', '11987654323'),
('Ana Souza', 'ana.souza@example.com', 'senha123', '11987654324'),
('Pedro Santos', 'pedro.santos@example.com', 'senha123', '11987654325');

INSERT INTO Veiculo (usuario_id, placa, modelo, ano, cor) VALUES
(1, 'ABC1D23', 'Fiat Uno', 2010, 'Branco'),
(1, 'ABC2D34', 'VW Gol', 2015, 'Preto'),
(1, 'ABC3D45', 'Chevrolet Onix', 2018, 'Vermelho'),
(1, 'ABC4D56', 'Honda Civic', 2020, 'Cinza'),
(1, 'ABC5D67', 'Toyota Corolla', 2021, 'Azul'),
(1, 'ABC6D78', 'Ford Ka', 2019, 'Verde'),
(1, 'ABC7D89', 'Renault Kwid', 2022, 'Amarelo'),
(1, 'ABC8D90', 'Hyundai HB20', 2023, 'Roxo'),
(1, 'ABC9E01', 'Jeep Renegade', 2021, 'Laranja'),
(1, 'ABCD123', 'Kia Sportage', 2019, 'Prata'),
(1, 'ABCDE45', 'Peugeot 208', 2022, 'Marrom');

INSERT INTO Frota (usuario_id, nome) VALUES
(1, 'Frota 01');

INSERT INTO FrotaVeiculo (frota_id, veiculo_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8),
(1, 9),
(1, 10),
(1, 11);

INSERT INTO Rastreador (veiculo_id, identificador) VALUES
(1, 'R12345'),
(2, 'R23456'),
(3, 'R34567'),
(4, 'R45678'),
(5, 'R56789'),
(6, 'R67890'),
(7, 'R78901'),
(8, 'R89012'),
(9, 'R90123'),
(10, 'R01234'),
(11, 'R12346'),
(NULL, 'R23457');

INSERT INTO Localizacao (rastreador_id, latitude, longitude, velocidade, horario_rastreador, bateria, bateria_veiculo, ignicao, altitude, direcao, odometro) VALUES
(1, -23.5505, -46.6333, 60.5, '2024-06-14 10:00:00', 85.5, 95.5, TRUE, 760.0, 180.0, 12345.67),
(1, -23.5506, -46.6334, 62.0, '2024-06-14 10:05:00', 84.5, 94.5, TRUE, 762.0, 182.0, 12350.67),
(2, -23.5510, -46.6340, 50.0, '2024-06-15 09:00:00', 90.0, 98.0, TRUE, 700.0, 170.0, 12360.67),
(3, -23.5520, -46.6350, 70.0, '2024-06-16 11:00:00', 75.0, 85.0, FALSE, 780.0, 190.0, 12400.67),
(4, -23.5530, -46.6360, 55.0, '2024-06-17 08:00:00', 80.0, 90.0, TRUE, 720.0, 175.0, 12450.67);

INSERT INTO Trajeto (veiculo_id, data_inicio, data_fim) VALUES
(1, '2024-06-14 09:00:00', '2024-06-14 11:00:00'),
(2, '2024-06-15 08:00:00', '2024-06-15 10:00:00');

INSERT INTO ConfiguracaoAlerta (veiculo_id, tipo_alerta, valor, mensagem) VALUES
(1, 'Velocidade', 80.0, 'Velocidade acima do permitido'),
(2, 'Bateria', 20.0, 'Bateria do veículo baixa');

INSERT INTO Alerta (veiculo_id, localizacao_id, configuracaoAlerta_id) VALUES
(1, 1, 1),
(2, 3, 2);
