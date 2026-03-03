-- =========================================================
-- REGLA 21: Validación de sumatoria de áreas de coeficiente
-- =========================================================
-- Descripción:
-- La sumatoria de las áreas de coeficiente debe ser igual al
-- área de terreno del predio matriz donde se ubican
-- =========================================================

-- Consulta que verifica la consistencia de áreas
SELECT
    matriz.t_id AS matriz_id,
    matriz.numero_predial AS numero_predial_matriz,
    cpt.ilicode AS condicion_predio,
    t.area_terreno AS area_terreno_matriz,
    SUM(up.coeficiente_copropiedad * t.area_terreno) AS suma_areas_coeficiente,
    ABS(t.area_terreno - SUM(up.coeficiente_copropiedad * t.area_terreno)) AS diferencia,
    'Error: La sumatoria de áreas por coeficiente no corresponde al área del terreno matriz' AS mensaje_error
FROM cca_predio matriz
LEFT JOIN cca_condicionprediotipo cpt ON matriz.condicion_predio = cpt.t_id
INNER JOIN cca_terreno t ON t.predio = matriz.t_id
INNER JOIN cca_predio_copropiedad cp ON cp.matriz = matriz.t_id
INNER JOIN cca_predio up ON up.t_id = cp.unidad_predial
WHERE cpt.ilicode IN ('PH.Matriz', 'Condominio.Matriz')
GROUP BY matriz.t_id, matriz.numero_predial, cpt.ilicode, t.area_terreno
HAVING ABS(t.area_terreno - SUM(up.coeficiente_copropiedad * t.area_terreno)) > 1;
