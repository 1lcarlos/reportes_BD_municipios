--cond 1_23
WITH tb_cond_1_23 AS (
    SELECT
        lp.numero_predial,
        --lp.tiene_area_registral,
        cb.ilicode as tiene_area_registral,
        lp.area_registral_m2,
        --cb.dispname AS tiene_area_registral_dispname,
        CASE 
            WHEN lp.area_registral_m2 > 0 AND cb.dispname = 'Si' THEN 'OK' 
            WHEN lp.area_registral_m2 = 0 AND cb.dispname = 'No' THEN 'OK' 
            ELSE 'Fail' 
        END AS cond_1_23
    FROM cca_predio lp
    LEFT JOIN cca_booleanotipo cb ON lp.tiene_area_registral = cb.t_id
    WHERE lp.area_registral_m2 IS NOT NULL
)
SELECT 
    numero_predial, 
    tiene_area_registral, 
    area_registral_m2, 
    --tiene_area_registral_dispname, 
    cond_1_23 
FROM tb_cond_1_23
WHERE cond_1_23 = 'Fail';