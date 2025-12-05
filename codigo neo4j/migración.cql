// =================================================================
// SCRIPT DE CARGA PARA NEO4J - ENTRADAS Y SALIDAS DE ALMACÉN
// =================================================================
// Orden: 1. Índices → 2. Nodos → 3. Relaciones
// Sin propiedades en relaciones

// =================================================================
// PASO 1: CREAR ÍNDICES
// =================================================================

// --- Índices principales (para claves únicas) ---
CREATE INDEX vendedor_clave IF NOT EXISTS
FOR (v:Vendedor) ON (v.claveVendedor);

CREATE INDEX cliente_clave IF NOT EXISTS
FOR (c:Cliente) ON (c.claveCliente);

CREATE INDEX articulo_clave IF NOT EXISTS
FOR (a:Articulo) ON (a.claveArticulo);

CREATE INDEX fecha_clave IF NOT EXISTS
FOR (f:Fecha) ON (f.claveFecha);

CREATE INDEX entrada_folio_partida IF NOT EXISTS
FOR (e:Entrada) ON (e.folioEntrada, e.partida);

CREATE INDEX salida_folio_partida IF NOT EXISTS
FOR (s:Salida) ON (s.folioSalida, s.partida);

// --- Índices adicionales para búsquedas frecuentes ---
CREATE INDEX articulo_tipo IF NOT EXISTS
FOR (a:Articulo) ON (a.articuloTipo);

CREATE INDEX articulo_grupo IF NOT EXISTS
FOR (a:Articulo) ON (a.articuloGrupo);

CREATE INDEX fecha_año_mes IF NOT EXISTS
FOR (f:Fecha) ON (f.año, f.mes);

CREATE INDEX cliente_tipo IF NOT EXISTS
FOR (c:Cliente) ON (c.clienteTipo);


// =================================================================
// PASO 2: CARGAR NODOS
// =================================================================

// --- 2.1 CARGAR VENDEDORES ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Vendedor.csv' AS row RETURN row",
  "MERGE (v:Vendedor {claveVendedor: row.ClaveVendedor})
   SET v.nombreVendedor = row.NombreVendedor",
  {batchSize: 10000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Vendedores cargados: ' + total AS resultado, errorMessages;

// --- 2.2 CARGAR CLIENTES ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Cliente.csv' AS row RETURN row",
  "MERGE (c:Cliente {claveCliente: row.ClaveCliente})
   SET c.ciudad = row.Ciudad,
       c.estado = row.Estado,
       c.pais = row.Pais,
       c.codigoPostal = row.CodigoPostal,
       c.clienteTipo = row.ClienteTipo,
       c.clienteGrupo = row.ClienteGrupo",
  {batchSize: 10000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Clientes cargados: ' + total AS resultado, errorMessages;

// --- 2.3 CARGAR ARTÍCULOS ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Articulo.csv' AS row RETURN row",
  "MERGE (a:Articulo {claveArticulo: row.ClaveArticulo})
   SET a.descripcion = row.Descripcion,
       a.articuloTipo = row.ArticuloTipo,
       a.articuloGrupo = row.ArticuloGrupo,
       a.articuloClase = row.ArticuloClase,
       a.almacenable = row.Almacenable,
       a.identificacion = row.Identificacion,
       a.umedInv = row.UMedInv,
       a.umedVenta = row.UMedVenta,
       a.umedCpa = row.UMedCpa,
       a.precio = toFloat(row.Precio),
       a.pctDescuento = toFloat(row.pctDescuento),
       a.ubicacionAlmacen = row.UbicacionAlmacen,
       a.ubicacionClave = row.UbicacionClave",
  {batchSize: 10000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Artículos cargados: ' + total AS resultado, errorMessages;

// --- 2.4 CARGAR FECHAS ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Fecha.csv' AS row RETURN row",
  "MERGE (f:Fecha {claveFecha: row.ClaveFecha})
   SET f.fecha = date(datetime(row.Fecha)),
       f.año = toInteger(row.Año),
       f.semestre = toInteger(row.Semestre),
       f.trimestre = toInteger(row.Trimestre),
       f.cuatrimestre = toInteger(row.Cuatrimestre),
       f.mes = toInteger(row.Mes),
       f.nombreMes = row.NombreMes,
       f.dia = toInteger(row.Dia),
       f.nombreDia = row.NombreDia",
  {batchSize: 10000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Fechas cargadas: ' + total AS resultado, errorMessages;

// --- 2.5 CARGAR NODOS ENTRADA ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Entrada.csv' AS row RETURN row",
  "MERGE (e:Entrada {folioEntrada: row.folioEntrada, partida: toInteger(row.partida)})
   SET e.claveFecha = row.claveFecha,
       e.claveCliente = row.claveCliente,
       e.claveVendedor = row.claveVendedor,
       e.claveArticulo = row.claveArticulo,
       e.cantidad = toFloat(row.cantidad),
       e.dpctDescuento = toFloat(row.dpctDescuento),
       e.dTotalImporte = toFloat(row.dTotalImporte),
       e.dTotalDescuento = toFloat(row.dTotalDescuento),
       e.dTotalImpuesto = toFloat(row.dTotalImpuesto),
       e.dTotal = toFloat(row.dTotal),
       e.pctDescuentoGlobal = toFloat(row.pctDescuentoGlobal),
       e.totalImporte = toFloat(row.totalImporte),
       e.totalDescuento = toFloat(row.totalDescuento),
       e.totalImpuesto = toFloat(row.totalImpuesto),
       e.total = toFloat(row.total),
       e.contarFolios = toFloat(row.contarFolios)",
  {batchSize: 10000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Nodos Entrada cargados: ' + total AS resultado, errorMessages;

// --- 2.6 CARGAR NODOS SALIDA ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Salida.csv' AS row RETURN row",
  "MERGE (s:Salida {folioSalida: row.folioSalida, partida: toInteger(row.partida)})
   SET s.claveFecha = row.claveFecha,
       s.claveCliente = row.claveCliente,
       s.claveVendedor = row.claveVendedor,
       s.claveArticulo = row.claveArticulo,
       s.cantidad = toFloat(row.cantidad),
       s.dpctDescuento = toFloat(row.dpctDescuento),
       s.dTotalImporte = toFloat(row.dTotalImporte),
       s.dTotalDescuento = toFloat(row.dTotalDescuento),
       s.dTotalImpuesto = toFloat(row.dTotalImpuesto),
       s.dTotal = toFloat(row.dTotal),
       s.pctDescuentoGlobal = toFloat(row.pctDescuentoGlobal),
       s.totalImporte = toFloat(row.totalImporte),
       s.totalDescuento = toFloat(row.totalDescuento),
       s.totalImpuesto = toFloat(row.totalImpuesto),
       s.total = toFloat(row.total),
       s.contarFolios = toFloat(row.contarFolios)",
  {batchSize: 10000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Nodos Salida cargados: ' + total AS resultado, errorMessages;


// =================================================================
// PASO 3: CREAR RELACIONES DE ENTRADAS
// =================================================================

// --- 3.1 RELACIÓN: Vendedor -> SUMINISTRA -> Entrada ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Entrada.csv' AS row RETURN row",
  "MATCH (v:Vendedor {claveVendedor: row.claveVendedor})
   MATCH (e:Entrada {folioEntrada: row.folioEntrada, partida: toInteger(row.partida)})
   MERGE (v)-[:SUMINISTRA]->(e)",
  {batchSize: 10000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Relaciones SUMINISTRA creadas: ' + total AS resultado, errorMessages;

// --- 3.2 RELACIÓN: Entrada -> CONTIENE -> Articulo ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Entrada.csv' AS row RETURN row",
  "MATCH (e:Entrada {folioEntrada: row.folioEntrada, partida: toInteger(row.partida)})
   MATCH (a:Articulo {claveArticulo: row.claveArticulo})
   MERGE (e)-[:CONTIENE]->(a)",
  {batchSize: 10000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Relaciones CONTIENE (Entrada) creadas: ' + total AS resultado, errorMessages;

// --- 3.3 RELACIÓN: Entrada -> OCURRE_EN -> Fecha ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Entrada.csv' AS row RETURN row",
  "MATCH (e:Entrada {folioEntrada: row.folioEntrada, partida: toInteger(row.partida)})
   MATCH (f:Fecha {claveFecha: row.claveFecha})
   MERGE (e)-[:OCURRE_EN]->(f)",
  {batchSize: 10000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Relaciones OCURRE_EN (Entrada) creadas: ' + total AS resultado, errorMessages;


// =================================================================
// PASO 4: CREAR RELACIONES DE SALIDAS
// =================================================================

// --- 4.1 RELACIÓN: Cliente -> PROVOCA -> Salida ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Salida.csv' AS row RETURN row",
  "MATCH (c:Cliente {claveCliente: row.claveCliente})
   MATCH (s:Salida {folioSalida: row.folioSalida, partida: toInteger(row.partida)})
   MERGE (c)-[:PROVOCA]->(s)",
  {batchSize: 10000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Relaciones PROVOCA creadas: ' + total AS resultado, errorMessages;

// --- 4.2 RELACIÓN: Vendedor -> PROCESA -> Salida ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Salida.csv' AS row RETURN row",
  "MATCH (v:Vendedor {claveVendedor: row.claveVendedor})
   MATCH (s:Salida {folioSalida: row.folioSalida, partida: toInteger(row.partida)})
   MERGE (v)-[:PROCESA]->(s)",
  {batchSize: 10000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Relaciones PROCESA creadas: ' + total AS resultado, errorMessages;

// --- 4.3 RELACIÓN: Salida -> CONTIENE -> Articulo ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Salida.csv' AS row RETURN row",
  "MATCH (s:Salida {folioSalida: row.folioSalida, partida: toInteger(row.partida)})
   MATCH (a:Articulo {claveArticulo: row.claveArticulo})
   MERGE (s)-[:CONTIENE]->(a)",
  {batchSize: 10000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Relaciones CONTIENE (Salida) creadas: ' + total AS resultado, errorMessages;

// --- 4.4 RELACIÓN: Salida -> OCURRE_EN -> Fecha ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Salida.csv' AS row RETURN row",
  "MATCH (s:Salida {folioSalida: row.folioSalida, partida: toInteger(row.partida)})
   MATCH (f:Fecha {claveFecha: row.claveFecha})
   MERGE (s)-[:OCURRE_EN]->(f)",
  {batchSize: 10000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Relaciones OCURRE_EN (Salida) creadas: ' + total AS resultado, errorMessages;


// =================================================================
//  VERIFICACIÓN DE CARGA
// =================================================================

// Contar nodos cargados
MATCH (v:Vendedor) RETURN 'Vendedores' AS tipo, COUNT(v) AS total
UNION
MATCH (c:Cliente) RETURN 'Clientes' AS tipo, COUNT(c) AS total
UNION
MATCH (a:Articulo) RETURN 'Artículos' AS tipo, COUNT(a) AS total
UNION
MATCH (f:Fecha) RETURN 'Fechas' AS tipo, COUNT(f) AS total
UNION
MATCH (e:Entrada) RETURN 'Entradas' AS tipo, COUNT(e) AS total
UNION
MATCH (s:Salida) RETURN 'Salidas' AS tipo, COUNT(s) AS total;

// Contar relaciones creadas
MATCH ()-[r:SUMINISTRA]->() RETURN 'SUMINISTRA' AS relacion, COUNT(r) AS total
UNION
MATCH ()-[r:PROVOCA]->() RETURN 'PROVOCA' AS relacion, COUNT(r) AS total
UNION
MATCH ()-[r:PROCESA]->() RETURN 'PROCESA' AS relacion, COUNT(r) AS total
UNION
MATCH ()-[r:CONTIENE]->() RETURN 'CONTIENE' AS relacion, COUNT(r) AS total
UNION
MATCH ()-[r:OCURRE_EN]->() RETURN 'OCURRE_EN' AS relacion, COUNT(r) AS total;
