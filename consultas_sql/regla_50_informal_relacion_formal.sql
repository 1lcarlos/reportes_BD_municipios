-- =========================================================
-- REGLA 50: Predio informal debe relacionar predio formal
-- =========================================================
-- Descripción:
-- Todo predio informal debe relacionar un predio formal
-- mediante la tabla cca_predio_informalidad
-- =========================================================

-- Consulta que identifica predios informales sin relación a formal
SELECT
    p.t_id,
    p.numero_predial,
    cpt.ilicode AS condicion_predio,
    'Error: El predio informal debe estar relacionado a un predio formal' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE cpt.ilicode = 'Informal'
  AND NOT EXISTS (
      SELECT 1
      FROM cca_predio_informalidad pi
      WHERE pi.cca_predio_informal = p.t_id
  );
