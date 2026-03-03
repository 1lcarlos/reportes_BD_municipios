-- =========================================================
-- REGLA 33: Área total terreno común para Condominio.Matriz
-- =========================================================
-- Descripción:
-- Para predios con condición Condominio.Matriz (posición 22-30 = "800000000"),
-- el área total terreno común del condominio debe corresponder
-- al área geográfica del predio matriz
-- =========================================================

-- Consulta que verifica el área terreno común para Condominio.Matriz
SELECT
    p.t_id,
    p.numero_predial,
    cpt.ilicode AS condicion_predio,
    p.area_total_terreno_comun,
    t.area_terreno AS area_geografica_matriz,
    ABS(COALESCE(p.area_total_terreno_comun, 0) - COALESCE(t.area_terreno, 0)) AS diferencia,
    'Error: El área total terreno común no corresponde al área geográfica del predio matriz' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
LEFT JOIN cca_terreno t ON t.predio = p.t_id
WHERE cpt.ilicode = 'Condominio.Matriz'
  AND LENGTH(p.numero_predial) = 30
  AND SUBSTRING(p.numero_predial, 22, 9) = '800000000'
  AND ABS(COALESCE(p.area_total_terreno_comun, 0) - COALESCE(t.area_terreno, 0)) > 1;
