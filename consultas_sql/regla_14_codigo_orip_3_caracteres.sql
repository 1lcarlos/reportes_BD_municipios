-- =========================================================
-- REGLA 14: Validación de código ORIP
-- =========================================================
-- Descripción:
-- El Codigo_ORIP asignado a cada una de las Matricula_inmobiliaria
-- debe estar asociado al dato del círculo registral (Tres caracteres)
-- =========================================================

-- Consulta que identifica códigos ORIP con formato incorrecto
SELECT
    p.t_id,
    p.numero_predial,
    p.codigo_orip,
    p.matricula_inmobiliaria,
    LENGTH(p.codigo_orip) AS longitud_codigo_orip,
    'Error: El código ORIP debe tener exactamente 3 caracteres' AS mensaje_error
FROM cca_predio p
WHERE p.matricula_inmobiliaria IS NOT NULL
  AND p.matricula_inmobiliaria != ''
  AND (
      p.codigo_orip IS NULL
      OR LENGTH(p.codigo_orip) != 3
  );
