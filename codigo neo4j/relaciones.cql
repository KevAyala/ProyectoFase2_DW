LOAD CSV WITH HEADERS FROM 'file:///Entrada.csv' AS row
MATCH (e:Entrada {folioEntrada: trim(row.folioEntrada)})
MATCH (c:Cliente {clave: trim(row.claveCliente)})
MERGE (c)-[:PROVOCA]->(e);

LOAD CSV WITH HEADERS FROM 'file:///Entrada.csv' AS row
MATCH (e:Entrada {folioEntrada: trim(row.folioEntrada)})
MATCH (v:Vendedor {clave: trim(row.claveVendedor)})
MERGE (v)-[:SUMINISTRA]->(e);

LOAD CSV WITH HEADERS FROM 'file:///Entrada.csv' AS row
MATCH (e:Entrada {folioEntrada: trim(row.folioEntrada)})
MATCH (f:Fecha {claveFecha: trim(row.claveFecha)})
MERGE (e)-[:OCURRE_EN]->(f);

LOAD CSV WITH HEADERS FROM 'file:///Entrada.csv' AS row
MATCH (e:Entrada {folioEntrada: trim(row.folioEntrada)})
MATCH (a:Articulo {clave: trim(row.claveArticulo)})
MERGE (e)-[r:CONTIENTE]->(a)
SET r.partida = toInteger(row.partida),
    r.cantidad = toFloat(row.cantidad),
    r.totalImporte = toFloat(row.dTotalImporte),
    r.totalDescuento = toFloat(row.dTotalDescuento),
    r.totalImpuesto = toFloat(row.dTotalImpuesto),
    r.total = toFloat(row.dTotal);

CALL apoc.periodic.iterate(
"
LOAD CSV WITH HEADERS FROM 'file:///Salida.csv' AS row
RETURN row
",
"
MATCH (s:Salida {folioSalida: trim(row.folioSalida)})
MATCH (c:Cliente {clave: trim(row.claveCliente)})
MERGE (c)-[:PROVOCA]->(s)
",
{batchSize: 500, parallel: true});

CALL apoc.periodic.iterate(
"
LOAD CSV WITH HEADERS FROM 'file:///Salida.csv' AS row
RETURN row
",
"
MATCH (s:Salida {folioSalida: trim(row.folioSalida)})
MATCH (v:Vendedor {clave: trim(row.claveVendedor)})
MERGE (v)-[:PROCESA]->(s)
",
{batchSize: 500, parallel: true});

CALL apoc.periodic.iterate(
"
LOAD CSV WITH HEADERS FROM 'file:///Salida.csv' AS row
RETURN row
",
"
MATCH (s:Salida {folioSalida: trim(row.folioSalida)})
MATCH (f:Fecha {claveFecha: trim(row.claveFecha)})
MERGE (s)-[:OCURRE_EN]->(f)
",
{batchSize: 500, parallel: true});

CALL apoc.periodic.iterate(
"
LOAD CSV WITH HEADERS FROM 'file:///Salida.csv' AS row
RETURN row
",
"
MATCH (s:Salida {folioSalida: trim(row.folioSalida)})
MATCH (a:Articulo {clave: trim(row.claveArticulo)})
MERGE (s)-[r:CONTIENTE]->(a)
SET  r.partida = toInteger(row.partida),
     r.cantidad = toFloat(row.cantidad),
     r.totalImporte = toFloat(row.dTotalImporte),
     r.totalDescuento = toFloat(row.dTotalDescuento),
     r.totalImpuesto = toFloat(row.dTotalImpuesto),
     r.total = toFloat(row.dTotal)
",
{batchSize: 500, parallel: true});

CALL db.schema.visualization;
