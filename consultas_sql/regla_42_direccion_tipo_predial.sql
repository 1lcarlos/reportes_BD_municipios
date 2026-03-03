-- =========================================================
-- REGLA 42: Tipo de dirección según número predial
-- =========================================================
-- Descripción:
-- Si los dígitos 6 y 7 del número predial son diferentes de "00",
-- la dirección debe ser estructurada.
-- Si los dígitos 6 y 7 son "00", la dirección debe ser no estructurada.
-- (Aplican excepciones en zonas rurales con comportamiento urbano)
-- =========================================================

-- Consulta conceptual
SELECT
    p.t_id,
    p.numero_predial,
    SUBSTRING(p.numero_predial, 6, 2) AS digitos_6_7,
    CASE
        WHEN SUBSTRING(p.numero_predial, 6, 2) != '00'
            THEN 'Debe ser dirección estructurada (zona urbana)'
        ELSE 'Debe ser dirección no estructurada (zona rural)'
    END AS tipo_direccion_esperado,
    'Error: El tipo de dirección no corresponde con la zona del predio' AS mensaje_error
FROM cca_predio p
WHERE LENGTH(p.numero_predial) = 30
-- Ajustar según estructura real de direcciones
/*
  AND EXISTS (
      SELECT 1 FROM extdireccion d
      WHERE d.cca_predio_direccion = p.t_id
        AND (
            (SUBSTRING(p.numero_predial, 6, 2) != '00' AND d.tipo_direccion != 'Estructurada')
            OR
            (SUBSTRING(p.numero_predial, 6, 2) = '00' AND d.tipo_direccion != 'No_Estructurada')
        )
  )
*/
  AND FALSE;

-- Nota: Requiere adaptación y considerar excepciones
