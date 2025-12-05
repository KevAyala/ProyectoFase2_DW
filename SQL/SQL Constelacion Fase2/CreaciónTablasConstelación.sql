USE AutopartesProyecto;

CREATE TABLE FactRecomendacionesEntrada (
    IdRecomendacion INT IDENTITY(1,1) PRIMARY KEY,
    
    ClaveArticulo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    ClaveArticuloRecomendado CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    
    ConteoEntradas INT NOT NULL,  -- FoliosJuntos
    
    FOREIGN KEY (ClaveArticulo) REFERENCES DimArticulo(ClaveArticulo),
    FOREIGN KEY (ClaveArticuloRecomendado) REFERENCES DimArticulo(ClaveArticulo)
);

CREATE TABLE FactRecomendacionesSalida (
    IdRecomendacion INT IDENTITY(1,1) PRIMARY KEY,
    
    ClaveArticulo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    ClaveArticuloRecomendado CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    
    ConteoSalidas INT NOT NULL,  -- FoliosJuntos
    
    FOREIGN KEY (ClaveArticulo) REFERENCES DimArticulo(ClaveArticulo),
    FOREIGN KEY (ClaveArticuloRecomendado) REFERENCES DimArticulo(ClaveArticulo)
);
