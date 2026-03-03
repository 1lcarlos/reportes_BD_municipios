-- =========================================================
-- REGLA 31: Área total de terreno para Condominio.Matriz
-- =========================================================
-- Descripción:
-- Para predios con condición Condominio.Matriz (posición 22-30 = "800000000"),
-- el área total de terreno debe corresponder a la suma del área
-- geográfica del terreno de Condominio.Matriz y las áreas geográficas
-- de los terrenos de las unidades privadas asociadas
-- =========================================================

-- Consulta que verifica el área total de terreno para Condominio.Matriz
SELECT
    matriz.t_id,
    matriz.numero_predial,
    cpt.ilicode AS condicion_predio,
    matriz.area_total_terreno,
    calc.suma_areas AS area_total_esperada,
    ABS(COALESCE(matriz.area_total_terreno, 0) - COALESCE(calc.suma_areas, 0)) AS diferencia,
    'Error: El área total de terreno no corresponde a la suma de áreas (matriz + unidades)' AS mensaje_error
FROM cca_predio matriz
LEFT JOIN cca_condicionprediotipo cpt ON matriz.condicion_predio = cpt.t_id
LEFT JOIN (
    SELECT
        m.t_id AS matriz_id,
        COALESCE(t_matriz.area_terreno, 0) + COALESCE(SUM(t_unidad.area_terreno), 0) AS suma_areas
    FROM cca_predio m
    LEFT JOIN cca_condicionprediotipo cpt2 ON m.condicion_predio = cpt2.t_id
    LEFT JOIN cca_terreno t_matriz ON t_matriz.predio = m.t_id
    LEFT JOIN cca_predio_copropiedad cp ON cp.matriz = m.t_id
    LEFT JOIN cca_predio up ON up.t_id = cp.unidad_predial
    LEFT JOIN cca_terreno t_unidad ON t_unidad.predio = up.t_id
    WHERE cpt2.ilicode = 'Condominio.Matriz'
    GROUP BY m.t_id, t_matriz.area_terreno
) calc ON calc.matriz_id = matriz.t_id
WHERE cpt.ilicode = 'Condominio.Matriz'
  AND LENGTH(matriz.numero_predial) = 30
  AND SUBSTRING(matriz.numero_predial, 22, 9) = '800000000'
  AND ABS(COALESCE(matriz.area_total_terreno, 0) - COALESCE(calc.suma_areas, 0)) > 1;
