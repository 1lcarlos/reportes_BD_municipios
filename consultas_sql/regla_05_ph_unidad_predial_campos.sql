-- =========================================================
-- REGLA 05: Validación de campos para PH.Unidad_Predial
-- =========================================================
-- Descripción:
-- El campo 22 del número predial para predios con condición de propiedad
-- PH.Unidad_Predial se estandariza como "9":
--   - Campo 22 = "9"
--   - Campos 23-24 no pueden ser "00"
--   - Campos 25-26 no pueden ser "00"
--   - Campos 27-30 no pueden ser "0000"
-- =========================================================

-- Consulta que identifica predios PH.Unidad_Predial que NO cumplen la regla
SELECT
    p.t_id,
    p.numero_predial,
    SUBSTRING(p.numero_predial, 22, 1) AS campo_22,
    SUBSTRING(p.numero_predial, 23, 2) AS campos_23_24,
    SUBSTRING(p.numero_predial, 25, 2) AS campos_25_26,
    SUBSTRING(p.numero_predial, 27, 4) AS campos_27_30,
    cpt.ilicode AS condicion_predio,
    CASE
        WHEN SUBSTRING(p.numero_predial, 22, 1) != '9'
            THEN 'Error: El campo 22 debe ser "9" para PH.Unidad_Predial'
        WHEN SUBSTRING(p.numero_predial, 23, 2) = '00'
            THEN 'Error: Los campos 23-24 no pueden ser "00"'
        WHEN SUBSTRING(p.numero_predial, 25, 2) = '00'
            THEN 'Error: Los campos 25-26 no pueden ser "00"'
        WHEN SUBSTRING(p.numero_predial, 27, 4) = '0000'
            THEN 'Error: Los campos 27-30 no pueden ser "0000"'
    END AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE cpt.ilicode = 'PH.Unidad_Predial'
  AND LENGTH(p.numero_predial) = 30
  AND (
      SUBSTRING(p.numero_predial, 22, 1) != '9'
      OR SUBSTRING(p.numero_predial, 23, 2) = '00'
      OR SUBSTRING(p.numero_predial, 25, 2) = '00'
      OR SUBSTRING(p.numero_predial, 27, 4) = '0000'
  );
