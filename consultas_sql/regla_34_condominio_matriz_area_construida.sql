-- =========================================================
-- REGLA 34: Área total construida para Condominio.Matriz
-- =========================================================
-- Descripción:
-- Para predios con condición Condominio.Matriz (posición 22-30 = "800000000"),
-- el área total construida debe ser la sumatoria de las áreas
-- de las unidades de construcción asociadas a unidades prediales
-- y al predio matriz
-- =========================================================

-- Consulta que verifica el área total construida para Condominio.Matriz
SELECT
    matriz.t_id,
    matriz.numero_predial,
    cpt.ilicode AS condicion_predio,
    matriz.area_total_construida,
    calc.suma_areas AS area_construida_esperada,
    ABS(COALESCE(matriz.area_total_construida, 0) - COALESCE(calc.suma_areas, 0)) AS diferencia,
    'Error: El área total construida no corresponde a la suma de unidades de construcción' AS mensaje_error
FROM cca_predio matriz
LEFT JOIN cca_condicionprediotipo cpt ON matriz.condicion_predio = cpt.t_id
LEFT JOIN (
    SELECT
        m.t_id AS matriz_id,
        COALESCE(
            (SELECT SUM(uc.area_construida)
             FROM cca_construccion c
             INNER JOIN cca_unidadconstruccion uc ON uc.construccion = c.t_id
             WHERE c.predio = m.t_id), 0
        ) +
        COALESCE(
            (SELECT SUM(uc2.area_construida)
             FROM cca_predio_copropiedad cp
             INNER JOIN cca_predio up ON up.t_id = cp.unidad_predial
             INNER JOIN cca_construccion c2 ON c2.predio = up.t_id
             INNER JOIN cca_unidadconstruccion uc2 ON uc2.construccion = c2.t_id
             WHERE cp.matriz = m.t_id), 0
        ) AS suma_areas
    FROM cca_predio m
    LEFT JOIN cca_condicionprediotipo cpt2 ON m.condicion_predio = cpt2.t_id
    WHERE cpt2.ilicode = 'Condominio.Matriz'
) calc ON calc.matriz_id = matriz.t_id
WHERE cpt.ilicode = 'Condominio.Matriz'
  AND LENGTH(matriz.numero_predial) = 30
  AND SUBSTRING(matriz.numero_predial, 22, 9) = '800000000'
  AND ABS(COALESCE(matriz.area_total_construida, 0) - COALESCE(calc.suma_areas, 0)) > 1;
