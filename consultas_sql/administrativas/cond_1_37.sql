--cond 1_37
WITH tb_cond_1_37_1 AS (
    SELECT 
        lp.t_id,
        lp.numero_predial,
        lp.area_total_terreno_comun,
        lt.area_terreno AS area_matriz_terreno_alfa
    FROM cca_predio lp
    LEFT JOIN cca_terreno lt ON lt.predio = lp.t_id 
    WHERE SUBSTR(lp.numero_predial, 22, 9) = '800000000' 
)
SELECT 
    tb1.numero_predial,
    tb1.area_total_terreno_comun,
    tb1.area_matriz_terreno_alfa,
    CASE 
        WHEN tb1.area_total_terreno_comun IS NULL THEN 'Fail'
        WHEN tb1.area_matriz_terreno_alfa IS NULL THEN 'Fail'
        WHEN tb1.area_total_terreno_comun <> tb1.area_matriz_terreno_alfa THEN 'Fail'
        ELSE 'Ok' 
    END AS cond_1_37
FROM tb_cond_1_37_1 tb1;