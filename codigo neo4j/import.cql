LOAD CSV WITH HEADERS FROM 'file:///Articulo.csv' AS row
MERGE (a:Articulo {clave: row.ClaveArticulo})
SET a.descripcion = row.Descripcion,
    a.tipo = row.ArticuloTipo,
    a.grupo = row.ArticuloGrupo,
    a.clase = row.ArticuloClase;
CREATE INDEX IF NOT EXISTS FOR (a:Articulo) ON (a.clave);

LOAD CSV WITH HEADERS FROM 'file:///Cliente.csv' AS row
MERGE (c:Cliente {clave: row.ClaveCliente})
SET c.razonSocial = row.RazonSocial;
CREATE INDEX IF NOT EXISTS FOR (c:Cliente) ON (c.clave);

LOAD CSV WITH HEADERS FROM 'file:///Vendedor.csv' AS row
MERGE (v:Vendedor {clave: row.ClaveVendedor})
SET v.nombre = row.NombreVendedor;
CREATE INDEX IF NOT EXISTS FOR (v:Vendedor) ON (v.clave);

LOAD CSV WITH HEADERS FROM 'file:///Fecha.csv' AS row
MERGE (f:Fecha {claveFecha: row.ClaveFecha})
SET f.fecha = row.Fecha;
CREATE INDEX IF NOT EXISTS FOR (f:Fecha) ON (f.claveFecha);

LOAD CSV WITH HEADERS FROM 'file:///Entrada.csv' AS row
MERGE (e:Entrada {folioEntrada: row.folioEntrada})
SET e.moneda = row.moneda,
    e.cliente = row.cliente,
    e.vendedor = row.vendedor,
    e.fecha = row.fecha,
    e.cantidadTotal = toFloat(row.cantidadTotal),
    e.promedioDescuento = toFloat(row.promedioDescuento),
    e.totalImporte = toFloat(row.totalImporte),
    e.totalDescuento = toFloat(row.totalDescuento),
    e.totalImpuesto = toFloat(row.totalImpuesto),
    e.total = toFloat(row.total),
    e.pctDescuentoGlobal = toFloat(row.pctDescuentoGlobal),
    e.numArticulos = toInteger(row.numArticulos),
    e.numPartidas = toInteger(row.numPartidas);
CREATE INDEX IF NOT EXISTS FOR (e:Entrada) ON (e.folioEntrada);

CALL apoc.periodic.iterate(
"
LOAD CSV WITH HEADERS FROM 'file:///Salida.csv' AS row
RETURN row
",
"
MERGE (s:Salida {folioSalida: trim(row.folioSalida)})
SET  s.cliente = trim(row.claveCliente),
     s.vendedor = trim(row.claveVendedor),
     s.fecha = trim(row.claveFecha),
     s.claveArticulo = trim(row.claveArticulo),
     s.cantidad = toFloat(row.cantidad),
     s.dpctDescuento = toFloat(row.dpctDescuento),
     s.totalImporte = toFloat(row.dTotalImporte),
     s.totalDescuento = toFloat(row.dTotalDescuento),
     s.totalImpuesto = toFloat(row.dTotalImpuesto),
     s.total = toFloat(row.dTotal)
",
{batchSize: 500, parallel: true});

CALL db.schema.visualization;