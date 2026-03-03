--cond 1_35
WITH tb_cond_1_35_1 AS (
    SELECT 
        lp.t_id,
        lp.numero_predial,
        lp.area_total_terreno,
        lt.area_terreno AS area_matriz_terreno_alfa
    FROM cca_predio lp
    LEFT JOIN cca_terreno lt ON lt.predio = lp.t_id 
    WHERE SUBSTR(lp.numero_predial, 22, 9) = '800000000' 
),
predios_asociados AS (
    SELECT 
        lp.numero_predial AS predio_matriz,
        SUM(lt.area_terreno) AS sum_area_terreno_unidades_alfa
    FROM cca_predio lp
    INNER JOIN tb_cond_1_35_1 tt ON tt.t_id = lp.t_id
    LEFT JOIN cca_terreno lt ON lt.predio = lp.t_id
    GROUP BY lp.numero_predial
)
SELECT 
    tb1.numero_predial,
    tb1.area_total_terreno,
    tb1.area_matriz_terreno_alfa + pa.sum_area_terreno_unidades_alfa AS area_total_condominio_alfa,
    CASE 
        WHEN tb1.area_total_terreno IS NULL THEN 'Fail'
        WHEN tb1.area_matriz_terreno_alfa + pa.sum_area_terreno_unidades_alfa IS NULL THEN 'Fail'
        WHEN tb1.area_total_terreno <> tb1.area_matriz_terreno_alfa + pa.sum_area_terreno_unidades_alfa THEN 'Fail'
        ELSE 'Ok' 
    END AS cond_1_35
FROM tb_cond_1_35_1 tb1
LEFT JOIN predios_asociados pa ON tb1.numero_predial = pa.predio_matriz;