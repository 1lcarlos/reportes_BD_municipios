-- =========================================================
-- REGLA 13: Validación de formato de matrícula inmobiliaria
-- =========================================================
-- Descripción:
-- El valor registrado en Matricula_inmobiliaria debe ser lógico
-- (codificación completa) y no contener ningún carácter alfabético
-- =========================================================

-- Consulta que identifica matrículas con formato incorrecto
SELECT
    p.t_id,
    p.numero_predial,
    p.matricula_inmobiliaria,
    'Error: La matrícula inmobiliaria contiene caracteres no numéricos o tiene formato incorrecto' AS mensaje_error
FROM cca_predio p
WHERE p.matricula_inmobiliaria IS NOT NULL
  AND p.matricula_inmobiliaria != ''
  AND (
      -- Contiene caracteres alfabéticos (exceptuando guiones que pueden ser parte del formato)
      p.matricula_inmobiliaria ~ '[A-Za-z]'
      OR
      -- Verifica que después de quitar guiones solo queden números
      REPLACE(p.matricula_inmobiliaria, '-', '') !~ '^[0-9]+$'
  );
