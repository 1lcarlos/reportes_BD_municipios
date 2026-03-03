-- =========================================================
-- REGLA 27: Área total construida privada para PH.Matriz
-- =========================================================
-- Descripción:
-- Para predios con condición PH.Matriz (posición 22-30 = "900000000"),
-- el área total construida privada debe ser la sumatoria de las
-- áreas de las unidades de construcción asociadas a las unidades
-- prediales.
-- =========================================================

-- Consulta que verifica el área construida privada para PH.Matriz
SELECT
    p.t_id,
    p.numero_predial,
    cpt.ilicode AS condicion_predio,
    p.area_total_construida_privada,
    calc.suma_areas_privadas,
    ABS(COALESCE(p.area_total_construida_privada, 0) - COALESCE(calc.suma_areas_privadas, 0)) AS diferencia,
    'Error: El área total construida privada no corresponde a la suma de áreas de unidades prediales' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
LEFT JOIN (
    SELECT
        cp.matriz AS matriz_id,
        SUM(uc.area_construida) AS suma_areas_privadas
    FROM cca_predio_copropiedad cp
    INNER JOIN cca_predio up ON up.t_id = cp.unidad_predial
    INNER JOIN cca_construccion c ON c.predio = up.t_id
    INNER JOIN cca_unidadconstruccion uc ON uc.construccion = c.t_id
    GROUP BY cp.matriz
) calc ON calc.matriz_id = p.t_id
WHERE cpt.ilicode = 'PH.Matriz'
  AND LENGTH(p.numero_predial) = 30
  AND SUBSTRING(p.numero_predial, 22, 9) = '900000000'
  AND ABS(COALESCE(p.area_total_construida_privada, 0) - COALESCE(calc.suma_areas_privadas, 0)) > 1;
