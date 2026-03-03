-- =========================================================
-- REGLA 15: Validación de lotes sin unidades de construcción
-- =========================================================
-- Descripción:
-- Para predios con destinación económica: Lote_Urbanizado_No_Construido
-- o Lote_Rural, no se deben relacionar ni ubicar espacialmente
-- unidades de construcción
-- =========================================================

-- Consulta que identifica lotes que tienen unidades de construcción
SELECT
    p.t_id,
    p.numero_predial,
    det.ilicode AS destinacion_economica,
    COUNT(uc.t_id) AS cantidad_unidades_construccion,
    'Error: Predios con destinación Lote no deben tener unidades de construcción relacionadas' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_destinacioneconomicatipo det ON p.destinacion_economica = det.t_id
INNER JOIN cca_construccion c ON c.predio = p.t_id
INNER JOIN cca_unidadconstruccion uc ON uc.construccion = c.t_id
WHERE det.ilicode IN ('Lote_Urbanizado_No_Construido', 'Lote_Rural')
GROUP BY p.t_id, p.numero_predial, det.ilicode;
