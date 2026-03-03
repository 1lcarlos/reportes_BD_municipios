-- =========================================================
-- REGLA 26: Área total construida para PH.Matriz
-- =========================================================
-- Descripción:
-- Para predios con condición PH.Matriz (posición 22-30 = "900000000"),
-- el área total construida debe ser la sumatoria de las áreas de
-- las unidades de construcción asociadas a las unidades prediales
-- y de las unidades de construcción asociadas al predio matriz.
-- =========================================================

-- Consulta que verifica el área total construida para PH.Matriz
SELECT
    p.t_id,
    p.numero_predial,
    cpt.ilicode AS condicion_predio,
    p.area_total_construida,
    calc.suma_areas_construidas,
    ABS(COALESCE(p.area_total_construida, 0) - COALESCE(calc.suma_areas_construidas, 0)) AS diferencia,
    'Error: El área total construida no corresponde a la suma de áreas de unidades de construcción' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
LEFT JOIN (
    -- Suma de áreas de construcción del predio matriz
    SELECT
        matriz.t_id AS matriz_id,
        COALESCE(SUM(uc.area_construida), 0) +
        COALESCE((
            SELECT SUM(uc2.area_construida)
            FROM cca_predio_copropiedad cp2
            INNER JOIN cca_predio up2 ON up2.t_id = cp2.unidad_predial
            INNER JOIN cca_construccion c2 ON c2.predio = up2.t_id
            INNER JOIN cca_unidadconstruccion uc2 ON uc2.construccion = c2.t_id
            WHERE cp2.matriz = matriz.t_id
        ), 0) AS suma_areas_construidas
    FROM cca_predio matriz
    LEFT JOIN cca_condicionprediotipo cpt2 ON matriz.condicion_predio = cpt2.t_id
    LEFT JOIN cca_construccion c ON c.predio = matriz.t_id
    LEFT JOIN cca_unidadconstruccion uc ON uc.construccion = c.t_id
    WHERE cpt2.ilicode = 'PH.Matriz'
    GROUP BY matriz.t_id
) calc ON calc.matriz_id = p.t_id
WHERE cpt.ilicode = 'PH.Matriz'
  AND LENGTH(p.numero_predial) = 30
  AND SUBSTRING(p.numero_predial, 22, 9) = '900000000'
  AND ABS(COALESCE(p.area_total_construida, 0) - COALESCE(calc.suma_areas_construidas, 0)) > 1;
