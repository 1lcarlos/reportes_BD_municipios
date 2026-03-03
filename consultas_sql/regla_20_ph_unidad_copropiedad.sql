-- =========================================================
-- REGLA 20: Validación de PH/Condominio y copropiedad
-- =========================================================
-- Descripción:
-- Todos los predios con condición PH.Unidad_Predial o
-- Condominio.Unidad_Predial deben tener un registro en la tabla
-- de cca_predio_copropiedad y la sumatoria de los coeficientes
-- de las unidades que los integran debe ser 1
-- =========================================================

-- Parte 1: Unidades prediales sin registro de copropiedad
SELECT
    p.t_id,
    p.numero_predial,
    cpt.ilicode AS condicion_predio,
    p.predio_matriz,
    'Error: Las unidades de PH o Condominio deben tener registro de copropiedad' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE cpt.ilicode IN ('PH.Unidad_Predial', 'Condominio.Unidad_Predial')
AND NOT EXISTS (
    SELECT 1
    FROM cca_predio_copropiedad cp
    WHERE cp.unidad_predial = p.t_id
);

-- Parte 2: Verificar que la suma de coeficientes por matriz sea 1
-- (Consulta separada para verificación)
/*
SELECT
    matriz.t_id AS matriz_id,
    matriz.numero_predial AS numero_predial_matriz,
    SUM(cp.coeficiente) AS suma_coeficientes,
    CASE
        WHEN ABS(SUM(cp.coeficiente) - 1) > 0.0001
            THEN 'Error: La suma de coeficientes debe ser igual a 1'
        ELSE 'OK'
    END AS mensaje_error
FROM cca_predio matriz
LEFT JOIN cca_condicionprediotipo cpt ON matriz.condicion_predio = cpt.t_id
INNER JOIN cca_predio_copropiedad cp ON cp.matriz = matriz.t_id
WHERE cpt.ilicode IN ('PH.Matriz', 'Condominio.Matriz')
GROUP BY matriz.t_id, matriz.numero_predial
HAVING ABS(SUM(cp.coeficiente) - 1) > 0.0001;
*/
