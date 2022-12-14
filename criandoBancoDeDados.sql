--MINI ERP
--USE MASTER
--DROP DATABASE MINIERP_MULT
--GO

USE MINIERP_MULT

CREATE DATABASE MINIERP_MULT
GO
USE MINIERP_MULT

--CADASTROS COMPLEMENTARES POR AREA
--CRIANDO TABELAS SEM DEPENDENCIAS/DEPENDENTES

--CREATE TABLE EMPRESA
CREATE TABLE EMPRESA
	(COD_EMPRESA INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
		NOME_EMPRESA VARCHAR(50),
		FANTASIA VARCHAR(20)
		);

		--Uma chave primária é um campo ou conjunto de campos com valores exclusivos por toda a tabela. 
		--Os valores da chave podem ser usados para se referir aos registros inteiros,
		--porque cada registro tem um valor diferente para a chave. 
		--Cada tabela só pode ter uma chave primária.

--TABELAS UNIDADE FEDERAL
--DROP TABLE UF
CREATE TABLE UF
(
	COD_UF VARCHAR(2) NOT NULL PRIMARY KEY,
	NOME_UF VARCHAR(30) NOT NULL,
);


--TABELAS CIDADES
CREATE TABLE CIDADES
	(
	COD_CIDADE VARCHAR(7) NOT NULL PRIMARY KEY,
	COD_UF VARCHAR(2) NOT NULL,
	NOME_MUN VARCHAR(50) NOT NULL,
	CONSTRAINT FK_CID1 FOREIGN KEY (COD_UF) REFERENCES UF (COD_UF)
	)

	-- CONSTRAINT: As restrições são usadas para limitar o tipo de dados que podem entrar em uma tabela.
	-- FOREIGN KEY: Impede ações que destruiriam links entre tabelas. A FOREIGN KEYé um campo (ou coleção de campos) 
	-- em uma tabela, que se refere a PRIMARY KEY em outra tabela.

--CRIANDO TABELAS CLIENTES
CREATE TABLE CLIENTES
	(
	COD_EMPRESA INT NOT NULL,
	ID_CLIENTE INT IDENTITY(1,1) NOT NULL, --1,1 para se auto numerar
	RAZAO_CLIENTE VARCHAR(100)NOT NULL,
	FANTASIA VARCHAR(15) NOT NULL,
	ENDERECO VARCHAR(50) NOT NULL,
	NRO VARCHAR(10) NOT NULL,
	BAIRRO VARCHAR(20) NOT NULL,
	COD_CIDADE VARCHAR(7) NOT NULL,
	CEP VARCHAR(8),
	CNPJ_CPF VARCHAR(15),
	TIPO_CLIENTE NCHAR(1) CONSTRAINT CK_TC1 CHECK (TIPO_CLIENTE in ('F', 'J')), --Só aceitará duas entradas, "física" ou "jurídica"
	DATA_CADASTRO DATETIME NOT NULL,
	COD_PGTO INT,
	CONSTRAINT PK_CLI1 PRIMARY KEY (COD_EMPRESA,ID_CLIENTE), --Chave primária composta
	CONSTRAINT FK_CLIT FOREIGN KEY (COD_CIDADE)
	REFERENCES CIDADES(COD_CIDADE),
	CONSTRAINT FK_CLI2 FOREIGN KEY (COD_EMPRESA)
	REFERENCES EMPRESA (COD_EMPRESA)
	)

-- CRIANDO TABELA DE FORNECEDORES
CREATE TABLE FORNECEDORES
	(
	COD_EMPRESA INT NOT NULL,
	ID_FOR INT IDENTITY(1,1),
	RAZAO_FORNEC VARCHAR(100) NOT NULL,
	FANTASIA VARCHAR(15) NOT NULL,
	ENDERECO VARCHAR(50) NOT NULL,
	NRO VARCHAR(10) NOT NULL,
	BAIRRO VARCHAR(20) NOT NULL,
	COD_CIDADE VARCHAR(7) NOT NULL,
	CEP VARCHAR(8),
	CNPJ_CPF VARCHAR(15),
	TIPO_FORNEC NCHAR(1) CONSTRAINT CK_TF1 CHECK (TIPO_FORNEC IN ('F', 'J')),
	DATA_CADASTRO DATETIME NOT NULL,
	COD_PAGTO INT,
	CONSTRAINT PK_FOR1 PRIMARY KEY (COD_EMPRESA,ID_FOR),
	CONSTRAINT FK_FOR1 FOREIGN KEY (COD_CIDADE)
	REFERENCES CIDADES (COD_CIDADE),
	CONSTRAINT FK_FOR2 FOREIGN KEY (COD_EMPRESA)
	REFERENCES EMPRESA (COD_EMPRESA)
	);

	--VERIFICANDO
	SELECT * FROM FORNECEDORES

--TABELAS TIPO DE MATERIAL
CREATE TABLE TIPO_MAT
	(
	COD_EMPRESA INT NOT NULL,
	COD_TIP_MAT INT NOT NULL,
	DESC_TIP_MAT VARCHAR(20) NOT NULL,
	CONSTRAINT PK_TIP_M1 PRIMARY KEY (COD_EMPRESA, COD_TIP_MAT),
	CONSTRAINT FK_TIP_M1 FOREIGN KEY (COD_EMPRESA)
	REFERENCES EMPRESA(COD_EMPRESA)
	);

--CRIANDO TABELAS MATERIAL
CREATE TABLE MATERIAL
	(
	COD_EMPRESA INT NOT NULL,
	COD_MAT INT NOT NULL,
	DESCRICAO VARCHAR(50) NOT NULL,
	PRECO_UNIT DECIMAL(10,2) NOT NULL,
	COD_TIP_MAT INT NOT NULL,
	ID_FOR INT,
	CONSTRAINT PK_MAT1 PRIMARY KEY (COD_EMPRESA,COD_MAT),
	CONSTRAINT FK_MAT1 FOREIGN KEY (COD_EMPRESA,COD_TIP_MAT)
	REFERENCES TIPO_MAT(COD_EMPRESA, COD_TIP_MAT)
	/*CONSTRAINT FK_MAT2 FOREIGN KEY (COD_EMPRESA,ID_FOR)
	REFERENCES FORNECEDORES(COD_EMPRESA,ID_FOR)
	*/
	--ALTER TABLE MATERIAL DROP CONSTRAINT FK_MAT2
	)

--CRIANDO INDEX
CREATE INDEX IX_MAT ON MATERIAL (COD_EMPRESA, COD_TIP_MAT)
		--Chaves primárias automaticamente criam índices para a posição

--PRODUCAO
--DROP TABLE ONDEM_PROD
CREATE TABLE ORDEM_PROD
	(
	COD_EMPRESA INT NOT NULL,
	ID_ORDEM INT IDENTITY(1,1) NOT NULL,
	COD_MAT_PROD INT NOT NULL,
	QTD_PLAN DECIMAL(10,2) NOT NULL,
	QTD_PROD DECIMAL(10,2) NOT NULL,
	DATA_INI DATE,
	DATA_FIM DATE,
	SITUACAO CHAR(1), --A-ABERTA, P-PLANEJADA, -F-FECHADA
	CONSTRAINT PK_OP1 PRIMARY KEY (COD_EMPRESA,ID_ORDEM),
	CONSTRAINT FK_OP1 FOREIGN KEY (COD_EMPRESA,COD_MAT_PROD)
	REFERENCES MATERIAL(COD_EMPRESA,COD_MAT),
	);

--CRIACAO DE TABELAS APONTAMENTO DE PRODUÇÃO
--DROP TABLE APONTAMENTOS
CREATE TABLE APONTAMENTOS
	(
	COD_EMPRESA INT NOT NULL,
	ID_APON INT IDENTITY(1,1) NOT NULL,
	ID_ORDEM INT NOT NULL,
	COD_MAT_PROD INT,
	QTD_APON DECIMAL(10,2),
	DATA_APON DATETIME NOT NULL,
	--CAMPO LOTE CRIADO NO FINAL
	--O LOGIN SERÁ CRIADO APÓS CRIAÇÃO DA TABELA DE USUÁRIOS
	CONSTRAINT FK_APON1 FOREIGN KEY (COD_EMPRESA,COD_MAT_PROD)
	REFERENCES MATERIAL (COD_EMPRESA, COD_MAT),
	CONSTRAINT FK_APON2 FOREIGN KEY (COD_EMPRESA,ID_ORDEM)
	REFERENCES ORDEM_PROD(COD_EMPRESA,ID_ORDEM),
	CONSTRAINT PK_APON1 PRIMARY KEY(COD_EMPRESA,ID_APON)
	);

--CRIAÇÃO DA TABELA FICHA TÉCNICA
CREATE TABLE FICHA_TECNICA
(
	COD_EMPRESA INT NOT NULL,
	ID_REF INT IDENTITY NOT NULL PRIMARY KEY,
	COD_MAT_PROD INT NOT NULL,
	COD_MAT_NECES INT NOT NULL,
	QTD_NECES DECIMAL(10,2) NOT NULL,
	CONSTRAINT FK_FIC1 FOREIGN KEY (COD_EMPRESA, COD_MAT_PROD)
	REFERENCES MATERIAL(COD_EMPRESA, COD_MAT),
	CONSTRAINT FK_FIC2 FOREIGN KEY (COD_EMPRESA, COD_MAT_NECES)
	REFERENCES MATERIAL (COD_EMPRESA, COD_MAT)
);

--CRIAÇÃO DA TABELA CONSUMO
--DROP TABLE CONSUMO
CREATE TABLE CONSUMO
(
	COD_EMPRESA INT NOT NULL,
	ID_APON INT NOT NULL,
	COD_MAT_NECES INT NOT NULL,
	QTD_CONSUMIDA DECIMAL(10,2) NOT NULL,
	LOTE VARCHAR(20) NOT NULL,
	CONSTRAINT FK_CONS1 FOREIGN KEY (COD_EMPRESA, COD_MAT_NECES)
	REFERENCES MATERIAL (COD_EMPRESA, COD_MAT),
	CONSTRAINT FK_CONS2 FOREIGN KEY (COD_EMPRESA,ID_APON)
	REFERENCES APONTAMENTOS(COD_EMPRESA,ID_APON)
);

--SUPRIMENTOS
--CRIAÇÃO DA TABELA
CREATE TABLE ESTOQUE
	(
	COD_EMPRESA INT NOT NULL,
	COD_MAT INT NOT NULL,
	QTD_SALDO DECIMAL(10,2) NOT NULL,
	CONSTRAINT FK_EST1 FOREIGN KEY (COD_EMPRESA,COD_MAT)
	REFERENCES MATERIAL(COD_EMPRESA,COD_MAT),
	CONSTRAINT PK_EST1 PRIMARY KEY (COD_EMPRESA,COD_MAT)
	);

--DROP TABLE ESTOQUE_LOTE
--CRIAÇÃO TABELAS ESTOQUE_LOTE
CREATE TABLE ESTOQUE_LOTE
(
	COD_EMPRESA INT NOT NULL,
	COD_MAT INT NOT NULL,
	LOTE VARCHAR(20) NOT NULL,
	QTD_LOTE DECIMAL(10,2) NOT NULL,
	CONSTRAINT PK_ESTL1 PRIMARY KEY (COD_EMPRESA,COD_MAT,LOTE), --PK COMPOSTA
	CONSTRAINT FK_ESTL1 FOREIGN KEY (COD_EMPRESA,COD_MAT)
	REFERENCES MATERIAL(COD_EMPRESA,COD_MAT)
)

--CRIAÇÃO TABLE MOV ESTOQUE
--DROP TABLE ESTOQUE_MOV
CREATE TABLE ESTOQUE_MOV
(
	COD_EMPRESA INT NOT NULL,
	ID_MOVE INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	TIP_MOV VARCHAR(1), --S=SAÍDA, E=ENTRADA
	COD_MAT INT NOT NULL,
	LOTE VARCHAR(20) NOT NULL,
	QTD DECIMAL(10,2) NOT NULL,
	DATA_MOVE DATE NOT NULL,
	DATA_HORA DATETIME NOT NULL,
	CONSTRAINT FK_ESTM1 FOREIGN KEY(COD_EMPRESA,COD_MAT)
	REFERENCES MATERIAL(COD_EMPRESA,COD_MAT)
	--CAMPO LOGIN TABELA ESTOQUE_MOV CRIAÇÃO APÓS TABELA USUÁRIO
)

--CRIAÇÃO TABELAS PED_COMPRAS
--DROP TABLE PRED_COMPRAS
CREATE TABLE PED_COMPRAS
(
	COD_EMPRESA INT NOT NULL,
	NUM_PEDIDO INT NOT NULL,
	ID_FOR INT NOT NULL,
	COD_PGTO INT NOT NULL, --ALTERAR COD_PAGTO TAB PED_COMPRAS PARA FOREIGN KEY APOS TABELA COND_PAGTO
	DATA_PEDIDO DATE NOT NULL,
	DATA_ENTREGA DATE NOT NULL,
	SITUACAO NCHAR(1) NOT NULL,
	TOTAL_PED DECIMAL(10,2),
	CONSTRAINT FK_PEDC1 FOREIGN KEY (COD_EMPRESA,ID_FOR)
	REFERENCES FORNECEDORES(COD_EMPRESA,ID_FOR),
	CONSTRAINT PK_PEDC1 PRIMARY KEY (COD_EMPRESA,NUM_PEDIDO)
);

--CRIAÇÃO DA TABELA PEDIDO DE COMPRAS
CREATE TABLE PED_COMPRAS_ITENS
(
	COD_EMPRESA INT NOT NULL,
	NUM_PEDIDO INT NOT NULL,
	SEQ_MAT INT NOT NULL,
	COD_MAT INT NOT NULL,
	QTD INT NOT NULL,
	VAL_UNIT DECIMAL(10,2) NOT NULL,
	CONSTRAINT PK_PEDCIT1 PRIMARY KEY (COD_EMPRESA,NUM_PEDIDO,SEQ_MAT),
	CONSTRAINT FK_PEDIT1 FOREIGN KEY (COD_EMPRESA,NUM_PEDIDO)
	REFERENCES PED_COMPRAS (COD_EMPRESA,NUM_PEDIDO),
	CONSTRAINT FK_PEDIT2 FOREIGN KEY(COD_EMPRESA,COD_MAT)
	REFERENCES MATERIAL(COD_EMPRESA,COD_MAT)
)

--RH
--CRIAÇÃO TABELAS CENTRO DE CUSTO
CREATE TABLE CENTRO_CUSTO
(
	COD_EMPRESA INT NOT NULL,
	COD_CC VARCHAR(4) NOT NULL,
	NOME_CC VARCHAR(20) NOT NULL,
	CONSTRAINT PK_CC1 PRIMARY KEY(COD_EMPRESA, COD_CC),
	CONSTRAINT FK_CC1 FOREIGN KEY(COD_EMPRESA)
	REFERENCES EMPRESA(COD_EMPRESA)
);

--CRIAÇÃO TABELAS CARGOS
CREATE TABLE CARGOS
(
	COD_EMPRESA INT NOT NULL,
	COD_CARGO INT IDENTITY(1,1) NOT NULL,
	NOME_CARGO VARCHAR(50),
	CONSTRAINT PK_CARG1 PRIMARY KEY (COD_EMPRESA,COD_CARGO),
	CONSTRAINT FK_CARG1 FOREIGN KEY (COD_EMPRESA)
	REFERENCES EMPRESA(COD_EMPRESA)
)

--CRIAÇÃO TABELA FUNCIONÁRIO
--DROP TABLE FUNCIONARIO
CREATE TABLE FUNCIONARIO
(
	COD_EMPRESA INT NOT NULL,
	MATRICULA INT NOT NULL,
	COD_CC VARCHAR(4) NOT NULL,
	NOME VARCHAR(50) NOT NULL,
	RG VARCHAR(15) NOT NULL,
	CPF VARCHAR(15) NOT NULL,
	ENDERECO VARCHAR(15) NOT NULL,
	NUMERO VARCHAR(10) NOT NULL,
	BAIRRO VARCHAR(50) NOT NULL,
	COD_CIDADE VARCHAR(7) NOT NULL,
	DATA_ADMISS DATE NOT NULL,
	DATA_DEMISS DATE,
	DATA_NASC DATE NOT NULL,
	TELEFONE VARCHAR(15) NOT NULL,
	COD_CARGO INT NOT NULL,
	CONSTRAINT FK_FUNC1 FOREIGN KEY (COD_EMPRESA,COD_CC)
	REFERENCES CENTRO_CUSTO(COD_EMPRESA,COD_CC),
	CONSTRAINT FK_FUNC2 FOREIGN KEY (COD_CIDADE)
	REFERENCES CIDADES(COD_CIDADE),
	CONSTRAINT FK_FUNC3 FOREIGN KEY (COD_EMPRESA,COD_CARGO)
	REFERENCES CARGOS(COD_EMPRESA,COD_CARGO),
	CONSTRAINT PK_FUNC1 PRIMARY KEY (COD_EMPRESA, MATRICULA),
);

--CRIAÇÃO TABELA SALÁRIO
CREATE TABLE SALARIO
(
	COD_EMPRESA INT NOT NULL,
	MATRICULA INT NOT NULL,
	SALARIO DECIMAL(10,2) NOT NULL,
	CONSTRAINT FK_SAL2 FOREIGN KEY (COD_EMPRESA,MATRICULA)
	REFERENCES FUNCIONARIO (COD_EMPRESA,MATRICULA),
	CONSTRAINT PK_SAL1 PRIMARY KEY (COD_EMPRESA,MATRICULA),
)

--CRIACAO TABLE FOLHA DE PAGTO
--DROP TABLE FOLHA_PAGTO
CREATE TABLE FOLHA_PAGTO
	(
	COD_EMPRESA INT NOT NULL,
	MATRICULA INT NOT NULL,
	TIPO_PGTO CHAR(1) NOT NULL,-- (M-FOLHA,A-ADTO,F-FERIAS,D-13º,R-RESC),
	TIPO CHAR(1)  NOT NULL,--P=PROVENTOS D-DESCONTO
	EVENTO VARCHAR(30) NOT NULL, 
	MES_REF VARCHAR(2)NOT NULL,
	ANO_REF VARCHAR(4)NOT NULL,
	DATA_PAGTO DATE NOT NULL,
	VALOR DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_FP1 FOREIGN KEY (COD_EMPRESA,MATRICULA) 
	REFERENCES FUNCIONARIO(COD_EMPRESA,MATRICULA)
	);

--CRIANDO INDEX
	CREATE INDEX IX1_FOLHA ON FOLHA_PAGTO(COD_EMPRESA,MATRICULA);

--SEGURANCA
--CRIACAO TA TABELAS USARIOS 
CREATE TABLE USUARIOS
	(
	COD_EMPRESA INT NOT NULL,
	LOGIN VARCHAR(30) NOT NULL PRIMARY KEY,
	MATRICULA INT NOT NULL,
	SENHA   VARCHAR(32) NOT NULL,
	SITUACAO CHAR(1) NOT NULL, --A=ATIVO -B BLOQUEADO
	CONSTRAINT FK_US1 FOREIGN KEY (COD_EMPRESA,MATRICULA) 
	REFERENCES FUNCIONARIO(COD_EMPRESA,MATRICULA)
	);



--FINANCEIRO
--CRIACAO TABELA CONTAS A RECEBER
CREATE TABLE CONTAS_RECEBER
	(
	COD_EMPRESA INT NOT NULL,
	ID_DOC INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ID_CLIENTE INT NOT NULL,
	ID_DOC_ORIG INT NOT NULL, --ALTER CAMPO ID_DOC_ORIG PARA FK TABELA NOTA_FISCAL
	PARC INT NOT NULL,
	DATA_VENC DATE NOT NULL,
	DATA_PAGTO DATE ,
	VALOR DECIMAL(10,2),
	CONSTRAINT FK_CR1 FOREIGN KEY (COD_EMPRESA,ID_CLIENTE) 
	REFERENCES CLIENTES(COD_EMPRESA,ID_CLIENTE)
	)

--CRIACAO TABELA CONTAS A PAGAR
--DROP TABLE CONTAS_PAGAR
CREATE TABLE CONTAS_PAGAR
	(
	COD_EMPRESA INT NOT NULL,
	ID_DOC INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ID_FOR INT NOT NULL,
	ID_DOC_ORIG INT NOT NULL, --ALTER CAMPO ID_DOC_ORIG PARA FK TABELA NOTA_FISCAL
	PARC INT NOT NULL,
	DATA_VENC DATE NOT NULL,
	DATA_PAGTO DATE ,
	VALOR DECIMAL(10,2),
	CONSTRAINT FK_CP1 FOREIGN KEY (COD_EMPRESA,ID_FOR) 
	REFERENCES FORNECEDORES(COD_EMPRESA,ID_FOR)
	);

--CRIACAO TABELA CONDIÇÕES DE PAGTO
CREATE TABLE COND_PAGTO
	(
	COD_PAGTO INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	NOME_CP VARCHAR(50) NOT NULL ,
	);

--CRIACAO DA TABELAS DETALHES DE CONDICAO DE PAGTO COM PARCELA
CREATE TABLE COND_PAGTO_DET
	(
	COD_PAGTO INT NOT NULL,
	PARC     INT NOT NULL,
	DIAS     INT NOT NULL,
	PCT  DECIMAL(10,2)NOT NULL,--PERCENTUAL DA PARCELA
	CONSTRAINT FK_CONDP1 FOREIGN KEY (COD_PAGTO) 
	REFERENCES COND_PAGTO(COD_PAGTO)
	)

--COMERCIAL
--CRIACAO TABELA PEDIDO DE VENDAS
CREATE TABLE PED_VENDAS
	(
	COD_EMPRESA INT NOT NULL,
	NUM_PEDIDO INT  NOT NULL,
	ID_CLIENTE INT NOT NULL,
	COD_PAGTO INT NOT NULL, 
	DATA_PEDIDO DATE NOT NULL,
	DATA_ENTREGA DATE NOT NULL,
	SITUACAO NCHAR(1) NOT NULL, --A-ABERTO P-PLANEJADO -F FINALIZADO
	TOTAL_PED DECIMAL(10,2),
	CONSTRAINT FK_PV1 FOREIGN KEY (COD_EMPRESA,ID_CLIENTE) 
	REFERENCES CLIENTES(COD_EMPRESA,ID_CLIENTE),
	CONSTRAINT FK_PV2 FOREIGN KEY (COD_PAGTO) 
	REFERENCES COND_PAGTO(COD_PAGTO),
	CONSTRAINT PK_PV1 PRIMARY KEY (COD_EMPRESA,NUM_PEDIDO)
	);


--CRIACAO DA TABELA PEDIDO VENDAS ITENS
CREATE TABLE PED_VENDAS_ITENS
	(
	COD_EMPRESA INT NOT NULL,
	NUM_PEDIDO INT NOT NULL,
	SEQ_MAT INT NOT NULL,
	COD_MAT INT NOT NULL,
	QTD     INT NOT NULL,
	VAL_UNIT DECIMAL(10,2) NOT NULL,
	CONSTRAINT FK_PVIT1 FOREIGN KEY (COD_EMPRESA,NUM_PEDIDO) 
	REFERENCES PED_VENDAS(COD_EMPRESA,NUM_PEDIDO),
	CONSTRAINT PK_PVIT1 PRIMARY KEY (COD_EMPRESA,NUM_PEDIDO,SEQ_MAT)
	);


--CRIACAO TABELAS VENDEDORES
--DROP TABLE VENDEDORES
CREATE TABLE VENDEDORES
    (COD_EMPRESA INT NOT NULL,
	 MATRICULA  INT NOT NULL,
 	CONSTRAINT FK_VEND1 FOREIGN KEY (COD_EMPRESA,MATRICULA) 
	REFERENCES FUNCIONARIO(COD_EMPRESA,MATRICULA)
	 );

--CRIACAO DE TAB GERENTES DE VENDAS
CREATE TABLE GERENTES
    (COD_EMPRESA INT NOT NULL,
	 MATRICULA INT NOT NULL,
 	CONSTRAINT FK_GER1 FOREIGN KEY (COD_EMPRESA,MATRICULA) 
	REFERENCES FUNCIONARIO(COD_EMPRESA,MATRICULA)
	 );

--CANAL DE VENDAS RELACIONA GERENTE COM VENDEDOR
CREATE TABLE CANAL_VENDAS_G_V
	(
	COD_EMPRESA INT NOT NULL,
	MATRICULA_GER INT NOT NULL,
	MATRICULA_VEND INT,
	CONSTRAINT FK_CGV1 FOREIGN KEY (COD_EMPRESA,MATRICULA_GER) 
	REFERENCES FUNCIONARIO(COD_EMPRESA,MATRICULA),
	CONSTRAINT FK_CGV2 FOREIGN KEY (COD_EMPRESA,MATRICULA_VEND) 
	REFERENCES FUNCIONARIO(COD_EMPRESA,MATRICULA),
	CONSTRAINT PK_CGV1 PRIMARY KEY (COD_EMPRESA,MATRICULA_GER,MATRICULA_VEND)
	)

--CANAL DE VENDAS RELACIONA VENDEDOR COM CLIENTE
CREATE TABLE CANAL_VENDAS_V_C
	(
	COD_EMPRESA INT NOT NULL,
	MATRICULA_VEND INT NOT NULL,
	ID_CLIENTE INT NOT NULL,
	CONSTRAINT FK_CVC1 FOREIGN KEY (COD_EMPRESA,MATRICULA_VEND) 
	REFERENCES FUNCIONARIO(COD_EMPRESA,MATRICULA),
	CONSTRAINT FK_CVC2 FOREIGN KEY (COD_EMPRESA,ID_CLIENTE) 
	REFERENCES CLIENTES(COD_EMPRESA,ID_CLIENTE)
	)

--CRIACAO DE TABELA PARA REGISTRA META DE VENDAS MES A MES/ANO
CREATE TABLE META_VENDAS
	(
	COD_EMPRESA INT NOT NULL,
	MATRICULA_VEND INT NOT NULL,
	ANO VARCHAR(4) NOT NULL,
	MES VARCHAR(2) NOT NULL,
	VALOR DECIMAL(10,2),
	CONSTRAINT FK_MV1 FOREIGN KEY (COD_EMPRESA,MATRICULA_VEND) 
	REFERENCES FUNCIONARIO(COD_EMPRESA,MATRICULA)
	);


--FISCAL
--CRIACAO DA TABELA DOS CODIGO DE OPERACOES FISCAIS
--DROP TABLE CFOP
	CREATE TABLE CFOP
	(
	COD_CFOP VARCHAR(5) NOT NULL PRIMARY KEY,
	DESC_CFOP VARCHAR(255) NOT NULL
	)

--CRIACAO DA TABELA NOTA_FISCAL
--DROP TABLE NOTA_FISCAL
--DROP TABLE NOTA_FISCAL_ITENS
CREATE TABLE NOTA_FISCAL
	(
	COD_EMPRESA INT NOT NULL,
	NUM_NF INT  NOT NULL ,
	TIP_NF CHAR(1) NOT NULL, --E ENTRADA, S- SAIDA
	COD_CFOP VARCHAR(5) NOT NULL,
	ID_CLIFOR INT NOT NULL,
	COD_PAGTO INT NOT NULL, 
	DATA_EMISSAO DATETIME NOT NULL,
	DATA_ENTREGA DATE NOT NULL,
	TOTAL_NF DECIMAL(10,2),
	INTEGRADA_FIN CHAR(1) DEFAULT('N'),
	INTEGRADA_SUP CHAR(1) DEFAULT('N'),
	CONSTRAINT FK_NF1 FOREIGN KEY (COD_CFOP) 
	REFERENCES CFOP(COD_CFOP),
	CONSTRAINT FK_NF2 FOREIGN KEY (COD_PAGTO) 
	REFERENCES COND_PAGTO(COD_PAGTO),
	CONSTRAINT PK_NF1 PRIMARY KEY (COD_EMPRESA,NUM_NF)
	);


--CRIACAO DA TABELA NOTA_FISCAL_ITENS
CREATE TABLE NOTA_FISCAL_ITENS
	(
	COD_EMPRESA INT NOT NULL,
	NUM_NF INT NOT NULL,
	SEQ_MAT INT NOT NULL,
	COD_MAT INT NOT NULL,
	QTD     INT NOT NULL,
	VAL_UNIT DECIMAL(10,2) NOT NULL,
	PED_ORIG  INT NOT NULL,
	CONSTRAINT FK_NFIT1 FOREIGN KEY (COD_EMPRESA,NUM_NF) 
	REFERENCES NOTA_FISCAL(COD_EMPRESA,NUM_NF),
	CONSTRAINT FK_NFIT2 FOREIGN KEY (COD_EMPRESA,COD_MAT) 
	REFERENCES MATERIAL(COD_EMPRESA,COD_MAT),
	)	

--CRIACAO TABELAS PARAMETRO DE INSS

CREATE TABLE PARAM_INSS
(
 VIGENCIA_INI DATE,
 VIGENCIA_FIM DATE,
 VALOR_DE DECIMAL(10,2) NOT NULL,
 VALOR_ATE DECIMAL(10,2) NOT NULL,
 PCT DECIMAL(10,2) NOT NULL
 )

--CRIACAO DE TABELAS DE PARAMETRO DO IRRF
CREATE TABLE PARAM_IRRF
(
 VIGENCIA_INI DATE,
 VIGENCIA_FIM DATE,
 VALOR_DE DECIMAL(10,2) NOT NULL,
 VALOR_ATE DECIMAL(10,2) NOT NULL,
 PCT DECIMAL(10,2) NOT NULL,
 VAL_ISENT DECIMAL(10,2)
 )


 --CRIACAO TABELAS AUDIT SALARIO
 CREATE TABLE AUDITORIA_SALARIO
 (
    COD_EMPRESA INT NOT NULL,
	MATRICULA VARCHAR(30) NOT NULL,
	SAL_ANTES DECIMAL(10, 2) NOT NULL,
	SAL_DEPOIS DECIMAL(10, 2) NOT NULL,
	USUARIO VARCHAR(20) NOT NULL,
	DATA_ATUALIZACAO DATETIME NOT NULL
);

--TABELAS DE PARAMETROS PARA AUTONUMERACAO
 CREATE TABLE PARAMETROS
 (COD_EMPRESA INT NOT NULL,
  PARAM VARCHAR(50) NOT NULL,
  VALOR INT NOT NULL,
  CONSTRAINT FK_PARAM1 FOREIGN KEY (COD_EMPRESA) 
	REFERENCES EMPRESA(COD_EMPRESA),
  CONSTRAINT PK_PARAM1 PRIMARY KEY (COD_EMPRESA,PARAM)
  );

 -- CREATE INDEX IX_PARAM1 ON PARAMETROS(COD_EMPRESA,PARAM);
  

--ADD CAMPO LOGIN TABELA APONTAMENTOS CRIACAO APOS TABELA USUARIOS E FK
ALTER TABLE APONTAMENTOS ADD LOGIN VARCHAR(30)NOT NULL;
--ADCIONAR CAMPO LOTE NA TABELA APONTAMENTOS
ALTER TABLE APONTAMENTOS ADD LOTE VARCHAR(20) NOT NULL;

--ADD CAMPO LOGIN TABELA ESTOQUE_MOV  CRIACAO APOS TABELA USUARIO
 ALTER TABLE ESTOQUE_MOV ADD LOGIN VARCHAR(30)NOT NULL;
--MINI ERP
--USE MASTER
--DROP DATABASE MINIERP_MULT
--GO

--CARGA EMPRESA
INSERT INTO EMPRESA VALUES ('XYZ BIKES', 'MATRIZ'),('XYZ BIKES', 'FILIAL');

--VERIFICAÇÃO
SELECT * FROM EMPRESA

--CARGA TABELA PARÂMETROS
INSERT INTO PARAMETROS VALUES
(1,'PED_COMPRAS',0),(1,'MATRICULA',0),(1,'PED_VENDAS',0),(1,'NOTA_FISCAL',0),
(2,'PED_COMPRAS',0),(2,'MATRICULA',0),(2,'PED_VENDAS',0),(2,'NOTA_FISCAL',0)

--VERIFICAÇÃO
SELECT * FROM PARAMETROS

--CARGA TABLE UF
INSERT INTO UF
SELECT DISTINCT B.UF, A.estado
FROM CURSO.DBO.UF a  --informação de outro servidor!
INNER JOIN CURSO.DBO.senso b --idem
ON a.COD_UF=b.cod_uf

--VERIFICAÇÃO
SELECT * FROM UF

--CARGA TABELA CIDADES
INSERT INTO CIDADES
SELECT cod_uf+cod_mun, UF, NOME_MUN FROM CURSO.DBO.senso

--VERIFICAÇÃO
SELECT * FROM CIDADES

--CARGA TABELAS CLIENTES
--DBCC Checkident( CLIENTES, reseed, 0)
INSERT INTO CLIENTES VALUES 
	(1,'CARLOS JACOB HOUSTON','CARLOS','RUA 1','375','SANTA HELENA','4203709','13290000','123456987','F',GETDATE(),1),
	(1,'PEDRO LARSON OHIO','PEDRO','RUA 2','235','SANTA CLARA','4119608','13290987','123456989','F',GETDATE(),2),
	(2,'BIKES ON LTDA','BIKES ON','RUA 14','279','MONTANHA','5300108','13293245','343456987','J',GETDATE(),3),
	(2,'MY BIKE MY LIFE SA','BIKE LIFE','RUA 23','675','ALPES','3509502','13379245','11290340','J',GETDATE(),3)

--VERIFICAÇÃO
SELECT * FROM CLIENTES

--CARGA TABELAS FORNECEDORES	
INSERT INTO  FORNECEDORES VALUES
	(1,'SO BIKES LTDA','SO BIKES','RUA 10','375','SANTA HILDA','4203709','13290000','123456987','J',GETDATE(),1),
	(1,'ESPECIAL BIKES LTDA','ESPECIAL BIKES','RUA 2','235','SANTA GENEBRA','4119608','13290987','123456989','J',GETDATE(),2),
	(2,'MONTA BIKES ME','MONTA BIKES','RUA 67','345','ALADO','5300108','13293245','343456987','J',GETDATE(),3),
	(2,'TRAIL BIKES ME','TRAIL BIKES','RUA 70','345','ESFERA','5300108','13293245','343456987','J',GETDATE(),3)

--VERIFICAÇÃO
SELECT * FROM FORNECEDORES

--CARGA TABELA TIPO DE MATERIAL
INSERT INTO TIPO_MAT VALUES (1,1,'MATERIA PRIMA'),(1,2,'PRODUDO ACABADO'),
                            (1,3,'EMBALAGEM'),(1,4,'CONSUMO')
INSERT INTO TIPO_MAT VALUES (2,1,'MATERIA PRIMA'),(2,2,'PRODUDO ACABADO'),
                             (2,3,'EMBALAGEM'),(2,4,'CONSUMO');

--VERIFICAÇÃO
SELECT * FROM TIPO_MAT

INSERT INTO MATERIAL VALUES
	(1,1,'BICICLETA ARO 29 PRETA MOD INFINITY','2500','2',''),
	(1,2,'BICICLETA ARO 29 BRANCA MOD INFINITY','2500','2',''),
	(1,3,'QUADRO ARO 29','500','1','1'),
	(1,4,'KIT TRANSMISSAO','500','1','1'),--FREIO+MARCHA-PEDEVELA-TROCADORES+K-7
	(1,5,'ARO 29','70','1','1'),
	(1,6,'PNEU 29','100','1','2'),
	(1,7,'CAMARA 29','25','1','2'),
	(1,8,'SUSPENSAO DIANTEIRA','250','1','2'),
	(1,9,'BANCO','80','1','3'),
	(1,10,'CANOTE','35','1','3'),
    (1,11,'TINTA BRANCA','10','4','2'),
	(1,12,'TINTA PRETA','10','4','2'),
	(1,13,'MESA','500','1','1'),
	(1,14,'GUIDON','50','1','2'),
	(1,15,'LUVAS','30','1','2'),
	(1,16,'CAIXA EMBALAGEM','10','3','2')

--VERIFICAÇÃO
SELECT * FROM MATERIAL

--FICHA TECNICA BIKE PRETA	
INSERT INTO FICHA_TECNICA VALUES 
      (1,'1','3',1),(1,'1','4',1),(1,'1','5',2),(1,'1','6',2),(1,'1','7',2),
	  (1,'1','8',1),(1,'1','9',1),(1,'1','10',1),(1,'1','12',0.250),(1,'1','13',1),
	  (1,'1','14',1),(1,'1','15',2),(1,'1','16',1)

--FICHA TECNICA BIKE BRANCA
INSERT INTO FICHA_TECNICA VALUES 
      (1,'2','3',1),(1,'2','4',1),(1,'2','5',2),(1,'2','6',2),(1,'2','7',2),
	  (1,'2','8',1),(1,'2','9',1),(1,'2','10',1),(1,'2','11',0.250),(1,'2','13',1),
	  (1,'2','14',1),(1,'2','15',2),(1,'2','16',1)

--VERIFICAÇÃO
SELECT * FROM FICHA_TECNICA

--CARGA CENTRO DE CUSTOS
INSERT INTO CENTRO_CUSTO VALUES (1,'9001','PRESIDENCIA')
INSERT INTO CENTRO_CUSTO VALUES (1,'9002','ADMINISTRATIVO')
INSERT INTO CENTRO_CUSTO VALUES (1,'9003','PRODUCAO')
INSERT INTO CENTRO_CUSTO VALUES (1,'9004','SUPRIMENTOS')
INSERT INTO CENTRO_CUSTO VALUES (1,'9005','RH')
INSERT INTO CENTRO_CUSTO VALUES (1,'9006','FINANCEIRO')
INSERT INTO CENTRO_CUSTO VALUES (1,'9007','COMERCIAL')
INSERT INTO CENTRO_CUSTO VALUES (1,'9008','FISCAL')
INSERT INTO CENTRO_CUSTO VALUES (1,'9009','TI')

INSERT INTO CENTRO_CUSTO VALUES (2,'9001','PRESIDENCIA')
INSERT INTO CENTRO_CUSTO VALUES (2,'9002','ADMINISTRATIVO')
INSERT INTO CENTRO_CUSTO VALUES (2,'9003','PRODUCAO')
INSERT INTO CENTRO_CUSTO VALUES (2,'9004','SUPRIMENTOS')
INSERT INTO CENTRO_CUSTO VALUES (2,'9005','RH')
INSERT INTO CENTRO_CUSTO VALUES (2,'9006','FINANCEIRO')
INSERT INTO CENTRO_CUSTO VALUES (2,'9007','COMERCIAL')
INSERT INTO CENTRO_CUSTO VALUES (2,'9008','FISCAL')
INSERT INTO CENTRO_CUSTO VALUES (2,'9009','TI')

--VERIFICAÇÃO
SELECT * FROM CENTRO_CUSTO

--CARGA DE CARGOS FUNÇÕES
INSERT INTO CARGOS VALUES 
	(1,'PRESIDENTE'),(1,'GER COMERCIAL'),(1,'VENDEDOR'),(1,'GER ADM'),
	 (1,'ASSISTENTE DE RH'),(1,'OPERADOR PRODUCAO'),(1,'ESTOQUISTA'),(1,'ANALISTA DE SISTEMA'),
	 (1,'FATURISTA'),(1,'ASSISTENTE FINANCEIRO')

--VERIFICAÇÃO
SELECT * FROM CARGOS

--Como aproveitar o sequencial das tabelas:
--DESABILITA IDENTITY e força uma nova numeração para a empresa (no caso empresa 2)
--dessa forma irá respeitar o que vem a partir do SELECT e a empresa 2 segue o mesmo
--código da empresa 1
SET IDENTITY_INSERT CARGOS ON  
GO  
INSERT INTO CARGOS (COD_EMPRESA,COD_CARGO,NOME_CARGO)
SELECT 2,COD_CARGO,NOME_CARGO FROM CARGOS

--SELECT * FROM CARGOS
SET IDENTITY_INSERT CARGOS OFF --REABILITA IDENTITY para que novas inserções aconteçam de forma padrão
GO

--TRIGGER PARA NUMERACAO DE MATRICULAS
CREATE TRIGGER TG_NUM_MATR ON FUNCIONARIO
 INSTEAD OF   INSERT AS
BEGIN
    
	DECLARE @PARAM VARCHAR(50),
			@MATRICULA INT,
			@COD_EMPRESA INT
	 --ATRIBUI PARAMETRO PESQUISA
	SET     @PARAM='MATRICULA'
	--ATRIBUI VALORES VARIAVEL
	SELECT  @MATRICULA=MATRICULA,@COD_EMPRESA=COD_EMPRESA FROM INSERTED
   --CONDICAO 
		IF @MATRICULA =0
		  BEGIN
				--PEGANDO NUMERO PARA AUTO NUMERAR
				SELECT @MATRICULA=VALOR+1  FROM PARAMETROS 
				WHERE PARAM=@PARAM 
				AND COD_EMPRESA=@COD_EMPRESA
			--REALIZANDO INSERT
			INSERT INTO FUNCIONARIO
			 SELECT 
			  COD_EMPRESA,@MATRICULA,COD_CC,NOME,RG,CPF,ENDERECO,NUMERO,BAIRRO,COD_CIDADE,
			   DATA_ADMISS,DATA_DEMISS,DATA_NASC,TELEFONE,COD_CARGO
			   FROM INSERTED
			   WHERE 1=1
            --REALIZANDO UPDATE PARAMETROS
				UPDATE PARAMETROS SET VALOR=VALOR+1
				WHERE PARAM=@PARAM 
				AND COD_EMPRESA=@COD_EMPRESA
		 END		
   END 
--FIM TRIGGER - Com o carregamento da tabela de FUNCIONARIOS, o campo matricula da tabela PARAMETROS também será modificada

--CARGA TABELA FUNCIONARIO
INSERT INTO FUNCIONARIO VALUES
 (1,0,'9001','JAMES LABRIE','1234567','123567990','RUA 1','2','SANTA CLAUS','3525904','2017-01-03','','1980-12-25','','1')
INSERT INTO FUNCIONARIO VALUES
 (1,0,'9002','JONH LARAVEL','1234568','123567889','RUA 2','3','SANTA CLAUS','3525904','2017-02-10','','1980-12-25','','4')
INSERT INTO FUNCIONARIO VALUES
 (1,0,'9003','PETER DOTNESK','3434568','123564578','RUA 3','4','SANTA CLAUS','3525904','2017-02-09','','1980-12-25','','6')
INSERT INTO FUNCIONARIO VALUES
 (1,0,'9004','LARA POTTER','4434509','123576867','RUA 4','5','SANTA CLAUS','3525904','2017-03-07','','1980-12-25','','7')
 INSERT INTO FUNCIONARIO VALUES
 (1,0,'9005','JESSICA SUTER','4534576','120367887','RUA 5','6','SANTA CLAUS','3525904','2017-03-03','','1980-12-25','','5')
INSERT INTO FUNCIONARIO VALUES
 (1,0,'9006','PEDRO TESLA','4334568','123703885','RUA 6','7','SANTA CLAUS','3525904','2017-04-15','','1980-12-25','','1')
INSERT INTO FUNCIONARIO VALUES
 (1,0,'9007','TIAGO FIELDER','9834568','147034889','RUA 7','8','SANTA CLAUS','3525904','2017-04-20','','1980-12-25','','2')
INSERT INTO FUNCIONARIO VALUES
 (1,0,'9007','MALCON DEXTER','9834568','147067889','RUA 17','28','SANTA CLAUS','3525904','2017-04-20','','1980-12-25','','3')
 INSERT INTO FUNCIONARIO VALUES
 (1,0,'9007','CHARLES NOIX','9894668','147067149','RUA 77','18','SANTA CLAUS','3525904','2017-04-20','','1980-12-25','','3')
 INSERT INTO FUNCIONARIO VALUES
 (1,0,'9008','JOAO SPARK','7734568','643567888','RUA 8','22','SANTA CLAUS','3525904','2017-05-07','','1980-12-25','','9')
INSERT INTO FUNCIONARIO VALUES
 (1,0,'9009','DAVID MANDRAKE','6634568','345567887','RUA 8','56','SANTA CLAUS','3525904','2017-05-07','','1980-12-25','','8')
INSERT INTO FUNCIONARIO VALUES
 (1,0,'9002','SAMUEL DUPRET','8984568','159567887','RUA 23','89','SANTA CLAUS','3525904','2017-05-07','','1980-12-25','','10')

 --VERIFICAÇÃO
 SELECT * FROM FUNCIONARIO
 SELECT * FROM PARAMETROS

 --CARGA TABELA USUARIOS
 INSERT INTO USUARIOS (COD_EMPRESA,LOGIN,MATRICULA,SENHA,SITUACAO) VALUES
(1,'JAMESL','1','','A'),(1,'JONHL','2','','A'),
(1,'PETERD','3','','A'),(1,'LARAP','4','','A'),
(1,'JESSICAS','5','','A'),(1,'PEDROT','6','','A'),
(1,'TIAGOF','7','','A'),(1,'MALCOND','8','','A'),
(1,'CHARLESN','9','','A'),(1,'JOAOS','10','','A'),
(1,'DAVIDM','11','','A'),(1,'SAMUELD','12','','A')

---GRAVANDO E CRIPTOGRAFANDO SENHA COM MD5 COM SENHA INICIAL = MATRICULA
UPDATE USUARIOS 
SET SENHA=CONVERT(VARCHAR(32), HashBytes('MD5', CONVERT(varchar,matricula)), 2)

--VERIFICAÇÃO
SELECT * FROM USUARIOS

--CARGA TABELA CONDICAO DE PAGAMENTO
INSERT INTO COND_PAGTO VALUES
	('A VISTA'),('3 X 30/60/90 DD'),('30 DD')

--VERIFICACAO
SELECT * FROM COND_PAGTO

--CARGA DETALHE DE PAGAMENTO PARCELAS
INSERT INTO COND_PAGTO_DET VALUES
	('1','1',0,100)

INSERT INTO COND_PAGTO_DET VALUES
	('2','1',30,33.34),
	('2','2',60,33.33),
	('2','3',90,33.33)

INSERT INTO COND_PAGTO_DET VALUES
	('3','1',30,100);

--VERIFICAÇÃO
SELECT * FROM COND_PAGTO_DET

--CARGA VENDEDORES
INSERT INTO VENDEDORES
SELECT A.COD_EMPRESA,A.MATRICULA 
FROM FUNCIONARIO A
 INNER JOIN CARGOS B
 ON A.COD_EMPRESA=B.COD_EMPRESA
 AND A.COD_CARGO=B.COD_CARGO
 WHERE B.NOME_CARGO='VENDEDOR'
 AND  CONCAT(A.COD_EMPRESA,A.MATRICULA) NOT IN (SELECT CONCAT(COD_EMPRESA,MATRICULA) FROM VENDEDORES)
--CONCAT para especificar o INSERT de vendedores que ainda NÃO estão na tabela de vendedores

 --VERIFICAÇÃO
SELECT * FROM VENDEDORES
SELECT * FROM FUNCIONARIO

--CARGA TABELA GERENTES
INSERT INTO GERENTES
SELECT A.COD_EMPRESA,A.MATRICULA 
FROM FUNCIONARIO A
 INNER JOIN CARGOS B
 ON A.COD_EMPRESA=B.COD_EMPRESA
 AND A.COD_CARGO=B.COD_CARGO
 WHERE B.NOME_CARGO='GER COMERCIAL'
 AND  CONCAT(A.COD_EMPRESA,A.MATRICULA) NOT IN (SELECT CONCAT(COD_EMPRESA,MATRICULA) FROM GERENTES)
--CONCAT para especificar o INSERT de gerentes que ainda NÃO estão na tabela de gerentes


 --VERIFICAÇÃO
SELECT * FROM GERENTES
SELECT * FROM FUNCIONARIO

--CARGA CANAL VENDAS GERENTE X VENDEDOR
INSERT INTO CANAL_VENDAS_G_V VALUES 
	(1,7,8),(1,7,9)

 --VERIFICAÇÃO
SELECT * FROM CANAL_VENDAS_G_V
SELECT * FROM VENDEDORES
SELECT * FROM GERENTES

--CARGA CANAL VENDAS VENDEDOR X CLIENTE
INSERT CANAL_VENDAS_V_C VALUES
	(1,8,1),(1,9,2)

--VERIFICAÇÃO
SELECT * FROM CLIENTES
SELECT * FROM CANAL_VENDAS_V_C

--CARGA DE META DE VENDAS
INSERT INTO META_VENDAS VALUES
  (1,9,'2018','01',83.33), (1,9,'2018','02',83.33),(1,9,'2018','03',83.33), (1,9,'2018','04',83.33),
  (1,9,'2018','05',83.33), (1,9,'2018','06',83.33),(1,9,'2018','07',83.33), (1,9,'2018','08',83.33),
  (1,9,'2018','09',83.33), (1,9,'2018','10',83.33),(1,9,'2018','11',83.33), (1,9,'2018','12',83.33)

INSERT INTO META_VENDAS VALUES
  (1,8,'2018','01',83.33), (1,8,'2018','02',83.33),(1,8,'2018','03',83.33), (1,8,'2018','04',83.33),
  (1,8,'2018','05',83.33), (1,8,'2018','06',83.33),(1,8,'2018','07',83.33), (1,8,'2018','08',83.33),
  (1,8,'2018','09',83.33), (1,8,'2018','10',83.33),(1,8,'2018','11',83.33), (1,8,'2018','12',83.33)

--VERIFICAÇÃO
SELECT * FROM META_VENDAS
  
--CARGA CFOP CODIGO DE OPERACAOS FISCAIS
 INSERT INTO CFOP VALUES
	('5.101','VENDAS DE MERC'),('1.101','COMPRAS DE MERC')

--VERIFICAÇÃO
SELECT * FROM CFOP

-- TRIGGER PARA AUTO NUMERÇÃO DO PEDIDO DE VENDAS
--SELECT * FROM PED_VENDAS
CREATE TRIGGER TG_NUM_PED_V ON PED_VENDAS
 INSTEAD OF   INSERT AS
BEGIN
    
	DECLARE @PARAM VARCHAR(50),
			@NUM_PEDIDO INT,
			@COD_EMPRESA INT
	 
	SET     @PARAM='PED_VENDAS'
	
	SELECT  @NUM_PEDIDO=NUM_PEDIDO,@COD_EMPRESA=COD_EMPRESA FROM INSERTED --INSERTED é a tabela PED_VENDAS
   
		IF @NUM_PEDIDO IS NULL
		  BEGIN
				SELECT @NUM_PEDIDO=VALOR+1  FROM PARAMETROS 
				WHERE PARAM=@PARAM 
				AND COD_EMPRESA=@COD_EMPRESA
			--REALIZANDO INSERT
			INSERT INTO PED_VENDAS
			 SELECT 
			  COD_EMPRESA,@NUM_PEDIDO,ID_CLIENTE,COD_PAGTO,DATA_PEDIDO,DATA_ENTREGA,SITUACAO,0
			   FROM INSERTED
			   WHERE 1=1
            --REALIZANDO UPDDATE PARAMETROS
				UPDATE PARAMETROS SET VALOR=VALOR+1
				WHERE PARAM=@PARAM 
				AND COD_EMPRESA=@COD_EMPRESA

		 END		
   END 
   
--INSERT PED_VENDAS CABEÇALHO
INSERT INTO PED_VENDAS (COD_EMPRESA,ID_CLIENTE,COD_PAGTO,DATA_PEDIDO,DATA_ENTREGA,SITUACAO) VALUES
 (1,1,1,'2018-01-13','2018-01-29','A')
INSERT INTO PED_VENDAS (COD_EMPRESA,ID_CLIENTE,COD_PAGTO,DATA_PEDIDO,DATA_ENTREGA,SITUACAO) VALUES
 (1,2,3,'2018-02-13','2018-02-28','A')
INSERT INTO PED_VENDAS (COD_EMPRESA,ID_CLIENTE,COD_PAGTO,DATA_PEDIDO,DATA_ENTREGA,SITUACAO) VALUES
 (1,1,2,'2018-03-13','2018-03-29','A')
 INSERT INTO PED_VENDAS (COD_EMPRESA,ID_CLIENTE,COD_PAGTO,DATA_PEDIDO,DATA_ENTREGA,SITUACAO) VALUES
 (1,2,2,'2018-04-13','2018-04-29','A')
INSERT INTO PED_VENDAS (COD_EMPRESA,ID_CLIENTE,COD_PAGTO,DATA_PEDIDO,DATA_ENTREGA,SITUACAO) VALUES
 (1,2,3,'2018-05-13','2018-05-29','A')
 INSERT INTO PED_VENDAS (COD_EMPRESA,ID_CLIENTE,COD_PAGTO,DATA_PEDIDO,DATA_ENTREGA,SITUACAO) VALUES
 (1,1,3,'2018-06-13','2018-06-29','A')
 INSERT INTO PED_VENDAS (COD_EMPRESA,ID_CLIENTE,COD_PAGTO,DATA_PEDIDO,DATA_ENTREGA,SITUACAO) VALUES
 (1,2,1,'2018-07-13','2018-07-29','A')
 INSERT INTO PED_VENDAS (COD_EMPRESA,ID_CLIENTE,COD_PAGTO,DATA_PEDIDO,DATA_ENTREGA,SITUACAO) VALUES
 (1,1,3,'2018-08-13','2018-08-29','A')
 INSERT INTO PED_VENDAS (COD_EMPRESA,ID_CLIENTE,COD_PAGTO,DATA_PEDIDO,DATA_ENTREGA,SITUACAO) VALUES
 (1,2,2,'2018-09-13','2018-09-29','A')
 INSERT INTO PED_VENDAS (COD_EMPRESA,ID_CLIENTE,COD_PAGTO,DATA_PEDIDO,DATA_ENTREGA,SITUACAO) VALUES
 (1,2,1,'2018-10-13','2018-10-29','A')
 INSERT INTO PED_VENDAS (COD_EMPRESA,ID_CLIENTE,COD_PAGTO,DATA_PEDIDO,DATA_ENTREGA,SITUACAO) VALUES
 (1,1,2,'2018-11-13','2018-11-29','A')
 INSERT INTO PED_VENDAS (COD_EMPRESA,ID_CLIENTE,COD_PAGTO,DATA_PEDIDO,DATA_ENTREGA,SITUACAO) VALUES
 (1,2,2,'2018-12-13','2018-12-29','A')

--VERIFICAÇÃO
SELECT * FROM PED_VENDAS
SELECT * FROM PARAMETROS

--CARGA DETALHES DE PEDIDOS
 INSERT INTO PED_VENDAS_ITENS VALUES
	(1,1,1,1,35,2500),(1,1,2,2,40,2500),
	(1,2,1,1,50,2500),(1,2,2,2,35,2500),
	(1,3,1,1,50,2500),(1,3,2,2,35,2500),
	(1,4,1,1,50,2500),(1,4,2,2,35,2500),
	(1,5,1,1,50,2500),(1,5,2,2,35,2500),
	(1,6,1,1,50,2500),(1,6,2,2,35,2500),
	(1,7,1,1,50,2500),(1,7,2,2,35,2500),
	(1,8,1,1,70,2500),(1,8,2,2,70,2500),
	(1,9,1,1,50,2500),(1,9,2,2,35,2500),
	(1,10,1,1,50,2500),(1,10,2,2,35,2500),
	(1,11,1,1,100,2500),(1,11,2,2,100,2500),
	(1,12,1,1,50,2500),(1,12,2,2,35,2500)

--VERIFICAÇÃO
SELECT * FROM PED_VENDAS
SELECT * FROM PED_VENDAS_ITENS

--ATUALIZANDO TOTAL PEDIDO VENDAS COM BASE NA TAB VENDA ITENS
--PED_ITENS apelido para ped_vendas

   WITH PED_ITENS(COD_EMPRESA,NUM_PEDIDO,TOTAL) AS
   (
	   SELECT A.COD_EMPRESA,A.NUM_PEDIDO,SUM(A.QTD*A.VAL_UNIT) TOTAL
	   FROM PED_VENDAS_ITENS A
	   GROUP BY A.COD_EMPRESA,A.NUM_PEDIDO
   )
   UPDATE PED_VENDAS SET TOTAL_PED=B.TOTAL 
   FROM PED_VENDAS A
   INNER JOIN PED_ITENS B
   ON A.NUM_PEDIDO=B.NUM_PEDIDO
   AND A.COD_EMPRESA=B.COD_EMPRESA

--VERIFICAÇÃO
SELECT * FROM PED_VENDAS

--CARGA FUNCIONARIO SALARIOS
INSERT INTO SALARIO VALUES (1,1,7650),(1,2,2650),(1,3,2550),(1,4,1550),
                           (1,5,4550),(1,6,2850),(1,7,1850),(1,8,1560),
						   (1,9,3899),(1,10,2345),(1,11,3100),(1,12,4500)

--VERIFICAÇÃO
SELECT * FROM SALARIO

--CARGA PARAMETROS INSS
 INSERT INTO PARAM_INSS VALUES 
   ('2018-01-01','2018-12-31',0,1659.38,8),
   ('2018-01-01','2018-12-31',1659.39,2765.66,9),
   ('2018-01-01','2018-12-31',2765.67,5531.31,11),
   ('2018-01-01','2018-12-31',5531.32,999999,0)

--VERIFICAÇÃO
SELECT * FROM PARAM_INSS

--CARGA PARAMETROS IRPF

 INSERT INTO PARAM_IRRF VALUES 
 ('2018-01-01','2018-12-31',0,1903.98,0,0),
 ('2018-01-01','2018-12-31',1903.99,2826.65,7.5,142.80),
 ('2018-01-01','2018-12-31',2826.66,3751.05,15,354.80),
 ('2018-01-01','2018-12-31',3751.06,4664.68,22.5,636.13),
 ('2018-01-01','2018-12-31',4664.68,999999,27.5,869.36)

--VERIFICAÇÃO
SELECT * FROM PARAM_IRRF
