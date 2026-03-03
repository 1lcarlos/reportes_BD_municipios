--cond 1_34
WITH tb_cond_1_34_1 AS (
    SELECT 
        lp.t_id,
        lp.numero_predial,
        lp.numero_torres
    FROM cca_predio lp
    WHERE SUBSTR(lp.numero_predial, 22, 9) = '900000000' 
),
predios_asociados AS (
    SELECT 
        lp.numero_predial AS predio_matriz, 
        lp.t_id AS tid_matriz, 
        lp2.numero_predial AS numero_predial_unidad,
        lpc.unidad_predial AS tid_unidad_predial,
        MAX(SUBSTR(lp2.numero_predial, 25, 2)) AS torre  -- Cambio: sin OVER
    FROM cca_predio lp
    INNER JOIN tb_cond_1_34_1 tt ON tt.t_id = lp.t_id
    LEFT JOIN cca_predio_copropiedad lpc ON lpc.matriz = lp.t_id 
    LEFT JOIN cca_predio lp2 ON lp2.t_id = lpc.unidad_predial 
    GROUP BY lp.numero_predial, lp.t_id, lp2.numero_predial, lpc.unidad_predial
),
tb_final_1_34 AS (
    SELECT 
        tb1.numero_predial, 
        tb1.numero_torres,
        MAX(pa.torre) AS max_torre
    FROM tb_cond_1_34_1 tb1
    LEFT JOIN predios_asociados pa ON tb1.t_id = pa.tid_matriz
    GROUP BY tb1.numero_predial, tb1.numero_torres
)
SELECT 
    numero_predial AS matriz, 
    numero_torres,
    max_torre, 
    CASE 
        WHEN numero_torres IS NULL OR max_torre IS NULL THEN 'Fail' 
        WHEN numero_torres = CAST(max_torre AS INTEGER) THEN 'OK' 
        ELSE 'Fail' 
    END AS cond_1_34 
FROM tb_final_1_34;