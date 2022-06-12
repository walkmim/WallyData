
SELECT VERSION();

INSERT INTO tb_cliente (nome,endereco) VALUES ('Fabricio Fonseca','Rua Vitoria, 168, Salvador - BA');
INSERT INTO tb_cliente (nome,endereco) VALUES ('Fabiano Almeida','Rua xpto, 450, Sao Paulo - SP');

SELECT * FROM tb_cliente

SELECT * FROM pg_database;
SELECT * FROM pg_catalog.pg_namespace;
SELECT * FROM pg_catalog.pg_tables where tablename = 'tb_cliente';

