-- =========================================================
-- REGLA 11: Validación de número predial sin duplicados
-- =========================================================
-- Descripción:
-- En los registros de número predial no deben existir duplicados
-- =========================================================

-- Consulta que identifica números prediales duplicados
SELECT
    p.t_id,
    p.numero_predial,
    dup.cantidad_duplicados,
    'Error: El número predial está duplicado' AS mensaje_error
FROM cca_predio p
INNER JOIN (
    SELECT numero_predial, COUNT(*) AS cantidad_duplicados
    FROM cca_predio
    GROUP BY numero_predial
    HAVING COUNT(*) > 1
) dup ON p.numero_predial = dup.numero_predial
ORDER BY p.numero_predial;
