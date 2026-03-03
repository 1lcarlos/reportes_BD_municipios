-- =========================================================
-- REGLA 16: Validación de Lote Rural
-- =========================================================
-- Descripción:
-- Los predios con destinación económica "Lote_Rural" deben:
--   - Estar relacionados a números prediales rurales
--   - No ubicar espacialmente unidades de construcción
--   - No relacionar condición de PH o condominio
--   - Tener comportamiento urbano (normalmente área menor a 500 m²)
-- =========================================================

-- Consulta que identifica predios Lote_Rural que no cumplen las condiciones

-- Parte 1: Lote_Rural con número predial urbano (dígitos 6-7 diferentes de "00")
SELECT
    p.t_id,
    p.numero_predial,
    SUBSTRING(p.numero_predial, 6, 2) AS digitos_6_7,
    det.ilicode AS destinacion_economica,
    cpt.ilicode AS condicion_predio,
    'Error: Lote_Rural debe tener número predial rural (dígitos 6-7 = "00")' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_destinacioneconomicatipo det ON p.destinacion_economica = det.t_id
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE det.ilicode = 'Lote_Rural'
  AND LENGTH(p.numero_predial) = 30
  AND SUBSTRING(p.numero_predial, 6, 2) != '00'

UNION ALL

-- Parte 2: Lote_Rural con condición PH o Condominio
SELECT
    p.t_id,
    p.numero_predial,
    NULL AS digitos_6_7,
    det.ilicode AS destinacion_economica,
    cpt.ilicode AS condicion_predio,
    'Error: Lote_Rural no debe tener condición de PH o Condominio' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_destinacioneconomicatipo det ON p.destinacion_economica = det.t_id
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE det.ilicode = 'Lote_Rural'
  AND cpt.ilicode IN (
      'PH.Matriz', 'PH.Unidad_Predial',
      'Condominio.Matriz', 'Condominio.Unidad_Predial'
  );
