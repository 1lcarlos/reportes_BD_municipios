-- =========================================================
-- REGLA 23: Una única unidad predial no puede constituir un PH
-- =========================================================
-- Descripción:
-- Una única unidad predial no puede constituir un PH o Condominio
-- (debe haber al menos 2 unidades prediales asociadas a una matriz)
-- =========================================================

-- Consulta que identifica matrices con solo una unidad predial
SELECT
    matriz.t_id AS matriz_id,
    matriz.numero_predial AS numero_predial_matriz,
    cpt.ilicode AS condicion_predio,
    COUNT(cp.unidad_predial) AS cantidad_unidades,
    'Error: Un PH o Condominio debe tener más de una unidad predial' AS mensaje_error
FROM cca_predio matriz
LEFT JOIN cca_condicionprediotipo cpt ON matriz.condicion_predio = cpt.t_id
LEFT JOIN cca_predio_copropiedad cp ON cp.matriz = matriz.t_id
WHERE cpt.ilicode IN ('PH.Matriz', 'Condominio.Matriz')
GROUP BY matriz.t_id, matriz.numero_predial, cpt.ilicode
HAVING COUNT(cp.unidad_predial) <= 1;
