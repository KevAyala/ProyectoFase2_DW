// =================================================================
// RECOMENDACIONES - CONSULTAS PARA EXPORTAR
// =================================================================

// ---------------------------------------------------------------
// ENTRADAS - 1. Artículos que aparecen juntos en folios
// ---------------------------------------------------------------
// Resultado: Articulo1, Articulo2, FoliosJuntos

MATCH (e1:Entrada)-[:CONTIENE]->(a1:Articulo)
MATCH (e2:Entrada)-[:CONTIENE]->(a2:Articulo)
WHERE e1.folioEntrada = e2.folioEntrada 
  AND a1.claveArticulo < a2.claveArticulo
WITH a1.claveArticulo AS Articulo1,
     a2.claveArticulo AS Articulo2,
     COUNT(DISTINCT e1.folioEntrada) AS FoliosJuntos
WHERE FoliosJuntos >= 2
RETURN Articulo1,
       Articulo2,
       FoliosJuntos
ORDER BY FoliosJuntos DESC;

CALL apoc.export.csv.query(
  "MATCH (e1:Entrada)-[:CONTIENE]->(a1:Articulo)
   MATCH (e2:Entrada)-[:CONTIENE]->(a2:Articulo)
   WHERE e1.folioEntrada = e2.folioEntrada 
     AND a1.claveArticulo < a2.claveArticulo
   WITH a1.claveArticulo AS Articulo1,
        a2.claveArticulo AS Articulo2,
        COUNT(DISTINCT e1.folioEntrada) AS FoliosJuntos
   WHERE FoliosJuntos >= 2
   RETURN Articulo1, Articulo2, FoliosJuntos
   ORDER BY Articulo1, FoliosJuntos DESC",
  "RecomendacionesEntradas.csv",
  {stream: true, batchSize: 10000}
);


// ---------------------------------------------------------------
// ENTRADAS - 2. Artículos del mismo tipo que aparecen juntos
// ---------------------------------------------------------------
// Resultado: Articulo1, Articulo2, Tipo, FoliosJuntos

MATCH (e1:Entrada)-[:CONTIENE]->(a1:Articulo)
MATCH (e2:Entrada)-[:CONTIENE]->(a2:Articulo)
WHERE e1.folioEntrada = e2.folioEntrada 
  AND a1.articuloTipo = a2.articuloTipo
  AND a1.claveArticulo < a2.claveArticulo
WITH a1.claveArticulo AS Articulo1,
     a2.claveArticulo AS Articulo2,
     a1.articuloTipo AS Tipo1,
      a2.articuloTipo AS Tipo2,
     COUNT(DISTINCT e1.folioEntrada) AS FoliosJuntos
WHERE FoliosJuntos >= 2
RETURN Articulo1,
       Articulo2,
       Tipo1,
       Tipo2,
       FoliosJuntos
ORDER BY FoliosJuntos DESC;

CALL apoc.export.csv.query(
  "MATCH (e1:Entrada)-[:CONTIENE]->(a1:Articulo)
   MATCH (e2:Entrada)-[:CONTIENE]->(a2:Articulo)
   WHERE e1.folioEntrada = e2.folioEntrada 
     AND a1.articuloTipo = a2.articuloTipo
     AND a1.claveArticulo < a2.claveArticulo
   WITH a1.claveArticulo AS Articulo1,
        a2.claveArticulo AS Articulo2,
        a1.articuloTipo AS Tipo,
        COUNT(DISTINCT e1.folioEntrada) AS FoliosJuntos
   WHERE FoliosJuntos >= 2
   RETURN Articulo1, Articulo2, Tipo, FoliosJuntos
   ORDER BY Articulo1, FoliosJuntos DESC",
  "RecomendacionesEntradasMismoTipo.csv",
  {stream: true, batchSize: 10000}
);


// ---------------------------------------------------------------
// SALIDAS - 3. Artículos que aparecen juntos en folios
// ---------------------------------------------------------------
// Resultado: Articulo1, Articulo2, FoliosJuntos

MATCH (s1:Salida)-[:CONTIENE]->(a1:Articulo)
MATCH (s2:Salida)-[:CONTIENE]->(a2:Articulo)
WHERE s1.folioSalida = s2.folioSalida 
  AND a1.claveArticulo < a2.claveArticulo
WITH a1.claveArticulo AS Articulo1,
     a2.claveArticulo AS Articulo2,
     COUNT(DISTINCT s1.folioSalida) AS FoliosJuntos
WHERE FoliosJuntos >= 2
RETURN Articulo1,
       Articulo2,
       FoliosJuntos
ORDER BY FoliosJuntos DESC;


// =================================================================
// CONSULTAS PARA UN ARTÍCULO ESPECÍFICO (TESTING)
// =================================================================

// ---------------------------------------------------------------
// ENTRADAS - Para un artículo específico (ej: 'SDPU81R')
// ---------------------------------------------------------------

// Opción 1: Artículos que aparecen juntos
MATCH (e1:Entrada)-[:CONTIENE]->(a1:Articulo {claveArticulo: '115-1101L'})
MATCH (e2:Entrada)-[:CONTIENE]->(a2:Articulo)
WHERE e1.folioEntrada = e2.folioEntrada 
  AND a1.claveArticulo <> a2.claveArticulo
WITH a1.claveArticulo AS Articulo1,
     a2.claveArticulo AS Articulo2,
     COUNT(DISTINCT e1.folioEntrada) AS FoliosJuntos
RETURN Articulo1,
       Articulo2,
       FoliosJuntos
ORDER BY FoliosJuntos DESC
LIMIT 10;

// Opción 2: Artículos del mismo tipo que aparecen juntos
MATCH (e1:Entrada)-[:CONTIENE]->(a1:Articulo {claveArticulo: 'SDPU81R'})
MATCH (e2:Entrada)-[:CONTIENE]->(a2:Articulo)
WHERE e1.folioEntrada = e2.folioEntrada 
  AND a1.articuloTipo = a2.articuloTipo
  AND a1.claveArticulo <> a2.claveArticulo
WITH a1.claveArticulo AS Articulo1,
     a2.claveArticulo AS Articulo2,
     a1.articuloTipo AS Tipo,
     COUNT(DISTINCT e1.folioEntrada) AS FoliosJuntos
RETURN Articulo1,
       Articulo2,
       Tipo,
       FoliosJuntos
ORDER BY FoliosJuntos DESC
LIMIT 10;


// ---------------------------------------------------------------
// SALIDAS - Para un artículo específico (ej: 'DDTPU84C2')
// ---------------------------------------------------------------

MATCH (s1:Salida)-[:CONTIENE]->(a1:Articulo {claveArticulo: 'DDTPU84C2'})
MATCH (s2:Salida)-[:CONTIENE]->(a2:Articulo)
WHERE s1.folioSalida = s2.folioSalida 
  AND a1.claveArticulo <> a2.claveArticulo
WITH a1.claveArticulo AS Articulo1,
     a2.claveArticulo AS Articulo2,
     COUNT(DISTINCT s1.folioSalida) AS FoliosJuntos
RETURN Articulo1,
       Articulo2,
       FoliosJuntos
ORDER BY FoliosJuntos DESC
LIMIT 10;