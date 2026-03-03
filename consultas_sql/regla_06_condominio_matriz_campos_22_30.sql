-- =========================================================
-- REGLA 06: Validación de campos 22-30 para Condominio.Matriz
-- =========================================================
-- Descripción:
-- Los campos 22 a 30 del número predial para predios con condición
-- de propiedad Condominio.Matriz se estandarizan como "800000000"
-- =========================================================

-- Consulta que identifica predios Condominio.Matriz que NO cumplen la regla
SELECT
    p.t_id,
    p.numero_predial,
    SUBSTRING(p.numero_predial, 22, 9) AS campos_22_30,
    '800000000' AS valor_esperado,
    cpt.ilicode AS condicion_predio,
    'Error: Los campos 22-30 del número predial para Condominio.Matriz deben ser "800000000"' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE cpt.ilicode = 'Condominio.Matriz'
  AND LENGTH(p.numero_predial) = 30
  AND SUBSTRING(p.numero_predial, 22, 9) != '800000000';
