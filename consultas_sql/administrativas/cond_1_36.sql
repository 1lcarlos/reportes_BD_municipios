--cond 1_36
WITH tb_cond_1_36_1 AS (
    SELECT 
        lp.t_id,
        lp.numero_predial,
        lp.area_total_terreno_privada
    FROM cca_predio lp
    WHERE SUBSTR(lp.numero_predial, 22, 9) = '800000000' 
),
predios_asociados AS (
    SELECT 
        tt.numero_predial AS predio_matriz,
        SUM(lt.area_terreno) AS sum_area_terreno_unidades_alfa
    FROM tb_cond_1_36_1 tt
    LEFT JOIN cca_predio lp 
        ON SUBSTR(lp.numero_predial, 1, 22) = SUBSTR(tt.numero_predial, 1, 22)
       AND SUBSTR(lp.numero_predial, 22, 1) = '8' -- Condición adicional
    LEFT JOIN cca_terreno lt ON lt.predio = lp.t_id
    WHERE lt.area_terreno IS NOT NULL -- Asegurar que no haya valores nulos
    GROUP BY tt.numero_predial
)
SELECT 
    tb1.numero_predial,
    tb1.area_total_terreno_privada,
    pa.sum_area_terreno_unidades_alfa AS area_total_condominio_alfa,
    CASE 
        WHEN tb1.area_total_terreno_privada IS NULL THEN 'Fail'
        WHEN pa.sum_area_terreno_unidades_alfa IS NULL THEN 'Fail'
        WHEN tb1.area_total_terreno_privada <> pa.sum_area_terreno_unidades_alfa THEN 'Fail'
        ELSE 'Ok' 
    END AS cond_1_36
FROM tb_cond_1_36_1 tb1
LEFT JOIN predios_asociados pa ON tb1.numero_predial = pa.predio_matriz;