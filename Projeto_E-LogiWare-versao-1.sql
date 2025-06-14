/*
CREATE DATABASE LogiWare;
USE LogiWare;

CREATE TABLE Armazenamento (
    id_armazenamento INT AUTO_INCREMENT PRIMARY KEY,
    capacidade_total INT NOT NULL,
    capacidade_utilizada INT NOT NULL
);

CREATE TABLE Produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    quantidade_estoque INT NOT NULL,
    id_armazenamento INT,
    FOREIGN KEY (id_armazenamento) REFERENCES Armazenamento(id_armazenamento)
);

CREATE TABLE Pedido (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    data_pedido DATE NOT NULL,
    status_pedido VARCHAR(50) NOT NULL
);

CREATE TABLE Transportadora (
    id_transportadora INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    contato VARCHAR(100) NOT NULL
);

CREATE TABLE Fornecedor (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    contato VARCHAR(100) NOT NULL
);

SHOW TABLES;

CREATE TRIGGER atualizar_estoque
AFTER INSERT ON Pedido
FOR EACH ROW
UPDATE Produto
SET quantidade_estoque = quantidade_estoque - 1
WHERE id_produto = NEW.id_pedido;



CREATE TABLE HistoricoMovimentacao (
    id_movimentacao INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT,
    tipo_movimentacao ENUM('entrada', 'saida'),
    quantidade INT,
    data_movimentacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);



SELECT id_armazenamento, capacidade_total, capacidade_utilizada,
       (capacidade_total - capacidade_utilizada) AS espaco_livre
FROM Armazenamento;



CREATE TABLE PedidoProduto (
    id_pedido INT,
    id_produto INT,
    quantidade INT,
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);



CREATE TABLE FornecedorProduto (
    id_fornecedor INT,
    id_produto INT,
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor(id_fornecedor),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);



SELECT id_produto, descricao, quantidade_estoque
FROM Produto
WHERE quantidade_estoque > 0;



SELECT HistoricoMovimentacao.id_produto, Produto.descricao, 
       HistoricoMovimentacao.tipo_movimentacao, HistoricoMovimentacao.quantidade, 
       HistoricoMovimentacao.data_movimentacao
FROM HistoricoMovimentacao
JOIN Produto ON HistoricoMovimentacao.id_produto = Produto.id_produto
ORDER BY HistoricoMovimentacao.data_movimentacao DESC;


DELIMITER $$
CREATE PROCEDURE AtualizarEstoque(IN pedido_id INT)
BEGIN
    UPDATE Produto
    SET quantidade_estoque = quantidade_estoque - (
        SELECT quantidade FROM PedidoProduto WHERE id_pedido = pedido_id
    )
    WHERE id_produto IN (
        SELECT id_produto FROM PedidoProduto WHERE id_pedido = pedido_id
    );
END;


DELIMITER $$
CREATE PROCEDURE AlocarProduto(IN produto_id INT, IN quantidade INT)
BEGIN
    DECLARE local_disponivel INT;

    -- Encontrar um local de armazenamento com espaço disponível
    SELECT id_armazenamento INTO local_disponivel
    FROM Armazenamento
    WHERE (capacidade_total - capacidade_utilizada) >= quantidade
    LIMIT 1;

    -- Atualizar localização do produto
    UPDATE Produto
    SET id_armazenamento = local_disponivel
    WHERE id_produto = produto_id;

    -- Atualizar capacidade utilizada
    UPDATE Armazenamento
    SET capacidade_utilizada = capacidade_utilizada + quantidade
    WHERE id_armazenamento = local_disponivel;
END;

SELECT id_produto, descricao, quantidade_estoque
FROM Produto
WHERE quantidade_estoque > 0;

SELECT HistoricoMovimentacao.id_produto, Produto.descricao, 
       HistoricoMovimentacao.tipo_movimentacao, HistoricoMovimentacao.quantidade, 
       HistoricoMovimentacao.data_movimentacao
FROM HistoricoMovimentacao
JOIN Produto ON HistoricoMovimentacao.id_produto = Produto.id_produto
ORDER BY HistoricoMovimentacao.data_movimentacao DESC;

SHOW CREATE TABLE PedidoProduto;
SHOW CREATE TABLE Produto;
SHOW CREATE TABLE FornecedorProduto;
SHOW TABLES;

SHOW CREATE TABLE PedidoProduto;
SHOW CREATE TABLE Pedido;

ALTER TABLE Pedido
ADD COLUMN id_transportadora INT,
ADD FOREIGN KEY (id_transportadora) REFERENCES Transportadora(id_transportadora);

USE LogiWare;

SELECT * FROM Pedido

SELECT * FROM Produto

INSERT INTO Armazenamento (capacidade_total, capacidade_utilizada) VALUES (5000, 2400), (5000, 2400);

CREATE TABLE Categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE
);

ALTER TABLE Produto ADD COLUMN id_categoria INT;
ALTER TABLE Produto ADD FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria);

INSERT INTO Categoria (nome) VALUES 
    ('Tubos e Conexões'), 
    ('Pintura');

INSERT INTO Produto (descricao, quantidade_estoque, id_armazenamento, id_categoria) VALUES 
    ('Tigre Tubo de Esgoto 100 mm 6 m', 200, 1, 1), 
    ('Tigre Tubo de Esgoto 75 mm 6 m', 200, 2, 1), 
    ('Tigre Tubo de Esgoto 50 mm 6 m', 200, 3, 1), 
    ('Tigre Tubo de Esgoto 40 mm 6 m', 40, 4, 1), 
    ('Tigre Joelho 90º PVC para Esgoto 100 mm', 200, 5, 1), 
    ('Tigre Joelho 90º PVC para Esgoto 75 mm', 200, 6, 1), 
    ('Tigre Joelho 90º PVC para Esgoto 50 mm', 200, 7, 1), 
    ('Tigre Joelho 90º PVC para Esgoto 40 mm', 200, 8, 1), 
    ('Tigre Joelho 90º roscável 1/2"', 200, 9, 1), 
    ('Tigre Joelho 90º roscável 3/4"', 200, 10, 1), 
    ('Tigre Joelho 90º roscável 1"', 200, 11, 1), 
    ('Tigre Joelho 90º roscável 1.1/4"', 200, 12, 1), 
    ('Coral Tinta PVA Látex Acrílica Branca 3,6 litros', 200, 13, 2), 
    ('Coral Tinta PVA Látex Acrílica Branca Lata 18 litros', 200, 14, 2), 
    ('Coral Tinta PVA Látex Acrílica Amarela 3,6 litros', 200, 15, 2), 
    ('Coral Tinta PVA Látex Acrílica Amarela Lata 18 litros', 200, 16, 2), 
    ('Coral Tinta PVA Látex Acrílica Vermelha 3,6 litros', 200, 17, 2), 
    ('Coral Tinta PVA Látex Acrílica Vermelha Lata 18 litros', 200, 18, 2), 
    ('Coral Tinta PVA Látex Acrílica Preta 3,6 litros', 200, 19, 2), 
    ('Coral Tinta PVA Látex Acrílica Preta Lata 18 litros', 200, 20, 2), 
    ('Coral Tinta PVA Látex Acrílica Azul 3,6 litros', 200, 21, 2), 
    ('Coral Tinta PVA Látex Acrílica Azul Lata 18 litros', 200, 22, 2), 
    ('Coral Tinta PVA Látex Acrílica Verde 3,6 litros', 200, 23, 2), 
    ('Coral Tinta PVA Látex Acrílica Verde Lata 18 litros', 200, 24, 2);

SELECT * FROM Categoria;

SHOW CREATE TABLE Produto;

ALTER TABLE Produto ADD CONSTRAINT fk_categoria FOREIGN KEY (id_categoria) 
REFERENCES Categoria(id_categoria) ON DELETE SET NULL;

INSERT INTO Produto (descricao, quantidade_estoque, id_armazenamento, id_categoria) VALUES 
    ('Tigre Tubo de Esgoto 100 mm 6 m', 200, 1, 1), 
    ('Tigre Tubo de Esgoto 75 mm 6 m', 200, 2, 1), 
    ('Tigre Tubo de Esgoto 50 mm 6 m', 200, 3, 1), 
    ('Tigre Tubo de Esgoto 40 mm 6 m', 40, 4, 1), 
    ('Tigre Joelho 90º PVC para Esgoto 100 mm', 200, 5, 1), 
    ('Tigre Joelho 90º PVC para Esgoto 75 mm', 200, 6, 1), 
    ('Tigre Joelho 90º PVC para Esgoto 50 mm', 200, 7, 1), 
    ('Tigre Joelho 90º PVC para Esgoto 40 mm', 200, 8, 1), 
    ('Tigre Joelho 90º roscável 1/2"', 200, 9, 1), 
    ('Tigre Joelho 90º roscável 3/4"', 200, 10, 1), 
    ('Tigre Joelho 90º roscável 1"', 200, 11, 1), 
    ('Tigre Joelho 90º roscável 1.1/4"', 200, 12, 1), 
    ('Coral Tinta PVA Látex Acrílica Branca 3,6 litros', 200, 13, 2), 
    ('Coral Tinta PVA Látex Acrílica Branca Lata 18 litros', 200, 14, 2), 
    ('Coral Tinta PVA Látex Acrílica Amarela 3,6 litros', 200, 15, 2), 
    ('Coral Tinta PVA Látex Acrílica Amarela Lata 18 litros', 200, 16, 2), 
    ('Coral Tinta PVA Látex Acrílica Vermelha 3,6 litros', 200, 17, 2), 
    ('Coral Tinta PVA Látex Acrílica Vermelha Lata 18 litros', 200, 18, 2), 
    ('Coral Tinta PVA Látex Acrílica Preta 3,6 litros', 200, 19, 2), 
    ('Coral Tinta PVA Látex Acrílica Preta Lata 18 litros', 200, 20, 2), 
    ('Coral Tinta PVA Látex Acrílica Azul 3,6 litros', 200, 21, 2), 
    ('Coral Tinta PVA Látex Acrílica Azul Lata 18 litros', 200, 22, 2), 
    ('Coral Tinta PVA Látex Acrílica Verde 3,6 litros', 200, 23, 2), 
    ('Coral Tinta PVA Látex Acrílica Verde Lata 18 litros', 200, 24, 2);
    
SELECT * FROM Armazenamento;

INSERT INTO Armazenamento (id_armazenamento, capacidade_total, capacidade_utilizada) VALUES 
    (3, 600, 150), 
    (4, 500, 120), (5, 400, 100), (6, 700, 300),
    (7, 900, 400), (8, 1100, 500), (9, 1200, 600),
    (10, 1300, 700), (11, 1400, 800), (12, 1500, 900),
    (13, 1600, 1000), (14, 1700, 1100), (15, 1800, 1200),
    (16, 1900, 1300), (17, 2000, 1400), (18, 2100, 1500),
    (19, 2200, 1600), (20, 2300, 1700), (21, 2400, 1800),
    (22, 2500, 1900), (23, 2600, 2000), (24, 2700, 2100);

UPDATE Armazenamento 
SET capacidade_total = (1000, 800)
WHERE id_armazenamento IN (1, 2);

UPDATE Armazenamento SET capacidade_total = 1000 WHERE id_armazenamento = 1;
UPDATE Armazenamento SET capacidade_total = 800 WHERE id_armazenamento = 2;

UPDATE Armazenamento SET capacidade_utilizada = 250 WHERE id_armazenamento = 1;
UPDATE Armazenamento SET capacidade_utilizada = 200 WHERE id_armazenamento = 2;

INSERT INTO Produto (descricao, quantidade_estoque, id_armazenamento, id_categoria) VALUES 
    ('Tigre Tubo de Esgoto 100 mm 6 m', 200, 1, 1), 
    ('Tigre Tubo de Esgoto 75 mm 6 m', 200, 2, 1), 
    ('Tigre Tubo de Esgoto 50 mm 6 m', 200, 3, 1), 
    ('Tigre Tubo de Esgoto 40 mm 6 m', 40, 4, 1), 
    ('Tigre Joelho 90º PVC para Esgoto 100 mm', 200, 5, 1), 
    ('Tigre Joelho 90º PVC para Esgoto 75 mm', 200, 6, 1), 
    ('Tigre Joelho 90º PVC para Esgoto 50 mm', 200, 7, 1), 
    ('Tigre Joelho 90º PVC para Esgoto 40 mm', 200, 8, 1), 
    ('Tigre Joelho 90º roscável 1/2"', 200, 9, 1), 
    ('Tigre Joelho 90º roscável 3/4"', 200, 10, 1), 
    ('Tigre Joelho 90º roscável 1"', 200, 11, 1), 
    ('Tigre Joelho 90º roscável 1.1/4"', 200, 12, 1), 
    ('Coral Tinta PVA Látex Acrílica Branca 3,6 litros', 200, 13, 2), 
    ('Coral Tinta PVA Látex Acrílica Branca Lata 18 litros', 200, 14, 2), 
    ('Coral Tinta PVA Látex Acrílica Amarela 3,6 litros', 200, 15, 2), 
    ('Coral Tinta PVA Látex Acrílica Amarela Lata 18 litros', 200, 16, 2), 
    ('Coral Tinta PVA Látex Acrílica Vermelha 3,6 litros', 200, 17, 2), 
    ('Coral Tinta PVA Látex Acrílica Vermelha Lata 18 litros', 200, 18, 2), 
    ('Coral Tinta PVA Látex Acrílica Preta 3,6 litros', 200, 19, 2), 
    ('Coral Tinta PVA Látex Acrílica Preta Lata 18 litros', 200, 20, 2), 
    ('Coral Tinta PVA Látex Acrílica Azul 3,6 litros', 200, 21, 2), 
    ('Coral Tinta PVA Látex Acrílica Azul Lata 18 litros', 200, 22, 2), 
    ('Coral Tinta PVA Látex Acrílica Verde 3,6 litros', 200, 23, 2), 
    ('Coral Tinta PVA Látex Acrílica Verde Lata 18 litros', 200, 24, 2);


-- Inserindo transportadoras
INSERT INTO Transportadora (nome, contato) VALUES 
    ('Lando Transportes de Produtos Ltda', 'contato@lando_pvc.com'), 
    ('Lando Transporte de Tintas Ltda', 'contato@lando_tintas.com');


-- Inserindo fornecedores
INSERT INTO Fornecedor (nome, contato) VALUES 
    ('Tubos e Conexões Tigre S/A', 'tigre-tubos.com'), 
    ('Tintas Coral S/A', 'coral-tintas.com');

-- Inserindo pedidos
INSERT INTO Pedido (data_pedido, status_pedido, id_transportadora) VALUES 
    ('2025-05-25', 'Pendente', 1), 
    ('2025-05-26', 'Em processamento', 2);


INSERT INTO PedidoProduto (id_pedido, id_produto, quantidade) VALUES 
    (1, 1, 2), 
    (1, 2, 1), 
    (2, 3, 5);

SELECT * FROM Produto WHERE id_produto IN (1, 2, 3);

SHOW CREATE TABLE PedidoProduto;

INSERT INTO Produto (id_produto, descricao, quantidade_estoque, id_armazenamento, id_categoria) VALUES 
    (1, 'Tigre Tubo de Esgoto 100 mm 6 m', 100, 1, 1), 
    (2, 'Tigre Tubo de Esgoto 75 mm 6 m', 150, 2, 1), 
    (3, 'Tigre Tubo de Esgoto 50 mm 6 m', 200, 3, 2);
    
SHOW CREATE TABLE PedidoProduto;

INSERT INTO PedidoProduto (id_pedido, id_produto, quantidade) VALUES 
    (1, 1, 2), 
    (1, 2, 1), 
    (2, 3, 5);

SELECT * FROM Produto;

SELECT * FROM Pedido;

SHOW CREATE TABLE PedidoProduto;

INSERT INTO PedidoProduto (id_pedido, id_produto, quantidade) VALUES 
    (1, 1, 2), 
    (1, 2, 1), 
    (2, 3, 5);

SELECT * FROM PedidoProduto;

SELECT p.descricao, pp.quantidade 
FROM PedidoProduto pp 
JOIN Produto p ON pp.id_produto = p.id_produto 
WHERE pp.id_pedido = 1;

SELECT * FROM Rastreamento WHERE id_pedido = 1;

CREATE TABLE Rastreamento (
    id_rastreamento INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    id_produto INT,
    status VARCHAR(50), -- Exemplo: "Em transporte", "Entregue", "Aguardando envio"
    localizacao_atual VARCHAR(255),
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

INSERT INTO Rastreamento (id_pedido, id_produto, status, localizacao_atual) VALUES
    (1, 1, 'Em transporte', 'Centro de Distribuição - São Paulo'),
    (1, 2, 'Entregue', 'Cliente - Campinas');
    
SELECT * FROM Rastreamento WHERE id_pedido = 1;

CREATE TABLE FornecedorProduto (
    id_fornecedor INT,
    id_produto INT,
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor(id_fornecedor),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

ALTER TABLE Pedido ADD COLUMN id_transportadora INT;
ALTER TABLE Pedido ADD FOREIGN KEY (id_transportadora) REFERENCES Transportadora(id_transportadora);

CREATE TABLE RastreamentoEntrega (
    id_rastreamento INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    id_transportadora INT,
    status VARCHAR(50), -- Exemplo: "Em trânsito", "Entregue", "Aguardando envio"
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    FOREIGN KEY (id_transportadora) REFERENCES Transportadora(id_transportadora)
);

INSERT INTO fornecedorproduto (id_fornecedor, id_produto) VALUES 
    (1, 1), (1, 2), (1, 3), (1, 73), (1, 74), (1, 75), (1, 76), (1, 77), (1, 78), (1, 79), (1, 80), (1, 81), (1, 82), (1, 83), (1, 84);

SELECT * FROM fornecedor WHERE id_fornecedor = 2;

SELECT * FROM produto WHERE id_produto BETWEEN 1 AND 84;

SELECT * FROM produto

SELECT * FROM produto WHERE id_produto BETWEEN 85 AND 96;


SELECT * FROM fornecedor WHERE id_fornecedor = 2;
SELECT * FROM produto WHERE id_produto BETWEEN 85 AND 96;


SHOW TABLES

INSERT INTO fornecedorproduto (id_fornecedor, id_produto) VALUES 
    (2, 85), (2, 86), (2, 87), (2, 88), (2, 89), (2, 90), (2, 91), (2, 92), (2, 93), (2, 94), (2, 95), (2, 96)

SELECT f.nome AS fornecedor, SUM(p.quantidade_estoque) AS total_estoque 
FROM FornecedorProduto fp
JOIN Fornecedor f ON fp.id_fornecedor = f.id_fornecedor
JOIN Produto p ON fp.id_produto = p.id_produto
GROUP BY f.nome;

SELECT f.nome AS fornecedor, p.descricao AS produto, p.quantidade_estoque 
FROM FornecedorProduto fp
JOIN Fornecedor f ON fp.id_fornecedor = f.id_fornecedor
JOIN Produto p ON fp.id_produto = p.id_produto
ORDER BY f.nome, p.descricao;

SHOW TABLES
SHOW TRIGGER;
SELECT * FROM HistoricoMovimentacao;
SHOW TRIGGERS FROM logiware;
SELECT VERSION();

INSERT INTO HistoricoMovimentacao (id_produto, tipo_movimentacao, quantidade) VALUES
    (1, 'Saída', 5);

SELECT * FROM HistoricoMovimentacao;

DELIMITER //

CREATE TRIGGER RegistraMovimentacao
AFTER INSERT ON PedidoProduto
FOR EACH ROW
BEGIN
    INSERT INTO HistoricoMovimentacao (id_produto, tipo_movimentacao, quantidade)
    VALUES (NEW.id_produto, 'Saída', NEW.quantidade);
END;

//

DELIMITER ;

SHOW TABLES LIKE 'HistoricoMovimentacao';

SELECT * FROM Produto WHERE id_armazenamento IS NOT NULL;

SELECT * FROM Armazenamento;

SHOW TRIGGERS FROM logiware;

DELIMITER //

CREATE TRIGGER AtualizaCapacidade
AFTER INSERT ON Produto
FOR EACH ROW
BEGIN
    UPDATE Armazenamento 
    SET capacidade_utilizada = capacidade_utilizada + NEW.quantidade_estoque
    WHERE id_armazenamento = NEW.id_armazenamento;
END;
//

DELIMITER ;

SELECT id_armazenamento FROM Produto WHERE id_armazenamento IS NULL;

SHOW TABLES LIKE 'Pedido';
SHOW COLUMNS FROM PedidoProduto;
SHOW COLUMNS FROM Pedido;

SELECT id_cliente FROM Pedido LIMIT 10;
SELECT id_transportadora, status_pedido FROM Pedido LIMIT 10;


CREATE TABLE Cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefone VARCHAR(20),
    endereco VARCHAR(255)
);

ALTER TABLE Pedido ADD COLUMN id_cliente INT;
ALTER TABLE Pedido ADD CONSTRAINT fk_cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente);

INSERT INTO Cliente (nome, email, telefone, endereco) VALUES
    ('Lando Souza', 'lando@email.com', '11999999999', 'Rua Lá de Casa, 100 número, Campinas'),
    ('Regiane Souza', 'regiane@email.com', '21999999999', 'Rua da Casa Dela, com número, Campinas');

UPDATE Pedido SET id_cliente = 1 WHERE id_pedido = 1;
UPDATE Pedido SET id_cliente = 2 WHERE id_pedido = 2;

SHOW TABLES LIKE 'Cliente';

SHOW COLUMNS FROM Pedido;

SELECT p.id_pedido, c.nome AS cliente, c.email, c.telefone 
FROM Pedido p
JOIN Cliente c ON p.id_cliente = c.id_cliente;

INSERT INTO Pedido (id_cliente, status_pedido) VALUES (1, 'Em andamento');

SELECT * FROM Pedido WHERE id_cliente = 1;

SHOW CREATE TABLE Pedido;

INSERT INTO Pedido (id_cliente, status_pedido, data_pedido, valor_total) 
VALUES (1, 'Em andamento', NOW(), 200.00);

ALTER TABLE Pedido ALTER COLUMN data_pedido SET DEFAULT NOW();
ALTER TABLE Pedido ALTER COLUMN valor_total SET DEFAULT 0;

INSERT INTO Pedido (id_cliente, status_pedido, data_pedido, valor_total) 
VALUES (1, 'Em andamento', NOW(), 200.00);

ALTER TABLE Pedido ALTER COLUMN valor_total SET DEFAULT 0;

SHOW COLUMNS FROM Pedido;

ALTER TABLE Pedido ADD COLUMN valor_total DECIMAL(10,2) DEFAULT 0.00;

INSERT INTO Pedido (id_cliente, status_pedido) VALUES (1, 'Em andamento');


SELECT id_pedido, data_pedido, valor_total FROM Pedido;

SELECT descricao, quantidade_estoque 
FROM Produto 
WHERE quantidade_estoque > 0
ORDER BY descricao;

SELECT h.id_movimentacao, p.descricao AS produto, h.tipo_movimentacao, 
       h.quantidade, h.data_movimentacao
FROM HistoricoMovimentacao h
JOIN Produto p ON h.id_produto = p.id_produto
ORDER BY h.data_movimentacao DESC;

SELECT f.nome AS fornecedor, p.descricao, p.quantidade_estoque 
FROM Produto p
JOIN FornecedorProduto fp ON p.id_produto = fp.id_produto
JOIN Fornecedor f ON fp.id_fornecedor = f.id_fornecedor
ORDER BY f.nome, p.descricao;

DELIMITER //

CREATE PROCEDURE AtualizaEstoque(IN produto_id INT, IN quantidade INT)
BEGIN
    UPDATE Produto
    SET quantidade_estoque = quantidade_estoque - quantidade
    WHERE id_produto = produto_id;
END;

//

DELIMITER ;

CALL AtualizaEstoque(1, 5);

DELIMITER //

CREATE PROCEDURE AlocaProduto(IN produto_id INT, IN quantidade INT)
BEGIN
    DECLARE armazenamento_id INT;

    -- Encontra um local com espaço suficiente
    SELECT id_armazenamento INTO armazenamento_id
    FROM Armazenamento
    WHERE capacidade_utilizada + quantidade <= capacidade_maxima
    ORDER BY capacidade_utilizada ASC
    LIMIT 1;

    -- Atualiza a tabela Produto com o armazenamento encontrado
    IF armazenamento_id IS NOT NULL THEN
        UPDATE Produto
        SET id_armazenamento = armazenamento_id
        WHERE id_produto = produto_id;

        -- Atualiza a capacidade utilizada no armazenamento
        UPDATE Armazenamento
        SET capacidade_utilizada = capacidade_utilizada + quantidade
        WHERE id_armazenamento = armazenamento_id;
    END IF;
END;

//

DELIMITER ;

CALL AlocaProduto(1, 50);


SHOW PROCEDURE STATUS WHERE Name IN ('AtualizarEstoque', 'AlocarProduto');

DROP PROCEDURE IF EXISTS AtualizarEstoque;
DROP PROCEDURE IF EXISTS AlocarProduto;

DELIMITER $$

CREATE PROCEDURE AtualizarEstoque(IN pedido_id INT)
BEGIN
    DECLARE produto_id INT;
    DECLARE qtd INT;
    DECLARE done INT DEFAULT 0;

    -- Cursor para percorrer todos os produtos do pedido
    DECLARE cur CURSOR FOR
        SELECT id_produto, quantidade FROM PedidoProduto WHERE id_pedido = pedido_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO produto_id, qtd;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Atualizar estoque
        UPDATE Produto 
        SET quantidade_estoque = quantidade_estoque - qtd 
        WHERE id_produto = produto_id;
    END LOOP;

    CLOSE cur;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE AlocarProduto(IN produto_id INT, IN quantidade INT)
BEGIN
    DECLARE local_disponivel INT DEFAULT NULL;

    -- Encontrar um local de armazenamento com espaço disponível
    SELECT id_armazenamento INTO local_disponivel
    FROM Armazenamento
    WHERE (capacidade_total - capacidade_utilizada) >= quantidade
    ORDER BY capacidade_utilizada ASC
    LIMIT 1;

    -- Verificar se um local foi encontrado
    IF local_disponivel IS NOT NULL THEN
        -- Atualizar localização do produto
        UPDATE Produto
        SET id_armazenamento = local_disponivel
        WHERE id_produto = produto_id;

        -- Atualizar capacidade utilizada
        UPDATE Armazenamento
        SET capacidade_utilizada = capacidade_utilizada + quantidade
        WHERE id_armazenamento = local_disponivel;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nenhum espaço disponível para armazenar o produto!';
    END IF;
END $$

DELIMITER ;

SHOW PROCEDURE STATUS WHERE Name IN ('AtualizarEstoque', 'AlocarProduto');

SHOW CREATE TABLE PedidoProduto;

ALTER TABLE Pedido MODIFY COLUMN data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE Pedido MODIFY COLUMN valor_total DECIMAL(10,2) DEFAULT 0.00;

INSERT INTO Pedido (id_cliente, status_pedido) VALUES (1, 'Em andamento');

DROP PROCEDURE IF EXISTS AtualizaEstoque;

DELIMITER //

CREATE PROCEDURE AtualizaEstoque(IN produto_id INT, IN quantidade INT)
BEGIN
    -- Previne valores negativos no estoque
    IF (SELECT quantidade_estoque FROM Produto WHERE id_produto = produto_id) >= quantidade THEN
        UPDATE Produto
        SET quantidade_estoque = quantidade_estoque - quantidade
        WHERE id_produto = produto_id;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Erro: Estoque insuficiente!';
    END IF;
END;

//

DELIMITER ;


DROP PROCEDURE IF EXISTS AlocaProduto;

DELIMITER //

CREATE PROCEDURE AlocaProduto(IN produto_id INT, IN quantidade INT)
BEGIN
    DECLARE armazenamento_id INT DEFAULT NULL;

    -- Encontrar um local de armazenamento com espaço suficiente
    SELECT id_armazenamento INTO armazenamento_id
    FROM Armazenamento
    WHERE capacidade_utilizada + quantidade <= capacidade_maxima
    ORDER BY capacidade_utilizada ASC
    LIMIT 1;

    -- Verificar se um local disponível foi encontrado
    IF armazenamento_id IS NOT NULL THEN
        -- Atualiza o local do produto
        UPDATE Produto
        SET id_armazenamento = armazenamento_id
        WHERE id_produto = produto_id;

        -- Atualiza a capacidade utilizada no armazenamento
        UPDATE Armazenamento
        SET capacidade_utilizada = capacidade_utilizada + quantidade
        WHERE id_armazenamento = armazenamento_id;
    ELSE
        -- Retorna um erro caso nenhum espaço esteja disponível
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: Nenhum espaço disponível para armazenar o produto!';
    END IF;
END;

//

DELIMITER ;
*/
use logiware;
SHOW TABLES;
SHOW CREATE TABLE armazenamento;
/*
CREATE TABLE `armazenamento` (
   `id_armazenamento` int(11) NOT NULL AUTO_INCREMENT,
   `capacidade_total` int(11) NOT NULL,
   `capacidade_utilizada` int(11) NOT NULL,
   PRIMARY KEY (`id_armazenamento`)
 ) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1
 */
SHOW CREATE TABLE categoria;
/*
'categoria', 'CREATE TABLE `categoria` (\n  `id_categoria` int(11) NOT NULL AUTO_INCREMENT,\n  `nome` varchar(100) NOT NULL,\n  PRIMARY KEY (`id_categoria`),\n  UNIQUE KEY `nome` (`nome`)\n) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1'
*/
SHOW CREATE TABLE cliente;
/*
CREATE TABLE `cliente` (
   `id_cliente` int(11) NOT NULL AUTO_INCREMENT,
   `nome` varchar(255) NOT NULL,
   `email` varchar(100) DEFAULT NULL,
   `telefone` varchar(20) DEFAULT NULL,
   `endereco` varchar(255) DEFAULT NULL,
   PRIMARY KEY (`id_cliente`),
   UNIQUE KEY `email` (`email`)
 ) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1
 */
SHOW CREATE TABLE fornecedor;
/*
CREATE TABLE `fornecedor` (
   `id_fornecedor` int(11) NOT NULL AUTO_INCREMENT,
   `nome` varchar(100) NOT NULL,
   `contato` varchar(100) NOT NULL,
   PRIMARY KEY (`id_fornecedor`)
 ) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1
 */
SHOW CREATE TABLE fornecedorproduto;
/*
CREATE TABLE `fornecedorproduto` (
   `id_fornecedor` int(11) DEFAULT NULL,
   `id_produto` int(11) DEFAULT NULL,
   KEY `id_fornecedor` (`id_fornecedor`),
   KEY `id_produto` (`id_produto`),
   CONSTRAINT `fornecedorproduto_ibfk_1` FOREIGN KEY (`id_fornecedor`) REFERENCES `fornecedor` (`id_fornecedor`),
   CONSTRAINT `fornecedorproduto_ibfk_2` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`)
 ) ENGINE=InnoDB DEFAULT CHARSET=latin1
 */
SHOW CREATE TABLE historicomovimentacao;
/*
CREATE TABLE `historicomovimentacao` (
   `id_movimentacao` int(11) NOT NULL AUTO_INCREMENT,
   `id_produto` int(11) DEFAULT NULL,
   `tipo_movimentacao` enum('entrada','saida') DEFAULT NULL,
   `quantidade` int(11) DEFAULT NULL,
   `data_movimentacao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
   PRIMARY KEY (`id_movimentacao`),
   KEY `id_produto` (`id_produto`),
   CONSTRAINT `historicomovimentacao_ibfk_1` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`)
 ) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1
 */
SHOW CREATE TABLE pedido;
/*
CREATE TABLE `pedido` (
   `id_pedido` int(11) NOT NULL AUTO_INCREMENT,
   `data_pedido` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
   `status_pedido` varchar(50) NOT NULL,
   `id_transportadora` int(11) DEFAULT NULL,
   `id_cliente` int(11) DEFAULT NULL,
   `valor_total` decimal(10,2) DEFAULT '0.00',
   PRIMARY KEY (`id_pedido`),
   KEY `id_transportadora` (`id_transportadora`),
   CONSTRAINT `pedido_ibfk_1` FOREIGN KEY (`id_transportadora`) REFERENCES `transportadora` (`id_transportadora`)
 ) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1
 */
SHOW CREATE TABLE pedidoproduto;
/*
CREATE TABLE `pedidoproduto` (
   `id_pedido` int(11) DEFAULT NULL,
   `id_produto` int(11) DEFAULT NULL,
   `quantidade` int(11) DEFAULT NULL,
   KEY `id_pedido` (`id_pedido`),
   KEY `id_produto` (`id_produto`),
   CONSTRAINT `pedidoproduto_ibfk_1` FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`id_pedido`),
   CONSTRAINT `pedidoproduto_ibfk_2` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`)
 ) ENGINE=InnoDB DEFAULT CHARSET=latin1
 */
SHOW CREATE TABLE produto;
/*
CREATE TABLE `produto` (
   `id_produto` int(11) NOT NULL AUTO_INCREMENT,
   `descricao` varchar(255) NOT NULL,
   `quantidade_estoque` int(11) NOT NULL,
   `id_armazenamento` int(11) DEFAULT NULL,
   `id_categoria` int(11) DEFAULT NULL,
   PRIMARY KEY (`id_produto`),
   KEY `id_armazenamento` (`id_armazenamento`),
   KEY `fk_categoria` (`id_categoria`),
   CONSTRAINT `fk_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE SET NULL,
   CONSTRAINT `produto_ibfk_1` FOREIGN KEY (`id_armazenamento`) REFERENCES `armazenamento` (`id_armazenamento`),
   CONSTRAINT `produto_ibfk_2` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`)
 ) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=latin1
 */
SHOW CREATE TABLE rastreamento;
/*
CREATE TABLE `rastreamento` (
   `id_rastreamento` int(11) NOT NULL AUTO_INCREMENT,
   `id_pedido` int(11) DEFAULT NULL,
   `id_produto` int(11) DEFAULT NULL,
   `status` varchar(50) DEFAULT NULL,
   `localizacao_atual` varchar(255) DEFAULT NULL,
   `data_atualizacao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
   PRIMARY KEY (`id_rastreamento`),
   KEY `id_pedido` (`id_pedido`),
   KEY `id_produto` (`id_produto`),
   CONSTRAINT `rastreamento_ibfk_1` FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`id_pedido`),
   CONSTRAINT `rastreamento_ibfk_2` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`)
 ) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1
 */
SHOW CREATE TABLE transportadora;
/*
CREATE TABLE `transportadora` (
   `id_transportadora` int(11) NOT NULL AUTO_INCREMENT,
   `nome` varchar(100) NOT NULL,
   `contato` varchar(100) NOT NULL,
   PRIMARY KEY (`id_transportadora`)
 ) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1
 */
 
ALTER TABLE armazenamento ADD COLUMN fk_id_produto INT;
ALTER TABLE armazenamento ADD FOREIGN KEY (fk_id_produto) REFERENCES produto(id_produto);
ALTER TABLE pedido ADD CONSTRAINT fk_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);

SELECT table_name, constraint_name, referenced_table_name
FROM information_schema.key_column_usage
WHERE table_schema = 'logiware';

INSERT INTO cliente (nome, email, telefone, endereco) VALUES ('Teste', 'teste@email.com', '11999999999', 'Rua X, SP');
SELECT * FROM cliente;

SELECT table_name, constraint_name, referenced_table_name, update_rule, delete_rule
FROM information_schema.referential_constraints
WHERE constraint_schema = 'logiware';
/*
3	37	18:05:09	SELECT table_name, constraint_name, referenced_table_name, update_rule, delete_rule
 FROM information_schema.referential_constraints
 WHERE constraint_schema = 'logiware'
 LIMIT 0, 1000	13 row(s) returned	0.000 sec / 0.000 sec
 */
 
INSERT INTO pedido (status_pedido, valor_total) VALUES ('Em andamento', 150.00);
SELECT * FROM pedido ORDER BY id_pedido DESC;
/*
3	38	18:06:01	INSERT INTO pedido (status_pedido, valor_total) VALUES ('Em andamento', 150.00)	1 row(s) affected	0.000 sec
*/

DELETE FROM pedido WHERE id_pedido = 92;
/*
18:06:55	DELETE FROM pedido WHERE id_pedido = 92	0 row(s) affected	0.000 sec
*/
SELECT * FROM pedido WHERE id_pedido = 1;
/*
3	43	18:08:46	SELECT * FROM pedido WHERE id_pedido = 1
 LIMIT 0, 1000	1 row(s) returned	0.000 sec / 0.000 sec
 */

DELETE FROM pedido WHERE id_pedido = 1;
/*
0	44	18:09:26	DELETE FROM pedido WHERE id_pedido = 1	Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`logiware`.`pedidoproduto`, CONSTRAINT `pedidoproduto_ibfk_1` FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`id_pedido`))	0.000 sec
*/
DELETE FROM pedidoproduto WHERE id_pedido = 1;
/*
3	45	18:11:43	DELETE FROM pedidoproduto WHERE id_pedido = 1	4 row(s) affected	0.000 sec
*/
DELETE FROM pedido WHERE id_pedido = 1;
/*
0	46	18:12:00	DELETE FROM pedido WHERE id_pedido = 1	Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`logiware`.`rastreamento`, CONSTRAINT `rastreamento_ibfk_1` FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`id_pedido`))	0.000 sec
*/

ALTER TABLE pedidoproduto DROP FOREIGN KEY pedidoproduto_ibfk_1;
ALTER TABLE pedidoproduto ADD CONSTRAINT pedidoproduto_ibfk_1 FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE;
/*0	47	18:12:30	ALTER TABLE pedidoproduto ADD CONSTRAINT pedidoproduto_ibfk_1 FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE	Error Code: 1022. Can't write; duplicate key in table '#sql-1210_49'	0.000 sec
*/

DELETE FROM rastreamento WHERE id_pedido = 1;

DELETE FROM pedido WHERE id_pedido = 1;
















