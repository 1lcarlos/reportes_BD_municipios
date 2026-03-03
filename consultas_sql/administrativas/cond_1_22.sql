--cond 1_22
WITH tb_cond_1_22 AS (
    SELECT 
        lp.numero_predial,
        lp.matricula_inmobiliaria,
        --cb.ilicode AS tiene_fmi,
        cb1.ilicode AS tiene_area_registral,
        lp.area_registral_m2,
        CASE 
            WHEN cb1.ilicode = 'No' AND lp.area_registral_m2 <> 0 THEN 'Fail'
            --WHEN cb1.ilicode = 'Si' AND lp.area_registral_m2 = 0 THEN 'Fail'
            ELSE 'OK'
        END AS cond_1_22
    FROM cca_predio lp 
    --LEFT JOIN cca_booleanotipo cb ON cb.t_id = lp.tiene_fmi 
    LEFT JOIN cca_booleanotipo cb1 ON cb1.t_id = lp.tiene_area_registral 
    --WHERE cb1.ilicode = 'No'
)
SELECT 
    numero_predial, 
    matricula_inmobiliaria,
    --tiene_fmi, 
    tiene_area_registral, 
    area_registral_m2, 
    cond_1_22 
FROM tb_cond_1_22 
WHERE cond_1_22 = 'Fail';