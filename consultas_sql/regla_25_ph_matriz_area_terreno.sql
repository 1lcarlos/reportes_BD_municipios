-- =========================================================
-- REGLA 25: Validación de áreas de terreno para PH.Matriz
-- =========================================================
-- Descripción:
-- Para predios con condición PH.Matriz (posición 22-30 = "900000000"):
--   - El área total de terreno y área total terreno común del PH
--     deben corresponder al área geográfica del predio matriz
--   - El área total terreno privada debe ser cero
-- =========================================================

-- Consulta que verifica las áreas de terreno para PH.Matriz
SELECT
    p.t_id,
    p.numero_predial,
    cpt.ilicode AS condicion_predio,
    p.area_total_terreno,
    p.area_total_terreno_comun,
    p.area_total_terreno_privada,
    t.area_terreno AS area_geografica_terreno,
    CASE
        WHEN COALESCE(p.area_total_terreno_privada, 0) != 0
            THEN 'Error: El área total terreno privada debe ser cero para PH.Matriz'
        WHEN ABS(COALESCE(p.area_total_terreno, 0) - COALESCE(t.area_terreno, 0)) > 1
            THEN 'Error: El área total de terreno no corresponde al área geográfica'
        WHEN ABS(COALESCE(p.area_total_terreno_comun, 0) - COALESCE(t.area_terreno, 0)) > 1
            THEN 'Error: El área total terreno común no corresponde al área geográfica'
    END AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
LEFT JOIN cca_terreno t ON t.predio = p.t_id
WHERE cpt.ilicode = 'PH.Matriz'
  AND LENGTH(p.numero_predial) = 30
  AND SUBSTRING(p.numero_predial, 22, 9) = '900000000'
  AND (
      COALESCE(p.area_total_terreno_privada, 0) != 0
      OR ABS(COALESCE(p.area_total_terreno, 0) - COALESCE(t.area_terreno, 0)) > 1
      OR ABS(COALESCE(p.area_total_terreno_comun, 0) - COALESCE(t.area_terreno, 0)) > 1
  );
