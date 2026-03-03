-- =========================================================
-- REGLA 40: Campos obligatorios para dirección estructurada
-- =========================================================
-- Descripción:
-- Si el tipo de dirección asociada a un predio es Estructurada,
-- los campos Clase_Via_Principal, Valor_Via_Principal,
-- Valor_Via_Generadora y Numero_Predio deben ir diligenciados.
-- El campo Nombre_Predio no debe ir diligenciado
-- =========================================================

-- Nota: Esta regla depende de la estructura de ExtDireccion en LADM_COL
-- Consulta conceptual que debe adaptarse a la estructura real

SELECT
    p.t_id,
    p.numero_predial,
    -- Campos de dirección estructurada (ajustar según tabla real)
    'Error: Dirección estructurada incompleta o con campos incorrectos' AS mensaje_error
FROM cca_predio p
-- Ajustar JOIN según estructura real de direcciones
/*
INNER JOIN extdireccion d ON d.cca_predio_direccion = p.t_id
WHERE d.tipo_direccion = 'Estructurada'
  AND (
      d.clase_via_principal IS NULL OR d.clase_via_principal = ''
      OR d.valor_via_principal IS NULL OR d.valor_via_principal = ''
      OR d.valor_via_generadora IS NULL OR d.valor_via_generadora = ''
      OR d.numero_predio IS NULL OR d.numero_predio = ''
      OR (d.nombre_predio IS NOT NULL AND d.nombre_predio != '')
  )
*/
WHERE FALSE;

-- Nota: Requiere adaptación según la estructura real de direcciones
