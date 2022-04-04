CREATE DATABASE campeonato
GO
USE campeonato


CREATE TABLE Times(
	CodigoTime		INT	PRIMARY KEY		IDENTITY,
	NomeTime		VARCHAR(30)			NOT NULL,
	Cidade			VARCHAR(30)			NOT NULL,
	Estadio			VARCHAR(30)			NOT NULL
)

INSERT INTO Times VALUES('Botafogo-SP','Ribeirão Preto','Santa Cruz')
INSERT INTO Times VALUES('Corinthians','São Paulo','Arena Corinthians')
INSERT INTO Times VALUES('Ferroviária','Araraquara','Fonte Luminosa')
INSERT INTO Times VALUES('Guarani','Campinas','Brinco de Ouro da Princesa')
INSERT INTO Times VALUES('Inter de Limeira','Limeira','Limeirão')
INSERT INTO Times VALUES('Ituano','Itu','Novelli Júnior')
INSERT INTO Times VALUES('Mirassol','Mirassol','Jóse Maria de Campos Maia')
INSERT INTO Times VALUES('Novorizontino','Novo Horizonte','Jorge Ismael de Biasi')
INSERT INTO Times VALUES('Palmeiras','São Paulo','Allianz Parque')
INSERT INTO Times VALUES('Ponte Preta','Campinas','Moisés Lucarelli')
INSERT INTO Times VALUES('Red Bull Bragantino','Campinas','Moisés Lucarelli')
INSERT INTO Times VALUES('Santo André','Santo André','Bruno José Daniel')
INSERT INTO Times VALUES('Santos','Santos','Vila Belmiro')
INSERT INTO Times VALUES('São Bento','Sorocaba','Walter Ribeiro')
INSERT INTO Times VALUES('São Caetano','São Caetano do Sul','Anacletto Campenella')
INSERT INTO Times VALUES('São Paulo','São Paulo','Morumbi')


CREATE TABLE Grupos(
	Grupo			VARCHAR(1) CHECK (Grupo IN ('A','B','C','D')),
	Codigo_Time		INT
PRIMARY KEY (Grupo, Codigo_Time)
)	

CREATE TABLE Jogos(
	CodigoTimeA		INT,
	CodigoTimeB		INT,
	GolsTimeA		INT,
	GolsTimeB		INT,
	DataJogo		DATE	CHECK(DataJogo BETWEEN '2021-02-27' and '2021-05-23')	
PRIMARY KEY (CodigoTimeA, CodigoTimeB)
)

ALTER TABLE Grupos ADD CONSTRAINT FK_Grupos_Times
FOREIGN KEY(Codigo_Time) REFERENCES Times(CodigoTime)

ALTER TABLE Jogos ADD CONSTRAINT FK_Jogos_TimesA
FOREIGN KEY(CodigoTimeA) REFERENCES Times(CodigoTime)

ALTER TABLE Jogos ADD CONSTRAINT FK_Jogos_TimesB
FOREIGN KEY(CodigoTimeB) REFERENCES Times(CodigoTime)
GO


CREATE PROC sp_gerarGrupos
AS
    DECLARE @random INT, 
            @secundarios AS VARCHAR(16),
            @principais AS VARCHAR (4),
            @grupo AS CHAR(1),
            @time AS VARCHAR(16),
            @count AS INT,
            @aux AS CHAR(1)

	
    SET @secundarios = 'AAABBBCCCDDD'
    SET @principais = 'ABCD'

    SET @count = 1

    WHILE (@count <= 16) 
    BEGIN 
		IF ((@count = 3) OR (@count = 16) OR (@count = 10) OR (@count = 13)) 
        BEGIN 
            SET @time = @principais
            SET @aux = 'p'
        END 
		
        ELSE
        BEGIN 
            SET @time = @secundarios
            SET @aux = 's'
        END  

        SET @random = FLOOR(RAND()*(LEN(@time))+1)
        
		SET @grupo = SUBSTRING(@time, @random, 1)

	
        SET @time = STUFF(@time, PATINDEX('%' + @grupo + '%', @time), LEN(@grupo), '')

		 
        IF (@aux = 's')
        BEGIN 
            SET @secundarios = @time 
        END 
        ELSE 
        BEGIN
            SET @principais = @time
        END  

		
        INSERT INTO Grupos VALUES (@grupo, @count)

		
        SET @count = @count + 1 

        END 
GO



CREATE PROC sp_gerarJogos
AS
	DECLARE @dia_de_hoje AS DATE, 
			@dia_final AS DATE,
			@contador AS INT,
			@codigo AS INT,
			@codigoAdv AS INT,
			@times_jogados AS INT,
			@adversario AS INT,
			@jogou AS INT,
			@id_time AS INT, 
			@mesmoGrupo AS INT 
	
	
	SET @dia_de_hoje = '2021-02-27'
	SET @dia_final = '2021-05-23'

	
	WHILE (@dia_de_hoje < @dia_final)
	BEGIN 
		
		IF ((DATEPART(WEEKDAY, @dia_de_hoje) = 1) OR (DATEPART(WEEKDAY, @dia_de_hoje) = 4))
		BEGIN 

			SET @times_jogados = 1

			
			WHILE (@times_jogados <= 16 )
			BEGIN 

				
	            SET @id_time = @times_jogados

				
				SET @codigo = NULL
				SET @codigo = (SELECT j.CodigoTimeA 
				               FROM Jogos AS j 
							   WHERE ((@id_time = j.CodigoTimeA OR 
									 @id_time = j.CodigoTimeB) AND
									 @dia_de_hoje = j.DataJogo))

				 
				IF (@codigo IS NULL)
				BEGIN
					SET @jogou = 0
					SET @contador = 1
					SET @adversario = 0

					
					WHILE ((@jogou = 0) AND (@contador < 16))
					BEGIN 
						
						
						SET @adversario = @id_time + @contador 
						IF (@adversario > 16)
						BEGIN
							SET @adversario = @adversario - 16
						END 

						
						SET @codigoAdv = NULL
						SET @codigoAdv = (SELECT j.CodigoTimeA 
										  FROM Jogos AS j 
										  WHERE ((@adversario = j.CodigoTimeA OR 
												 @adversario = j.CodigoTimeB) AND
												 @dia_de_hoje = j.DataJogo))

										
						SET @codigo = NULL
						SET @codigo = (SELECT j.CodigoTimeA
									   FROM Jogos AS J 
									   WHERE (j.CodigoTimeA = @id_time AND j.CodigoTimeB = @adversario) OR 
											 (j.CodigoTimeA = @adversario AND j.CodigoTimeB = @id_time))

											
						SET @mesmoGrupo = NULL
						SET @mesmoGrupo = (SELECT g1.Codigo_Time
										   FROM Grupos g1, Grupos g2
									       WHERE g1.Grupo != g2.Grupo
											 AND g1.Codigo_Time = @id_time
											 AND g2.Codigo_Time = @adversario)
						
						
						IF ((@codigo IS NOT NULL) OR (@codigoAdv IS NOT NULL) or (@id_time = @adversario) OR (@mesmoGrupo IS NULL))
						BEGIN 
							SET @contador = @contador + 1
						END 

						 
						ELSE 
						BEGIN 
							SET @jogou = 1; 
							INSERT INTO Jogos VALUES (@id_time, @adversario, NULL, NULL, @dia_de_hoje)
						END 
					END 
				END
				SET @times_jogados = @times_jogados + 1 	
			END 
		END 

		SET @dia_de_hoje = DATEADD(DAY, 1, @dia_de_hoje)

	END 
GO


CREATE FUNCTION fn_gerarTabelaGrupo(@grupo AS CHAR(1))
RETURNS @table TABLE (
cod_time	INT,
nome_time	VARCHAR(100)
)
AS
BEGIN

	INSERT INTO @table 
		SELECT t.CodigoTime, t.NomeTime
		FROM Grupos g, Times t
		WHERE t.CodigoTime = g.Codigo_Time
			AND Grupo = @grupo

	RETURN 
END 
GO



CREATE FUNCTION fn_consultarData (@verfData DATE)
RETURNS @table TABLE (
nome_timeA	VARCHAR(100),
nome_timeB	VARCHAR(100)
)
AS
BEGIN 
	INSERT INTO @table 
		SELECT ta.nomeTime, tb.NomeTime
		FROM Jogos j, Times ta, Times tb
		WHERE ta.CodigoTime = j.CodigoTimeA
			AND tb.CodigoTime = j.CodigoTimeB
			AND j.DataJogo = @verfData
	RETURN 
END 
GO 


SELECT g.Grupo, t.NomeTime
FROM Grupos g
INNER JOIN Times t
ON t.CodigoTime = g.Codigo_Time

SELECT * FROM Jogos ORDER BY CodigoTimeA
SELECT * FROM Times 



EXEC sp_gerarGrupos
EXEC sp_gerarJogos


SELECT * FROM fn_gerarTabelaGrupo('A')
SELECT * FROM fn_gerarTabelaGrupo('B')
SELECT * FROM fn_gerarTabelaGrupo('C')
SELECT * FROM fn_gerarTabelaGrupo('D')

SELECT * FROM fn_consultarData('2021-02-27')	


TRUNCATE TABLE Jogos 
TRUNCATE TABLE Grupos
