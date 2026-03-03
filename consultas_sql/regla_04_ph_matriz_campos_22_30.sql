-- =========================================================
-- REGLA 04: Validación de campos 22-30 para PH.Matriz
-- =========================================================
-- Descripción:
-- Los campos 22 a 30 del número predial nacional para predios con
-- condición de propiedad PH.Matriz se estandarizan como "900000000"
-- =========================================================

-- Consulta que identifica predios PH.Matriz que NO cumplen la regla
SELECT
    p.t_id,
    p.numero_predial,
    SUBSTRING(p.numero_predial, 22, 9) AS campos_22_30,
    '900000000' AS valor_esperado,
    cpt.ilicode AS condicion_predio,
    'Error: Los campos 22-30 del número predial para PH.Matriz deben ser "900000000"' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE cpt.ilicode = 'PH.Matriz'
  AND LENGTH(p.numero_predial) = 30
  AND SUBSTRING(p.numero_predial, 22, 9) != '900000000';
