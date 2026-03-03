-- =========================================================
-- REGLA 10: Validación de campos 3-5 corresponden al Municipio
-- =========================================================
-- Descripción:
-- Los campos 3 a 5 del número predial deben corresponder al valor
-- diligenciado en Municipio (últimos 3 dígitos de Departamento_Municipio)
-- =========================================================

-- Consulta que identifica predios donde los campos 3-5 no corresponden al municipio
SELECT
    p.t_id,
    p.numero_predial,
    SUBSTRING(p.numero_predial, 3, 3) AS campos_3_5_numero_predial,
    SUBSTRING(p.departamento_municipio, 3, 3) AS municipio_esperado,
    p.departamento_municipio,
    'Error: Los campos 3-5 del número predial no corresponden al municipio' AS mensaje_error
FROM cca_predio p
WHERE LENGTH(p.numero_predial) = 30
  AND LENGTH(p.departamento_municipio) = 5
  AND SUBSTRING(p.numero_predial, 3, 3) != SUBSTRING(p.departamento_municipio, 3, 3);
