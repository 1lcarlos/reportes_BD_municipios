-- =========================================================
-- REGLA 29: Número de torres para PH.Matriz
-- =========================================================
-- Descripción:
-- Para predios con condición PH.Matriz (posición 22-30 = "900000000"),
-- el número de torres debe ser igual al número máximo indicado
-- en las posiciones 25-26 del número predial de las unidades
-- asociadas al PH
-- =========================================================

-- Consulta que verifica el número de torres para PH.Matriz
SELECT
    matriz.t_id,
    matriz.numero_predial,
    cpt.ilicode AS condicion_predio,
    matriz.numero_torres,
    calc.max_torres AS numero_torres_esperado,
    'Error: El número de torres no corresponde al máximo de posiciones 25-26 de las unidades' AS mensaje_error
FROM cca_predio matriz
LEFT JOIN cca_condicionprediotipo cpt ON matriz.condicion_predio = cpt.t_id
LEFT JOIN (
    SELECT
        cp.matriz AS matriz_id,
        MAX(CAST(SUBSTRING(up.numero_predial, 25, 2) AS INTEGER)) AS max_torres
    FROM cca_predio_copropiedad cp
    INNER JOIN cca_predio up ON up.t_id = cp.unidad_predial
    WHERE LENGTH(up.numero_predial) = 30
      AND SUBSTRING(up.numero_predial, 25, 2) ~ '^[0-9]+$'
    GROUP BY cp.matriz
) calc ON calc.matriz_id = matriz.t_id
WHERE cpt.ilicode = 'PH.Matriz'
  AND LENGTH(matriz.numero_predial) = 30
  AND SUBSTRING(matriz.numero_predial, 22, 9) = '900000000'
  AND COALESCE(matriz.numero_torres, 0) != COALESCE(calc.max_torres, 0);
