-- =========================================================
-- REGLA 22: Validación de datos PH/Condominio matriz
-- =========================================================
-- Descripción:
-- Solo los predios con condición PH.Matriz o Condominio.Matriz
-- (posición 22 a la 30 "800000000" y "900000000") deben tener
-- los campos de datos de PH/Condominio diligenciados.
-- En caso contrario no debe tener relacionado registro.
-- =========================================================

-- Predios que NO son matriz pero tienen datos de PH/Condominio diligenciados
SELECT
    p.t_id,
    p.numero_predial,
    cpt.ilicode AS condicion_predio,
    p.total_unidades_privadas,
    p.numero_torres,
    p.area_total_terreno,
    p.area_total_construida,
    'Error: Solo predios PH.Matriz o Condominio.Matriz deben tener datos de PH/Condominio' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE cpt.ilicode NOT IN ('PH.Matriz', 'Condominio.Matriz')
  AND (
      COALESCE(p.total_unidades_privadas, 0) > 0
      OR COALESCE(p.numero_torres, 0) > 0
      OR COALESCE(p.area_total_terreno, 0) > 0
      OR COALESCE(p.area_total_terreno_privada, 0) > 0
      OR COALESCE(p.area_total_terreno_comun, 0) > 0
      OR COALESCE(p.area_total_construida, 0) > 0
      OR COALESCE(p.area_total_construida_privada, 0) > 0
      OR COALESCE(p.area_total_construida_comun, 0) > 0
  );
