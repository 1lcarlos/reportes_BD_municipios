-- =========================================================
-- REGLA 17: Validación de destinaciones que requieren construcción
-- =========================================================
-- Descripción:
-- Para predios con destinación económica: Comercial, Educativo,
-- Habitacional, Industrial, Institucional y Salubridad debe
-- relacionar espacialmente al menos una unidad de construcción
-- (Aplican excepciones cuando existen unidades de construcción
-- de predios informales sobre formales)
-- =========================================================

-- Consulta que identifica predios que requieren construcción pero no la tienen
SELECT
    p.t_id,
    p.numero_predial,
    det.ilicode AS destinacion_economica,
    cpt.ilicode AS condicion_predio,
    'Error: Predios con esta destinación económica deben tener al menos una unidad de construcción' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_destinacioneconomicatipo det ON p.destinacion_economica = det.t_id
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE det.ilicode IN (
    'Comercial', 'Educativo', 'Habitacional',
    'Industrial', 'Institucional', 'Salubridad'
)
AND NOT EXISTS (
    SELECT 1
    FROM cca_construccion c
    INNER JOIN cca_unidadconstruccion uc ON uc.construccion = c.t_id
    WHERE c.predio = p.t_id
)
-- Excluir predios que puedan tener construcciones de informales
AND NOT EXISTS (
    SELECT 1
    FROM cca_predio_informalidad pi
    WHERE pi.cca_predio_formal = p.t_id
);
