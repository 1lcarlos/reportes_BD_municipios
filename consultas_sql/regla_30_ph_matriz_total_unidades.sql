-- =========================================================
-- REGLA 30: Total de unidades privadas para PH.Matriz
-- =========================================================
-- Descripción:
-- Para predios con condición PH.Matriz (posición 22-30 = "900000000"),
-- el total de unidades privadas debe ser el conteo de predios
-- asociados al PH
-- =========================================================

-- Consulta que verifica el total de unidades privadas para PH.Matriz
SELECT
    matriz.t_id,
    matriz.numero_predial,
    cpt.ilicode AS condicion_predio,
    matriz.total_unidades_privadas,
    calc.conteo_unidades AS total_unidades_esperado,
    'Error: El total de unidades privadas no corresponde al conteo de predios asociados' AS mensaje_error
FROM cca_predio matriz
LEFT JOIN cca_condicionprediotipo cpt ON matriz.condicion_predio = cpt.t_id
LEFT JOIN (
    SELECT
        cp.matriz AS matriz_id,
        COUNT(cp.unidad_predial) AS conteo_unidades
    FROM cca_predio_copropiedad cp
    GROUP BY cp.matriz
) calc ON calc.matriz_id = matriz.t_id
WHERE cpt.ilicode = 'PH.Matriz'
  AND LENGTH(matriz.numero_predial) = 30
  AND SUBSTRING(matriz.numero_predial, 22, 9) = '900000000'
  AND COALESCE(matriz.total_unidades_privadas, 0) != COALESCE(calc.conteo_unidades, 0);
