-- =========================================================
-- REGLA 03: Validación de campos 14-17 y 18-21 del número predial
-- =========================================================
-- Descripción:
-- Los campos 14 al 17 ni del 18 al 21 del número predial nacional
-- pueden ser "0000"
-- =========================================================

-- Consulta que identifica predios que NO cumplen la regla
SELECT
    p.t_id,
    p.numero_predial,
    SUBSTRING(p.numero_predial, 14, 4) AS campos_14_17,
    SUBSTRING(p.numero_predial, 18, 4) AS campos_18_21,
    CASE
        WHEN SUBSTRING(p.numero_predial, 14, 4) = '0000' AND SUBSTRING(p.numero_predial, 18, 4) = '0000'
            THEN 'Error: Ambos campos (14-17 y 18-21) son "0000"'
        WHEN SUBSTRING(p.numero_predial, 14, 4) = '0000'
            THEN 'Error: Los campos 14-17 son "0000"'
        WHEN SUBSTRING(p.numero_predial, 18, 4) = '0000'
            THEN 'Error: Los campos 18-21 son "0000"'
    END AS mensaje_error
FROM cca_predio p
WHERE LENGTH(p.numero_predial) = 30
  AND (
      SUBSTRING(p.numero_predial, 14, 4) = '0000'
      OR SUBSTRING(p.numero_predial, 18, 4) = '0000'
  );
