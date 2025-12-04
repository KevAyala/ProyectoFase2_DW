// =================================================================
// RECOMENDACIONES SOLICITADAS
// =================================================================

// ---------------------------------------------------------------
// ENTRADAS - 1. Artículos que aparecen juntos en folios
// ---------------------------------------------------------------
// Dado un artículo A, recomienda artículos B que aparecen 
// frecuentemente en los mismos folios de entrada

MATCH (e1:Entrada)-[:CONTIENE]->(a1:Articulo)
MATCH (e2:Entrada)-[:CONTIENE]->(a2:Articulo)
WHERE e1.folioEntrada = e2.folioEntrada 
  AND a1.claveArticulo < a2.claveArticulo
WITH a1.claveArticulo AS articuloA,
     a2.claveArticulo AS articuloB,
     COUNT(DISTINCT e1.folioEntrada) AS vecesJuntos
WHERE vecesJuntos >= 2
RETURN articuloA,
       articuloB,
       vecesJuntos
ORDER BY articuloA, vecesJuntos DESC;

// ---------------------------------------------------------------
// ENTRADAS - 2. Artículos del mismo tipo
// ---------------------------------------------------------------
// Dado un artículo A, recomienda artículos B del mismo tipo

MATCH (a1:Articulo)
MATCH (a2:Articulo)
WHERE a1.articuloTipo = a2.articuloTipo
  AND a1.claveArticulo < a2.claveArticulo
OPTIONAL MATCH (e:Entrada)-[:CONTIENE]->(a2)
WITH a1.claveArticulo AS articuloA,
     a1.descripcion AS descripcionA,
     a1.articuloTipo AS tipo,
     a2.claveArticulo AS articuloB,
     a2.descripcion AS descripcionB,
     a2.precio AS precioB,
     COUNT(DISTINCT e) AS frecuenciaEntrada
RETURN articuloA,
       descripcionA,
       tipo,
       articuloB,
       descripcionB,
       precioB,
       frecuenciaEntrada
ORDER BY articuloA, frecuenciaEntrada DESC;


// ---------------------------------------------------------------
// SALIDAS - 3. Artículos que aparecen juntos en folios
// ---------------------------------------------------------------
// Dado un artículo A, recomienda artículos B que los clientes
// compran frecuentemente juntos

MATCH (s1:Salida)-[:CONTIENE]->(a1:Articulo)
MATCH (s2:Salida)-[:CONTIENE]->(a2:Articulo)
WHERE s1.folioSalida = s2.folioSalida 
  AND a1.claveArticulo < a2.claveArticulo
WITH a1.claveArticulo AS articuloA,
     a1.descripcion AS descripcionA,
     a2.claveArticulo AS articuloB,
     a2.descripcion AS descripcionB,
     COUNT(DISTINCT s1.folioSalida) AS vecesJuntos
WHERE vecesJuntos >= 2
RETURN articuloA,
       descripcionA,
       articuloB,
       descripcionB,
       vecesJuntos
ORDER BY articuloA, vecesJuntos DESC;