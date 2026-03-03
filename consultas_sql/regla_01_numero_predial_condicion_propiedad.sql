-- =========================================================
-- REGLA 01: Validación de campos 22 a 30 del número predial
--           según condición de propiedad
-- =========================================================
-- Descripción:
-- Los campos 22 a 30 del número predial nacional se estandarizan según
-- la condición de propiedad:
--   - NPH: "000000000"
--   - Bien de uso público: "300000000"
--   - Vía: "400000000"
--   - Parque cementerio: "700000000"
--   - Informal: "200000000"
-- =========================================================

-- Consulta que identifica predios que NO cumplen la regla
SELECT
    p.t_id,
    p.numero_predial,
    SUBSTRING(p.numero_predial, 22, 9) AS campos_22_30,
    cpt.ilicode AS condicion_predio,
    CASE
        WHEN cpt.ilicode = 'NPH' THEN '000000000'
        WHEN cpt.ilicode = 'Bien_Uso_Publico' THEN '300000000'
        WHEN cpt.ilicode = 'Via' THEN '400000000'
        WHEN cpt.ilicode LIKE 'Parque_Cementerio%' THEN '700000000'
        WHEN cpt.ilicode = 'Informal' THEN '200000000'
        ELSE NULL
    END AS valor_esperado,
    'Error: Los campos 22-30 del número predial no corresponden a la condición de propiedad' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE
    (
        -- NPH debe tener "000000000" en posiciones 22-30
        (cpt.ilicode = 'NPH' AND SUBSTRING(p.numero_predial, 22, 9) != '000000000')
        OR
        -- Bien de uso público debe tener "300000000" en posiciones 22-30
        (cpt.ilicode = 'Bien_Uso_Publico' AND SUBSTRING(p.numero_predial, 22, 9) != '300000000')
        OR
        -- Vía debe tener "400000000" en posiciones 22-30
        (cpt.ilicode = 'Via' AND SUBSTRING(p.numero_predial, 22, 9) != '400000000')
        OR
        -- Parque cementerio debe tener "700000000" en posiciones 22-30
        (cpt.ilicode LIKE 'Parque_Cementerio%' AND SUBSTRING(p.numero_predial, 22, 9) != '700000000')
        OR
        -- Informal debe tener "200000000" en posiciones 22-30
        (cpt.ilicode = 'Informal' AND SUBSTRING(p.numero_predial, 22, 9) != '200000000')
    )
    AND LENGTH(p.numero_predial) = 30;
