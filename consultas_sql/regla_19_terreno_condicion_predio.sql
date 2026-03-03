-- =========================================================
-- REGLA 19: Validación de terreno por condición de predio
-- =========================================================
-- Descripción:
-- Los predios asociados a condiciones de propiedad NPH, PH.Matriz,
-- Condominio.Matriz, Condominio.Unidad_Predial, Via, Bien_Uso_Publico
-- o Parque_Cementerio deben estar representados con un único
-- elemento en la capa CCA_Terreno (excepto los que tienen novedad
-- de Cancelación).
-- Todos los CCA_Terreno deben estar asociados a un CCA_Predio
-- con las condiciones mencionadas.
-- =========================================================

-- Parte 1: Predios con condiciones especiales que tienen más de un terreno
SELECT
    p.t_id,
    p.numero_predial,
    cpt.ilicode AS condicion_predio,
    COUNT(t.t_id) AS cantidad_terrenos,
    'Error: Este tipo de predio debe tener un único terreno asociado' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
INNER JOIN cca_terreno t ON t.predio = p.t_id
WHERE cpt.ilicode IN (
    'NPH', 'PH.Matriz', 'Condominio.Matriz', 'Condominio.Unidad_Predial',
    'Via', 'Bien_Uso_Publico', 'Parque_Cementerio.Matriz', 'Parque_Cementerio.Unidad_Predial'
)
GROUP BY p.t_id, p.numero_predial, cpt.ilicode
HAVING COUNT(t.t_id) > 1

UNION ALL

-- Parte 2: Predios con condiciones especiales sin ningún terreno
SELECT
    p.t_id,
    p.numero_predial,
    cpt.ilicode AS condicion_predio,
    0 AS cantidad_terrenos,
    'Error: Este tipo de predio debe tener un terreno asociado' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE cpt.ilicode IN (
    'NPH', 'PH.Matriz', 'Condominio.Matriz', 'Condominio.Unidad_Predial',
    'Via', 'Bien_Uso_Publico', 'Parque_Cementerio.Matriz', 'Parque_Cementerio.Unidad_Predial'
)
AND NOT EXISTS (
    SELECT 1 FROM cca_terreno t WHERE t.predio = p.t_id
);
