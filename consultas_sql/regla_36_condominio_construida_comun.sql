-- =========================================================
-- REGLA 36: Área total construida común para Condominio.Matriz
-- =========================================================
-- Descripción:
-- Para predios con condición Condominio.Matriz (posición 22-30 = "800000000"),
-- el área total construida común debe ser la sumatoria de las
-- áreas de las unidades asociadas al Condominio Matriz
-- =========================================================

-- Consulta que verifica el área construida común para Condominio.Matriz
SELECT
    p.t_id,
    p.numero_predial,
    cpt.ilicode AS condicion_predio,
    p.area_total_construida_comun,
    calc.suma_areas_comunes AS area_comun_esperada,
    ABS(COALESCE(p.area_total_construida_comun, 0) - COALESCE(calc.suma_areas_comunes, 0)) AS diferencia,
    'Error: El área total construida común no corresponde a la suma de unidades del matriz' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
LEFT JOIN (
    SELECT
        c.predio AS matriz_id,
        SUM(uc.area_construida) AS suma_areas_comunes
    FROM cca_construccion c
    INNER JOIN cca_unidadconstruccion uc ON uc.construccion = c.t_id
    INNER JOIN cca_predio pr ON pr.t_id = c.predio
    LEFT JOIN cca_condicionprediotipo cpt2 ON pr.condicion_predio = cpt2.t_id
    WHERE cpt2.ilicode = 'Condominio.Matriz'
    GROUP BY c.predio
) calc ON calc.matriz_id = p.t_id
WHERE cpt.ilicode = 'Condominio.Matriz'
  AND LENGTH(p.numero_predial) = 30
  AND SUBSTRING(p.numero_predial, 22, 9) = '800000000'
  AND ABS(COALESCE(p.area_total_construida_comun, 0) - COALESCE(calc.suma_areas_comunes, 0)) > 1;
