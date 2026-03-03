-- =========================================================
-- REGLA 41: Campos para dirección no estructurada
-- =========================================================
-- Descripción:
-- Si el tipo de dirección asociada a un predio es No estructurada,
-- únicamente el campo Nombre_Predio debe ir diligenciado
-- =========================================================

-- Consulta conceptual que debe adaptarse a la estructura real
SELECT
    p.t_id,
    p.numero_predial,
    'Error: Dirección no estructurada debe tener solo Nombre_Predio diligenciado' AS mensaje_error
FROM cca_predio p
-- Ajustar JOIN según estructura real de direcciones
/*
INNER JOIN extdireccion d ON d.cca_predio_direccion = p.t_id
WHERE d.tipo_direccion = 'No_Estructurada'
  AND (
      d.nombre_predio IS NULL OR d.nombre_predio = ''
      OR d.clase_via_principal IS NOT NULL
      OR d.valor_via_principal IS NOT NULL
      OR d.valor_via_generadora IS NOT NULL
      OR d.numero_predio IS NOT NULL
  )
*/
WHERE FALSE;

-- Nota: Requiere adaptación según la estructura real de direcciones
