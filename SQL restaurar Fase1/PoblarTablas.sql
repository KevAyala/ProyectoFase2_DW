----------------------------------------------------------
----------------------- DIMENSIONES ----------------------
----------------------------------------------------------
USE AutopartesProyecto;

------------------------- VENDEDOR -------------------------
CREATE OR ALTER PROCEDURE PoblarDimVendedor
AS
BEGIN
	INSERT INTO AutopartesProyecto.dbo.DimVendedor (ClaveVendedor, NombreVendedor)
	SELECT V.Clave, V.Nombre
	FROM AutopartesO2025.dbo.Vendedor V
	WHERE NOT EXISTS(
		SELECT 1
		FROM AutopartesProyecto.dbo.DimVendedor DV
		WHERE DV.ClaveVendedor  = V.Clave
	);

	PRINT 'Registros insertados en DimVendedor'
END;
GO

EXECUTE PoblarDimVendedor;
------------------------- ARTICULO -------------------------
CREATE OR ALTER PROCEDURE PoblarDimArticulo
AS
BEGIN
	INSERT INTO AutopartesProyecto.dbo.DimArticulo(ClaveArticulo, Descripcion, ArticuloTipo, ArticuloGrupo, ArticuloClase, Almacenable, Identificacion, UMedInv, UMedVenta, UMedCpa, Precio, pctDescuento, UbicacionAlmacen, UbicacionClave)
	SELECT A.clave, A.Descripcion, A.ArticuloTipo, A.ArticuloGrupo, A.ArticuloClase, A.Almacenable, A.Identificacion, A.UMedInv, A.UMedVta, A.UMedCpa, A.Precio, A.pctDescuento, A.UbicacionAlmacen, A.UbicacionClave
	FROM AutopartesO2025.dbo.Articulo A
	WHERE NOT EXISTS(
		SELECT 1
		FROM AutopartesProyecto.dbo.DimArticulo DA
		WHERE DA.ClaveArticulo = A.clave
	);

	PRINT 'Registros insertados en DimArticulo'
END;
GO

EXECUTE PoblarDimArticulo;

------------------------- FACTURA -------------------------
CREATE OR ALTER PROCEDURE PoblarDimFactura
AS
BEGIN
	INSERT INTO AutopartesProyecto.dbo.DimFactura (FolioFactura, CondicionDePago, MedioEmbarque, Moneda)
	SELECT FE.Folio, FE.CondicionPago, FE.MedioEmbarque, FE.Moneda
	FROM AutopartesO2025.dbo.FacturaEncabezado FE
	WHERE NOT EXISTS(
		SELECT 1
		FROM AutopartesProyecto.dbo.DimFactura DF
		WHERE DF.FolioFactura  = FE.Folio
	);

	PRINT 'Registros insertados en DimFactura'
END;
GO

EXECUTE PoblarDimFactura;

------------------------- CLIENTE -------------------------
CREATE OR ALTER PROCEDURE PoblarDimCliente
AS
BEGIN
	INSERT INTO AutopartesProyecto.dbo.DimCliente (ClaveCliente, RazonSocial, CalleNumero, Colonia, Ciudad, Estado, Pais, CodigoPostal, ClienteTipo, ClienteGrupo)
	SELECT C.Clave, C.RazonSocial, C.CalleNumero, C.Colonia, C.Ciudad, C.Estado, C.Pais, C.CodigoPostal, C.ClienteTipo, C.ClienteGrupo
	FROM AutopartesO2025.dbo.Cliente C
	WHERE NOT EXISTS(
		SELECT 1
		FROM AutopartesProyecto.dbo.DimCliente DC
		WHERE DC.ClaveCliente = C.Clave
	);

	PRINT 'Registros insertados en DimCliente'
END;
GO

EXECUTE PoblarDimCliente;

------------------------- FECHA -------------------------
CREATE OR ALTER PROCEDURE PoblarDimFecha
AS
BEGIN
    SET LANGUAGE Spanish;

    INSERT INTO AutopartesProyecto.dbo.DimFecha (ClaveFecha, Fecha, Año, Semestre, Trimestre, Cuatrimestre, Mes, NombreMes, Dia, NombreDia)
    SELECT 
        CONVERT(CHAR(10), f.Fecha, 112) AS ClaveFecha, -- YYYYMMDD
        f.Fecha,
        YEAR(f.Fecha) AS Año,
        CASE 
            WHEN MONTH(f.Fecha) BETWEEN 1 AND 6 THEN 1 ELSE 2
        END AS Semestre,
        CASE 
            WHEN MONTH(f.Fecha) BETWEEN 1 AND 3 THEN 1
            WHEN MONTH(f.Fecha) BETWEEN 4 AND 6 THEN 2
            WHEN MONTH(f.Fecha) BETWEEN 7 AND 9 THEN 3
            ELSE 4
        END AS Trimestre,
        CASE 
            WHEN MONTH(f.Fecha) BETWEEN 1 AND 4 THEN 1
            WHEN MONTH(f.Fecha) BETWEEN 5 AND 8 THEN 2
            ELSE 3
        END AS Cuatrimestre,
        MONTH(f.Fecha) AS Mes,
        DATENAME(MONTH, f.Fecha) AS NombreMes, 
        DAY(f.Fecha) AS Dia,
        DATENAME(WEEKDAY, f.Fecha) AS NombreDia 
    FROM AutopartesO2025.dbo.FacturaEncabezado f
    WHERE NOT EXISTS (
        SELECT 1 
        FROM DimFecha d 
        WHERE d.ClaveFecha = CONVERT(CHAR(10), f.Fecha, 112)
    )
    GROUP BY f.Fecha;

	PRINT 'Registros insertados en DimFecha'
END;
GO

EXECUTE PoblarDimFecha;

------------------------- ENTRADA -------------------------
CREATE OR ALTER PROCEDURE PoblarDimEntrada
AS
BEGIN
	INSERT INTO AutopartesProyecto.dbo.DimEntrada(FolioEntrada, Moneda)
	SELECT EC.Folio, EC.Moneda
	FROM AutopartesO2025.dbo.EntradaEncabezado EC
	WHERE NOT EXISTS(
		SELECT 1
		FROM AutopartesProyecto.dbo.DimEntrada DE
		WHERE DE.FolioEntrada  = EC.Folio
	);

	PRINT 'Registros insertados en DimVendedor'
END;
GO

EXECUTE PoblarDimEntrada;

------------------------- SALIDA -------------------------
CREATE OR ALTER PROCEDURE PoblarDimSalida
AS
BEGIN

    INSERT INTO AutopartesProyecto.dbo.DimSalida (
        FolioSalida,
        CondicionDePago,
        MedioEmbarque,
        Moneda
    )
    SELECT 
        SE.Folio AS FolioSalida,
        SE.CondicionPago,
        SE.MedioEmbarque,
        SE.Moneda
    FROM AutopartesO2025.dbo.SalidaEncabezado SE
    WHERE NOT EXISTS (
        SELECT 1 
        FROM AutopartesProyecto.dbo.DimSalida DS
        WHERE DS.FolioSalida = SE.Folio
    );

    PRINT 'Registros insertados en DimSalida correctamente';
END;
GO

EXECUTE PoblarDimSalida;


----------------------------------------------------------
------------------------- HECHOS -------------------------
----------------------------------------------------------

------------------------- FACTURA -------------------------
CREATE OR ALTER PROCEDURE PoblarFactFactura
AS
BEGIN
    INSERT INTO AutopartesProyecto.dbo.FactFactura
    (
        FolioFactura,
        ClaveArticulo,
        Partida,
        ClaveCliente,
        ClaveVendedor,
        ClaveFecha,
        Cantidad,
        dpctImpuesto,
        dTotalImporte,
        dTotalDescuento,
        dTotalImpuesto,
        dTotal,
        pctDescuentoGlobal,
        TotalImporte,
        TotalDescuento,
        TotalRetencion,
        Total,
        ContarFacturas
    )
    SELECT 
        FE.Folio AS FolioFactura,
        FD.Articulo AS ClaveArticulo,
        FD.Partida,
        FE.Cliente AS ClaveCliente,
        FE.Vendedor AS ClaveVendedor,
        CONVERT(CHAR(10), FE.Fecha, 112) AS ClaveFecha,
        FD.Cantidad,
        FD.pctImpuesto AS dpctImpuesto,
        FD.TotalImporte AS dTotalImporte,
        FD.TotalDescuento AS dTotalDescuento,
        FD.TotalImpuesto AS dTotalImpuesto,
        FD.Total AS dTotal,
        FE.pctDescuentoGlobal,
        FE.TotalImporte,
        FE.TotalDescuento,
        FE.TotalRetencion,
        FE.Total,
        CAST(1.0 / COUNT(*) OVER (PARTITION BY FE.Folio) AS DECIMAL(10,4)) AS ContarFacturas
    FROM AutopartesO2025.dbo.FacturaEncabezado FE
    INNER JOIN AutopartesO2025.dbo.FacturaDetalle FD
        ON FE.Folio = FD.Folio
    WHERE NOT EXISTS(
        SELECT 1
        FROM AutopartesProyecto.dbo.FactFactura FF
        WHERE FF.FolioFactura = FE.Folio
          AND FF.ClaveArticulo = FD.Articulo
          AND FF.Partida = FD.Partida
          AND FF.ClaveCliente = FE.Cliente
          AND FF.ClaveVendedor = FE.Vendedor
          AND FF.ClaveFecha = CONVERT(CHAR(10), FE.Fecha, 112)
    );

    PRINT 'Registros insertados en FactFactura correctamente';
END;
GO

EXEC PoblarFactFactura;
------------------------- ENTRADA -------------------------
CREATE OR ALTER PROCEDURE PoblarFactEntrada
AS
BEGIN
    -- Asegura que exista el registro genérico
    IF NOT EXISTS (SELECT 1 FROM AutopartesProyecto.dbo.DimVendedor WHERE ClaveVendedor = 'SIN_VEND')
    BEGIN
        INSERT INTO AutopartesProyecto.dbo.DimVendedor (ClaveVendedor, NombreVendedor)
        VALUES ('SIN_VEND', 'Vendedor desconocido');
    END;

    INSERT INTO AutopartesProyecto.dbo.FactEntrada
    (
        FolioEntrada,
        ClaveArticulo,
        Partida,
        ClaveCliente,
        ClaveVendedor,
        ClaveFecha,
        Cantidad,
        dpctDescuento,
        dTotalImporte,
        dTotalDescuento,
        dTotalImpuesto,
        dTotal,
        pctDescuentoGlobal,
        TotalImporte,
        TotalDescuento,
        TotalImpuesto,
        Total,
        ContarFolios
    )
    SELECT 
        EE.Folio AS FolioEntrada,
        ED.Articulo AS ClaveArticulo,
        ED.Partida,
        EE.Cliente AS ClaveCliente,
        ISNULL(EE.Vendedor, 'SIN_VEND') AS ClaveVendedor,
        CONVERT(CHAR(10), EE.Fecha, 112) AS ClaveFecha,
        ED.Cantidad,
        ED.pctDescuento AS dpctDescuento,
        ED.TotalImporte AS dTotalImporte,
        ED.TotalDescuento AS dTotalDescuento,
        ED.TotalImpuesto AS dTotalImpuesto,
        ED.Total AS dTotal,
        EE.pctDescuentoGlobal,
        EE.TotalImporte,
        EE.TotalDescuento,
        EE.TotalImpuesto,
        EE.Total,
        CAST(1.0 / COUNT(*) OVER (PARTITION BY EE.Folio) AS DECIMAL(10,4)) AS ContarFolios
    FROM AutopartesO2025.dbo.EntradaEncabezado EE
    INNER JOIN AutopartesO2025.dbo.EntradaDetalle ED
        ON EE.Folio = ED.Folio
    INNER JOIN AutopartesProyecto.dbo.DimVendedor DV ON DV.ClaveVendedor = ISNULL(EE.Vendedor, 'SIN_VEND')
    INNER JOIN AutopartesProyecto.dbo.DimCliente DC ON DC.ClaveCliente = EE.Cliente
    INNER JOIN AutopartesProyecto.dbo.DimArticulo DA ON DA.ClaveArticulo = ED.Articulo
    INNER JOIN AutopartesProyecto.dbo.DimFecha DF ON DF.ClaveFecha = CONVERT(CHAR(10), EE.Fecha, 112)
    INNER JOIN AutopartesProyecto.dbo.DimEntrada DE ON DE.FolioEntrada = EE.Folio
    WHERE NOT EXISTS(
        SELECT 1
        FROM AutopartesProyecto.dbo.FactEntrada FE
        WHERE FE.FolioEntrada = EE.Folio
          AND FE.ClaveArticulo = ED.Articulo
          AND FE.Partida = ED.Partida
          AND FE.ClaveCliente = EE.Cliente
          AND FE.ClaveVendedor = ISNULL(EE.Vendedor, 'SIN_VEND')
          AND FE.ClaveFecha = CONVERT(CHAR(10), EE.Fecha, 112)
    );

    PRINT 'Registros insertados en FactEntrada correctamente';
END;
GO

EXEC PoblarFactEntrada;

-------------------------  SALIDA -------------------------
CREATE OR ALTER PROCEDURE PoblarFactSalida
AS
BEGIN
    INSERT INTO AutopartesProyecto.dbo.FactSalida
    (
        FolioSalida,
        ClaveArticulo,
        Partida,
        ClaveCliente,
        ClaveVendedor,
        ClaveFecha,
        Cantidad,
        dpctDescuento,
        dTotalImporte,
        dTotalDescuento,
        dTotalImpuesto,
        dTotal,
        pctDescuentoGlobal,
        TotalImporte,
        TotalDescuento,
        TotalImpuesto,
        Total,
        ContarFolios
    )
    SELECT 
        SE.Folio AS FolioSalida,
        SD.Articulo AS ClaveArticulo,
        SD.Partida,
        SE.Cliente AS ClaveCliente,
        SE.Vendedor AS ClaveVendedor,
        CONVERT(CHAR(10), SE.Fecha, 112) AS ClaveFecha,
        SD.Cantidad,
        SD.pctDescuento AS dpctDescuento,
        SD.TotalImporte AS dTotalImporte,
        SD.TotalDescuento AS dTotalDescuento,
        SD.TotalImpuesto AS dTotalImpuesto,
        SD.Total AS dTotal,
        SE.pctDescuentoGlobal,
        SE.TotalImporte,
        SE.TotalDescuento,
        SE.TotalImpuesto,
        SE.Total,
        CAST(1.0 / COUNT(*) OVER (PARTITION BY SE.Folio) AS DECIMAL(10,4)) AS ContarFolios
    FROM AutopartesO2025.dbo.SalidaEncabezado SE
    INNER JOIN AutopartesO2025.dbo.SalidaDetalle SD
        ON SE.Folio = SD.Folio
    WHERE NOT EXISTS(
        SELECT 1
        FROM AutopartesProyecto.dbo.FactSalida FS
        WHERE FS.FolioSalida = SE.Folio
          AND FS.ClaveArticulo = SD.Articulo
          AND FS.Partida = SD.Partida
          AND FS.ClaveCliente = SE.Cliente
          AND FS.ClaveVendedor = SE.Vendedor
          AND FS.ClaveFecha = CONVERT(CHAR(10), SE.Fecha, 112)
    );

    PRINT 'Registros insertados en FactSalida correctamente';
END;
GO

EXEC PoblarFactSalida;

CREATE OR ALTER PROCEDURE PoblarTodo
AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Iniciando proceso de carga del Data Warehouse...';
    PRINT '---------------------------------------------';

    BEGIN TRY
        BEGIN TRANSACTION;

        PRINT 'Cargando dimensiones...';
        EXECUTE PoblarDimVendedor;
        PRINT 'DimVendedor completada.';

        EXECUTE PoblarDimArticulo;
        PRINT 'DimArticulo completada.';

        EXECUTE PoblarDimFactura;
        PRINT 'DimFactura completada.';

        EXECUTE PoblarDimCliente;
        PRINT 'DimCliente completada.';

        EXECUTE PoblarDimFecha;
        PRINT 'DimFecha completada.';

        EXECUTE PoblarDimEntrada;
        PRINT 'DimEntrada completada.';

        EXECUTE PoblarDimSalida;
        PRINT 'DimSalida completada.';

        PRINT '---------------------------------------------';
        PRINT 'Cargando tablas de hechos...';

        EXECUTE PoblarFactFactura;
        PRINT 'FactFactura completada.';

        EXECUTE PoblarFactSalida;
        PRINT 'FactSalida completada.';

        EXECUTE PoblarFactEntrada;
        PRINT 'FactEntrada completada.';

        COMMIT TRANSACTION;

        PRINT '---------------------------------------------';
        PRINT 'Carga completada exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT '---------------------------------------------';
        PRINT 'Error detectado. Realizando rollback...';
        ROLLBACK TRANSACTION;

        PRINT 'Error: ' + ERROR_MESSAGE();
        PRINT 'Número de error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Procedimiento: ' + ISNULL(ERROR_PROCEDURE(), 'Desconocido');
        PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END;
GO

EXEC PoblarTodo;
