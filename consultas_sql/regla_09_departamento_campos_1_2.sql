-- =========================================================
-- REGLA 09: Validación de campos 1-2 corresponden al Departamento
-- =========================================================
-- Descripción:
-- Los campos 1 y 2 del número predial deben corresponder al valor
-- diligenciado en el campo Departamento (primeros 2 dígitos de
-- Departamento_Municipio)
-- =========================================================

-- Consulta que identifica predios donde los campos 1-2 no corresponden al departamento
SELECT
    p.t_id,
    p.numero_predial,
    SUBSTRING(p.numero_predial, 1, 2) AS campos_1_2_numero_predial,
    SUBSTRING(p.departamento_municipio, 1, 2) AS departamento_esperado,
    p.departamento_municipio,
    'Error: Los campos 1-2 del número predial no corresponden al departamento' AS mensaje_error
FROM cca_predio p
WHERE LENGTH(p.numero_predial) = 30
  AND LENGTH(p.departamento_municipio) = 5
  AND SUBSTRING(p.numero_predial, 1, 2) != SUBSTRING(p.departamento_municipio, 1, 2);
