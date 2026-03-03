-- =========================================================
-- REGLA 43: Letras de vías deben ser alfabéticas
-- =========================================================
-- Descripción:
-- En el caso de que una dirección estructurada tenga valores en
-- Letra_Via_Principal y en Letra_Via_Generadora, estos datos
-- deben ser alfabéticos
-- =========================================================

-- Consulta conceptual
SELECT
    p.t_id,
    p.numero_predial,
    'Error: Las letras de vía principal y generadora deben ser alfabéticas' AS mensaje_error
FROM cca_predio p
-- Ajustar JOIN según estructura real
/*
INNER JOIN extdireccion d ON d.cca_predio_direccion = p.t_id
WHERE d.tipo_direccion = 'Estructurada'
  AND (
      (d.letra_via_principal IS NOT NULL AND d.letra_via_principal !~ '^[A-Za-z]+$')
      OR
      (d.letra_via_generadora IS NOT NULL AND d.letra_via_generadora !~ '^[A-Za-z]+$')
  )
*/
WHERE FALSE;

-- Nota: Requiere adaptación según la estructura real de direcciones
