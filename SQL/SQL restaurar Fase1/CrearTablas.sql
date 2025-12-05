USE AutopartesProyecto;
----------------------------------------------------------
----------------------- DIMENSIONES ----------------------
----------------------------------------------------------

CREATE TABLE DimArticulo(
	ClaveArticulo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS PRIMARY KEY,
	Descripcion VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloTipo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloGrupo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ArticuloClase CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
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

CREATE TABLE DimFecha(
	ClaveFecha CHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS PRIMARY KEY,
	Fecha DATETIME,
	Año INT,
	Semestre INT,
	Trimestre INT,
	Cuatrimestre INT,
	Mes INT,
	NombreMes VARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Dia INT,
	NombreDia VARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS
);

CREATE TABLE DimFactura(
	FolioFactura CHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS PRIMARY KEY,
	CondicionDePago CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	MedioEmbarque CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Moneda CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS
);

CREATE TABLE DimEntrada(
	FolioEntrada CHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS PRIMARY KEY,
	Moneda CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS
);

CREATE TABLE DimSalida(
	FolioSalida CHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS PRIMARY KEY,
	CondicionDePago CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	MedioEmbarque CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Moneda CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS
);

----------------------------------------------------------
------------------------- HECHOS -------------------------
----------------------------------------------------------

CREATE TABLE FactFactura(
	FolioFactura CHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	ClaveArticulo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,--DETALLE
	ClaveCliente CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	ClaveVendedor CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	ClaveFecha CHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    Partida INT NOT NULL, --DETALLE
	Cantidad NUMERIC(15,5), --DETALLE
	dpctImpuesto NUMERIC(8,5),--DETALLE
	dTotalImporte NUMERIC(15,5),--DETALLE
	dTotalDescuento NUMERIC(15,5),--DETALLE
	dTotalImpuesto NUMERIC(15,5),--DETALLE
	dTotal NUMERIC(15,5),--DETALLE
	pctDescuentoGlobal NUMERIC(8,5),
	TotalImporte INT,
	TotalDescuento INT,
	TotalRetencion INT,
	Total INT,
    ContarFacturas DECIMAL(10,4),
	PRIMARY KEY (FolioFactura, ClaveArticulo, ClaveCliente, ClaveVendedor, ClaveFecha, Partida),
    FOREIGN KEY (FolioFactura) REFERENCES DimFactura(FolioFactura),
    FOREIGN KEY (ClaveArticulo) REFERENCES DimArticulo(ClaveArticulo),
    FOREIGN KEY (ClaveCliente) REFERENCES DimCliente(ClaveCliente),
    FOREIGN KEY (ClaveVendedor) REFERENCES DimVendedor(ClaveVendedor),
    FOREIGN KEY (ClaveFecha) REFERENCES DimFecha(ClaveFecha)
);

CREATE TABLE FactEntrada(
    FolioEntrada CHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Partida INT NOT NULL,--Detalle
    ClaveFecha CHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    ClaveCliente CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
    ClaveVendedor CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
    ClaveArticulo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,--Detalle
    Cantidad NUMERIC(15,5), --Detalle
	dpctDescuento NUMERIC(8,5) NOT NULL,--Detalle
    dTotalImporte NUMERIC(15,5) NOT NULL,--Detalle
    dTotalDescuento NUMERIC(15,5) NOT NULL,--Detalle
    dTotalImpuesto NUMERIC(15,5) NOT NULL,--Detalle
    dTotal NUMERIC(15,5) NOT NULL,--Detalle
    pctDescuentoGlobal NUMERIC(8,5),
    TotalImporte NUMERIC(15,5),
    TotalDescuento NUMERIC(15,5),
    TotalImpuesto NUMERIC(15,5),
    Total NUMERIC(15,5),
    ContarFolios DECIMAL(10,4),
    PRIMARY KEY (FolioEntrada, ClaveArticulo, ClaveFecha, Partida),
	FOREIGN KEY (FolioEntrada) REFERENCES DimEntrada(FolioEntrada),
    FOREIGN KEY (ClaveArticulo) REFERENCES DimArticulo(ClaveArticulo),
    FOREIGN KEY (ClaveCliente) REFERENCES DimCliente(ClaveCliente),
    FOREIGN KEY (ClaveVendedor) REFERENCES DimVendedor(ClaveVendedor),
    FOREIGN KEY (ClaveFecha) REFERENCES DimFecha(ClaveFecha)
);

CREATE TABLE FactSalida(
    FolioSalida CHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Partida INT NOT NULL,--Detalle
    ClaveFecha CHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    ClaveCliente CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
    ClaveVendedor CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
    ClaveArticulo CHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,--Detalle
    Cantidad NUMERIC(15,5), --Detalle
	dpctDescuento NUMERIC(8,5) NOT NULL,--Detalle
    dTotalImporte NUMERIC(15,5) NOT NULL,--Detalle
    dTotalDescuento NUMERIC(15,5) NOT NULL,--Detalle
    dTotalImpuesto NUMERIC(15,5) NOT NULL,--Detalle
    dTotal NUMERIC(15,5) NOT NULL,--Detalle
    pctDescuentoGlobal NUMERIC(8,5),
    TotalImporte NUMERIC(15,5),
    TotalDescuento NUMERIC(15,5),
    TotalImpuesto NUMERIC(15,5),
    Total NUMERIC(15,5),
    ContarFolios DECIMAL(10,4),
    PRIMARY KEY (FolioSalida, ClaveArticulo, ClaveFecha, Partida),
	FOREIGN KEY (FolioSalida) REFERENCES DimSalida(FolioSalida),
    FOREIGN KEY (ClaveArticulo) REFERENCES DimArticulo(ClaveArticulo),
    FOREIGN KEY (ClaveCliente) REFERENCES DimCliente(ClaveCliente),
    FOREIGN KEY (ClaveVendedor) REFERENCES DimVendedor(ClaveVendedor),
    FOREIGN KEY (ClaveFecha) REFERENCES DimFecha(ClaveFecha)
);
