USE RecomendacionProductosSalida;

CREATE TABLE DimArticulo(
	ClaveArticulo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS PRIMARY KEY,
	Descripcion VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloTipo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloTipoDescripcion VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloGrupo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloGrupoDescripcion VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloClase CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloClaseDescripcion VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Almacenable CHAR(1) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Identificacion VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	UMedInv CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	UMedVenta CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	UMedCpa CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Precio NUMERIC(15,5),
	pctDescuento NUMERIC(8,5),
	UbicacionAlmacen CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	UbicacionClave CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS
);

CREATE TABLE DimArticuloRecomendado(
	ClaveArticulo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS PRIMARY KEY,
	Descripcion VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloTipo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloTipoDescripcion VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloGrupo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloGrupoDescripcion VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloClase CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloClaseDescripcion VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Almacenable CHAR(1) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Identificacion VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	UMedInv CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	UMedVenta CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	UMedCpa CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Precio NUMERIC(15,5),
	pctDescuento NUMERIC(8,5),
	UbicacionAlmacen CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	UbicacionClave CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS
);

CREATE TABLE DimCliente(
	ClaveCliente CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS PRIMARY KEY NOT NULL,
	RazonSocial VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CalleNumero VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Colonia VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Ciudad VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Estado CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Pais CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CodigoPostal VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ClienteTipo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ClienteGrupo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS
);

CREATE TABLE DimVendedor(
	ClaveVendedor CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS PRIMARY KEY,
	NombreVendedor VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
);

CREATE TABLE FactRecomendacionesSalida (
    IdRecomendacion INT IDENTITY(1,1) PRIMARY KEY,
    
    ClaveArticulo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    ClaveArticuloRecomendado CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    
    ConteoSalidas INT NOT NULL,
    
    FOREIGN KEY (ClaveArticulo) REFERENCES DimArticulo(ClaveArticulo),
    FOREIGN KEY (ClaveArticuloRecomendado) REFERENCES DimArticuloRecomendado(ClaveArticulo)
);

CREATE TABLE FactRecomendacionesSalidaCyV (
    IdRecomendacion INT IDENTITY(1,1) PRIMARY KEY,
    
    ClaveArticulo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    ClaveArticuloRecomendado CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,

    ClaveCliente CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    ClaveVendedor CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,

    ConteoSalidas INT NOT NULL,

    FOREIGN KEY (ClaveArticulo) REFERENCES DimArticulo(ClaveArticulo),
    FOREIGN KEY (ClaveArticuloRecomendado) REFERENCES DimArticuloRecomendado(ClaveArticulo),
    FOREIGN KEY (ClaveCliente) REFERENCES DimCliente(ClaveCliente),
    FOREIGN KEY (ClaveVendedor) REFERENCES DimVendedor(ClaveVendedor)
);


------------------------- VENDEDOR -------------------------
CREATE OR ALTER PROCEDURE PoblarDimVendedor
AS
BEGIN
	INSERT INTO RecomendacionProductosEntrada.dbo.DimVendedor (ClaveVendedor, NombreVendedor)
	SELECT V.Clave, V.Nombre
	FROM AutopartesO2025.dbo.Vendedor V
	WHERE NOT EXISTS(
		SELECT 1
		FROM RecomendacionProductosEntrada.dbo.DimVendedor DV
		WHERE DV.ClaveVendedor  = V.Clave
	);

	PRINT 'Registros insertados en DimVendedor'
END;
GO

EXECUTE PoblarDimVendedor;

------------------------- CLIENTE -------------------------
CREATE OR ALTER PROCEDURE PoblarDimCliente
AS
BEGIN
	INSERT INTO RecomendacionProductosEntrada.dbo.DimCliente (ClaveCliente, RazonSocial, CalleNumero, Colonia, Ciudad, Estado, Pais, CodigoPostal, ClienteTipo, ClienteGrupo)
	SELECT C.Clave, C.RazonSocial, C.CalleNumero, C.Colonia, C.Ciudad, C.Estado, C.Pais, C.CodigoPostal, C.ClienteTipo, C.ClienteGrupo
	FROM AutopartesO2025.dbo.Cliente C
	WHERE NOT EXISTS(
		SELECT 1
		FROM RecomendacionProductosEntrada.dbo.DimCliente DC
		WHERE DC.ClaveCliente = C.Clave
	);

	PRINT 'Registros insertados en DimCliente'
END;
GO

EXECUTE PoblarDimCliente;

CREATE OR ALTER PROCEDURE PoblarDimArticulo
AS
BEGIN
    INSERT INTO DimArticulo (
        ClaveArticulo, Descripcion,
        ArticuloTipo, ArticuloTipoDescripcion,
        ArticuloGrupo, ArticuloGrupoDescripcion,
        ArticuloClase, ArticuloClaseDescripcion,
        Almacenable, Identificacion,
        UMedInv, UMedVenta, UMedCpa,
        Precio, pctDescuento,
        UbicacionAlmacen, UbicacionClave
    )
    SELECT 
        A.Clave, A.Descripcion,

        A.ArticuloTipo, AT.Descripcion,
        A.ArticuloGrupo, AG.Descripcion,
        A.ArticuloClase, AC.Descripcion,

        A.Almacenable, A.Identificacion,
        A.UMedInv, A.UMedVta, A.UMedCpa,
        A.Precio, A.pctDescuento,
        A.UbicacionAlmacen, A.UbicacionClave
    FROM AutopartesO2025.dbo.Articulo A
    LEFT JOIN AutopartesO2025.dbo.ArticuloTipo  AT ON AT.Clave  = A.ArticuloTipo
    LEFT JOIN AutopartesO2025.dbo.ArticuloGrupo AG ON AG.Clave  = A.ArticuloGrupo
    LEFT JOIN AutopartesO2025.dbo.ArticuloClase AC ON AC.Clave  = A.ArticuloClase
    WHERE NOT EXISTS (
        SELECT 1
        FROM DimArticulo DA
        WHERE DA.ClaveArticulo = A.Clave
    );

    PRINT 'Registros insertados en DimArticulo';
END;
GO

EXECUTE PoblarDimArticulo;

CREATE OR ALTER PROCEDURE PoblarDimArticuloRecomendado
AS
BEGIN
    INSERT INTO DimArticuloRecomendado (
        ClaveArticulo, Descripcion,
        ArticuloTipo, ArticuloTipoDescripcion,
        ArticuloGrupo, ArticuloGrupoDescripcion,
        ArticuloClase, ArticuloClaseDescripcion,
        Almacenable, Identificacion,
        UMedInv, UMedVenta, UMedCpa,
        Precio, pctDescuento,
        UbicacionAlmacen, UbicacionClave
    )
    SELECT 
        A.Clave, A.Descripcion,

        A.ArticuloTipo, AT.Descripcion,
        A.ArticuloGrupo, AG.Descripcion,
        A.ArticuloClase, AC.Descripcion,

        A.Almacenable, A.Identificacion,
        A.UMedInv, A.UMedVta, A.UMedCpa,
        A.Precio, A.pctDescuento,
        A.UbicacionAlmacen, A.UbicacionClave
    FROM AutopartesO2025.dbo.Articulo A
    LEFT JOIN AutopartesO2025.dbo.ArticuloTipo  AT ON AT.Clave  = A.ArticuloTipo
    LEFT JOIN AutopartesO2025.dbo.ArticuloGrupo AG ON AG.Clave  = A.ArticuloGrupo
    LEFT JOIN AutopartesO2025.dbo.ArticuloClase AC ON AC.Clave  = A.ArticuloClase
    WHERE NOT EXISTS (
        SELECT 1
        FROM DimArticuloRecomendado DAR
        WHERE DAR.ClaveArticulo = A.Clave
    );

    PRINT 'Registros insertados en DimArticuloRecomendado';
END;
GO

EXECUTE PoblarDimArticuloRecomendado;
