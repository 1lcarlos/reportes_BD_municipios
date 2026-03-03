-- =========================================================
-- REGLA 24: Unidades prediales deben tener matriz asociada
-- =========================================================
-- Descripción:
-- No se pueden tener unidades prediales de PH o Condominio
-- sin tener un predio matriz asociado
-- =========================================================

-- Consulta que identifica unidades prediales sin matriz
SELECT
    p.t_id,
    p.numero_predial,
    cpt.ilicode AS condicion_predio,
    p.predio_matriz,
    'Error: La unidad predial de PH/Condominio no tiene un predio matriz asociado' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE cpt.ilicode IN ('PH.Unidad_Predial', 'Condominio.Unidad_Predial')
  AND (
      p.predio_matriz IS NULL
      OR p.predio_matriz = ''
      OR NOT EXISTS (
          SELECT 1
          FROM cca_predio_copropiedad cp
          WHERE cp.unidad_predial = p.t_id
      )
  );
