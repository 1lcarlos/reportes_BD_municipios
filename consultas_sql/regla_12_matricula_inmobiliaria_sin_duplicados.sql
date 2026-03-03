-- =========================================================
-- REGLA 12: Validación de matrícula inmobiliaria sin duplicados
-- =========================================================
-- Descripción:
-- El valor de Matricula_inmobiliaria no puede estar relacionado a
-- más de un número predial (FMI duplicados, pueden existir excepciones)
-- =========================================================

-- Consulta que identifica matrículas inmobiliarias duplicadas
SELECT
    p.t_id,
    p.numero_predial,
    p.matricula_inmobiliaria,
    p.codigo_orip,
    dup.cantidad_duplicados,
    'Error: La matrícula inmobiliaria está asociada a más de un número predial' AS mensaje_error
FROM cca_predio p
INNER JOIN (
    SELECT matricula_inmobiliaria, codigo_orip, COUNT(*) AS cantidad_duplicados
    FROM cca_predio
    WHERE matricula_inmobiliaria IS NOT NULL
      AND matricula_inmobiliaria != ''
    GROUP BY matricula_inmobiliaria, codigo_orip
    HAVING COUNT(*) > 1
) dup ON p.matricula_inmobiliaria = dup.matricula_inmobiliaria
     AND COALESCE(p.codigo_orip, '') = COALESCE(dup.codigo_orip, '')
ORDER BY p.matricula_inmobiliaria;
