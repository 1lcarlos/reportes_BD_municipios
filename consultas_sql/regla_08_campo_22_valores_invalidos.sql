-- =========================================================
-- REGLA 08: Validación del campo 22 del número predial
-- =========================================================
-- Descripción:
-- El campo 22 del número predial debe ser diferente a "1", "5" y "6"
-- =========================================================

-- Consulta que identifica predios con campo 22 inválido
SELECT
    p.t_id,
    p.numero_predial,
    SUBSTRING(p.numero_predial, 22, 1) AS campo_22,
    'Error: El campo 22 del número predial no puede ser "1", "5" o "6"' AS mensaje_error
FROM cca_predio p
WHERE LENGTH(p.numero_predial) = 30
  AND SUBSTRING(p.numero_predial, 22, 1) IN ('1', '5', '6');
