
SELECT @@VERSION
--***************************************************--

CREATE DATABASE TESTE
GO
USE TESTE
GO
CREATE TABLE tb_cliente 
	(id INT IDENTITY PRIMARY KEY,
	nome VARCHAR(100),
	endereco VARCHAR(150))
GO
INSERT INTO tb_cliente VALUES	('Walisson Alkmim','Av. Visc. de Rio Claro, s/n - Centro, Rio Claro - SP, 13500-505'),
								('Vito Andolini','	Via degli Uffizi, 1, 56100 Pise Italia')
GO
SELECT * FROM tb_cliente
GO

--***************************************************--

CREATE PROC pr_teste
AS
BEGIN 
	SELECT * FROM tb_cliente
END

--***************************************************--

SELECT * FROM SYS.DATABASES;

--ALTER DATABASE [TESTE] SET RECOVERY SIMPLE ;  
--SELECT * FROM SYS.SYSPROCESSES
GO

--***************************************************--

CREATE SCHEMA sales
