-- =========================================================
-- REGLA 35: Área total construida privada para Condominio.Matriz
-- =========================================================
-- Descripción:
-- Para predios con condición Condominio.Matriz (posición 22-30 = "800000000"),
-- el área total construida privada debe ser la sumatoria de las
-- áreas de las unidades de construcción asociadas a las unidades prediales
-- =========================================================

-- Consulta que verifica el área construida privada para Condominio.Matriz
SELECT
    matriz.t_id,
    matriz.numero_predial,
    cpt.ilicode AS condicion_predio,
    matriz.area_total_construida_privada,
    calc.suma_areas_privadas AS area_privada_esperada,
    ABS(COALESCE(matriz.area_total_construida_privada, 0) - COALESCE(calc.suma_areas_privadas, 0)) AS diferencia,
    'Error: El área total construida privada no corresponde a la suma de unidades prediales' AS mensaje_error
FROM cca_predio matriz
LEFT JOIN cca_condicionprediotipo cpt ON matriz.condicion_predio = cpt.t_id
LEFT JOIN (
    SELECT
        cp.matriz AS matriz_id,
        SUM(uc.area_construida) AS suma_areas_privadas
    FROM cca_predio_copropiedad cp
    INNER JOIN cca_predio up ON up.t_id = cp.unidad_predial
    INNER JOIN cca_construccion c ON c.predio = up.t_id
    INNER JOIN cca_unidadconstruccion uc ON uc.construccion = c.t_id
    GROUP BY cp.matriz
) calc ON calc.matriz_id = matriz.t_id
WHERE cpt.ilicode = 'Condominio.Matriz'
  AND LENGTH(matriz.numero_predial) = 30
  AND SUBSTRING(matriz.numero_predial, 22, 9) = '800000000'
  AND ABS(COALESCE(matriz.area_total_construida_privada, 0) - COALESCE(calc.suma_areas_privadas, 0)) > 1;
