// =================================================================
// SCRIPT DE CARGA PARA NEO4J - ENTRADAS Y SALIDAS DE ALMACÉN
// =================================================================
// Usando APOC para grandes volúmenes de datos (medio millón de registros)
// Coloca tus CSV en: file:///nombre_archivo.csv
// O usa URL: 'https://...'

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

CREATE INDEX entrada_folio IF NOT EXISTS
FOR (e:Entrada) ON (e.folioEntrada);

CREATE INDEX entrada_partida IF NOT EXISTS
FOR (e:Entrada) ON (e.partida);

CREATE INDEX salida_folio IF NOT EXISTS
FOR (s:Salida) ON (s.folioSalida);

CREATE INDEX salida_partida IF NOT EXISTS
FOR (s:Salida) ON (s.partida);

// --- Índices compuestos para búsquedas combinadas ---
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
// PASO 2: CARGAR NODOS COMPARTIDOS (Vendedor, Cliente, Articulo, Fecha)
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


// =================================================================
// PASO 3: CARGAR GRAFO DE ENTRADAS
// =================================================================

// --- 3.1 CARGAR NODOS ENTRADA Y TODAS SUS RELACIONES ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Entrada.csv' AS row RETURN row",
  "
  // Crear nodo Entrada
  MERGE (e:Entrada {folioEntrada: row.folioEntrada, partida: toInteger(row.partida)})
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
      e.contarFolios = toFloat(row.contarFolios)
  
  // Relación: Vendedor -> SUMINISTRA -> Entrada
  WITH e, row
  MATCH (v:Vendedor {claveVendedor: row.claveVendedor})
  MERGE (v)-[r1:SUMINISTRA]->(e)
  
  // Relación: Entrada -> CONTIENE -> Articulo
  WITH e, row
  MATCH (a:Articulo {claveArticulo: row.claveArticulo})
  MERGE (e)-[r2:CONTIENE {
    cantidad: toFloat(row.cantidad),
    dpctDescuento: toFloat(row.dpctDescuento),
    dTotalImporte: toFloat(row.dTotalImporte),
    dTotalDescuento: toFloat(row.dTotalDescuento),
    dTotalImpuesto: toFloat(row.dTotalImpuesto),
    dTotal: toFloat(row.dTotal),
    partida: toInteger(row.partida)
  }]->(a)
  
  // Relación: Entrada -> OCURRE_EN -> Fecha
  WITH e, row
  MATCH (f:Fecha {claveFecha: row.claveFecha})
  MERGE (e)-[r3:OCURRE_EN]->(f)
  ",
  {batchSize: 5000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Entradas procesadas: ' + total AS resultado, errorMessages;


// =================================================================
// PASO 4: CARGAR GRAFO DE SALIDAS
// =================================================================

// --- 4.1 CARGAR NODOS SALIDA Y TODAS SUS RELACIONES ---
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///Salida.csv' AS row RETURN row",
  "
  // Crear nodo Salida
  MERGE (s:Salida {folioSalida: row.folioSalida, partida: toInteger(row.partida)})
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
      s.contarFolios = toFloat(row.contarFolios)
  
  // Relación: Cliente -> PROVOCA -> Salida
  WITH s, row
  MATCH (c:Cliente {claveCliente: row.claveCliente})
  MERGE (c)-[r1:PROVOCA]->(s)
  
  // Relación: Vendedor -> PROCESA -> Salida
  WITH s, row
  MATCH (v:Vendedor {claveVendedor: row.claveVendedor})
  MERGE (v)-[r2:PROCESA]->(s)
  
  // Relación: Salida -> CONTIENE -> Articulo
  WITH s, row
  MATCH (a:Articulo {claveArticulo: row.claveArticulo})
  MERGE (s)-[r3:CONTIENE {
    cantidad: toFloat(row.cantidad),
    dpctDescuento: toFloat(row.dpctDescuento),
    dTotalImporte: toFloat(row.dTotalImporte),
    dTotalDescuento: toFloat(row.dTotalDescuento),
    dTotalImpuesto: toFloat(row.dTotalImpuesto),
    dTotal: toFloat(row.dTotal),
    partida: toInteger(row.partida)
  }]->(a)
  
  // Relación: Salida -> OCURRE_EN -> Fecha
  WITH s, row
  MATCH (f:Fecha {claveFecha: row.claveFecha})
  MERGE (s)-[r4:OCURRE_EN]->(f)
  ",
  {batchSize: 5000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN 'Salidas procesadas: ' + total AS resultado, errorMessages;


// =================================================================
// PASO 5: VERIFICACIÓN DE CARGA
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

