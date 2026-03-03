--cond 1_13
WITH tb_cond_1_13 AS (
    SELECT 
        lp.matricula_inmobiliaria,
        COUNT(*) AS cond_1_13
    FROM cca_predio lp
    WHERE lp.matricula_inmobiliaria IS NOT NULL
    GROUP BY lp.matricula_inmobiliaria
    HAVING COUNT(*) > 1
)
SELECT 
    lp.numero_predial,
    lp.matricula_inmobiliaria,
    dup.cond_1_13
FROM cca_predio lp
INNER JOIN tb_cond_1_13 dup
    ON lp.matricula_inmobiliaria = dup.matricula_inmobiliaria
ORDER BY lp.matricula_inmobiliaria, lp.numero_predial;