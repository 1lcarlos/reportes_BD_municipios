-- =========================================================
-- REGLA 37: Número de torres para Condominio.Matriz
-- =========================================================
-- Descripción:
-- Para predios con condición Condominio.Matriz (posición 22-30 = "800000000"),
-- el número de torres debe ser 0
-- =========================================================

-- Consulta que verifica el número de torres para Condominio.Matriz
SELECT
    p.t_id,
    p.numero_predial,
    cpt.ilicode AS condicion_predio,
    p.numero_torres,
    'Error: El número de torres debe ser 0 para Condominio.Matriz' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE cpt.ilicode = 'Condominio.Matriz'
  AND LENGTH(p.numero_predial) = 30
  AND SUBSTRING(p.numero_predial, 22, 9) = '800000000'
  AND COALESCE(p.numero_torres, 0) != 0;
