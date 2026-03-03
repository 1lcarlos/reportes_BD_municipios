-- =========================================================
-- REGLA 07: Validación de campos para Condominio.Unidad_Predial
-- =========================================================
-- Descripción:
-- Los campos 22 al 26 del número predial para predios con condición
-- de propiedad Condominio.Unidad_Predial se estandarizan como "80000"
-- y los campos del 27 al 30 deben ser diferentes a "0000"
-- =========================================================

-- Consulta que identifica predios Condominio.Unidad_Predial que NO cumplen la regla
SELECT
    p.t_id,
    p.numero_predial,
    SUBSTRING(p.numero_predial, 22, 5) AS campos_22_26,
    SUBSTRING(p.numero_predial, 27, 4) AS campos_27_30,
    cpt.ilicode AS condicion_predio,
    CASE
        WHEN SUBSTRING(p.numero_predial, 22, 5) != '80000'
            THEN 'Error: Los campos 22-26 deben ser "80000" para Condominio.Unidad_Predial'
        WHEN SUBSTRING(p.numero_predial, 27, 4) = '0000'
            THEN 'Error: Los campos 27-30 no pueden ser "0000"'
    END AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE cpt.ilicode = 'Condominio.Unidad_Predial'
  AND LENGTH(p.numero_predial) = 30
  AND (
      SUBSTRING(p.numero_predial, 22, 5) != '80000'
      OR SUBSTRING(p.numero_predial, 27, 4) = '0000'
  );
