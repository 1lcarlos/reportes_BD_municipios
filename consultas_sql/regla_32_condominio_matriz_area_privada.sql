-- =========================================================
-- REGLA 32: Área total terreno privada para Condominio.Matriz
-- =========================================================
-- Descripción:
-- Para predios con condición Condominio.Matriz (posición 22-30 = "800000000"),
-- el área total terreno_privada debe corresponder a la sumatoria
-- de las áreas geográficas de las unidades privadas asociadas al Condominio
-- =========================================================

-- Consulta que verifica el área terreno privada para Condominio.Matriz
SELECT
    matriz.t_id,
    matriz.numero_predial,
    cpt.ilicode AS condicion_predio,
    matriz.area_total_terreno_privada,
    calc.suma_areas_privadas AS area_privada_esperada,
    ABS(COALESCE(matriz.area_total_terreno_privada, 0) - COALESCE(calc.suma_areas_privadas, 0)) AS diferencia,
    'Error: El área total terreno privada no corresponde a la suma de áreas de unidades' AS mensaje_error
FROM cca_predio matriz
LEFT JOIN cca_condicionprediotipo cpt ON matriz.condicion_predio = cpt.t_id
LEFT JOIN (
    SELECT
        cp.matriz AS matriz_id,
        SUM(t.area_terreno) AS suma_areas_privadas
    FROM cca_predio_copropiedad cp
    INNER JOIN cca_predio up ON up.t_id = cp.unidad_predial
    INNER JOIN cca_terreno t ON t.predio = up.t_id
    GROUP BY cp.matriz
) calc ON calc.matriz_id = matriz.t_id
WHERE cpt.ilicode = 'Condominio.Matriz'
  AND LENGTH(matriz.numero_predial) = 30
  AND SUBSTRING(matriz.numero_predial, 22, 9) = '800000000'
  AND ABS(COALESCE(matriz.area_total_terreno_privada, 0) - COALESCE(calc.suma_areas_privadas, 0)) > 1;
