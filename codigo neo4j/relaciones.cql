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


//grafo de co-ocurrencias en SALIDAS
CALL apoc.periodic.iterate(
"
MATCH (s:Salida)
WITH s.folioSalida AS folio
RETURN folio
",
"
MATCH (s1:Salida {folioSalida: folio})
MATCH (s2:Salida {folioSalida: folio})
WHERE s1.claveArticulo < s2.claveArticulo  // evita duplicados tipo (A,B)/(B,A)

MATCH (a1:Articulo {claveArticulo: s1.claveArticulo})
MATCH (a2:Articulo {claveArticulo: s2.claveArticulo})

MERGE (a1)-[r:COOCURRE_SALIDA]->(a2)
ON CREATE SET r.vecesJuntos = 1
ON MATCH  SET r.vecesJuntos = r.vecesJuntos + 1
",
{batchSize:1000, parallel:false}
)
YIELD total, batches, errorMessages
RETURN total, batches, errorMessages;


CALL apoc.periodic.iterate(
"
MATCH
(a1:Articulo)<-[:CONTIENE]-(:Detalles)-[:PERTENECE]->(s:Salida),
(a2:Articulo)<-[:CONTIENE]-(:Detalles)-[:PERTENECE]->(s),
(t:ArticuloTipo)<-[:ES_DE_TIPO]-(a1)
WHERE a1 <> a2
  AND (a2)-[:ES_DE_TIPO]->(t)
RETURN
    a1.claveArticulo AS clave1,
    a2.claveArticulo AS clave2,
    t.claveTipo AS tipo,
    COUNT(*) AS veces
",
"
MATCH (a1:Articulo {claveArticulo: clave1})
MATCH (a2:Articulo {claveArticulo: clave2})
MERGE (a1)-[r:RECOMENDACION_TIPO]->(a2)
SET r.tipo = tipo,
    r.vecesJuntos = veces
",
{batchSize: 5000, parallel:false}
)
YIELD batches, total, errorMessages
RETURN batches, total, errorMessages;
