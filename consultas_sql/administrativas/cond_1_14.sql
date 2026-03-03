--cond 1_14
WITH tb_cond_1_14 AS (
    SELECT
    lp.numero_predial,
        lp.matricula_inmobiliaria,
        CASE 
            WHEN LENGTH(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                lp.matricula_inmobiliaria, '0', ''), '1', ''), '2', ''), '3', ''), '4', ''), '5', ''), '6', ''), '7', ''), '8', ''), '9', ''))) = 0 
            THEN 'OK' 
            ELSE 'Fail' 
        END AS cond_1_14
    FROM cca_predio lp
    WHERE lp.matricula_inmobiliaria IS NOT NULL
)
SELECT DISTINCT * 
FROM tb_cond_1_14 
WHERE cond_1_14 = 'Fail';