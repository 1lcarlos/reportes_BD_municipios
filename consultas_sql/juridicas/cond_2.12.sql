--cond 2.12
WITH base AS (
    SELECT 
        lp.numero_predial,
        lpt.ilicode AS tipo_predio,
        ld2.ilicode AS tipo_derecho,
        li.razon_social
    FROM cca_predio lp
    LEFT JOIN cca_derecho ld ON ld.predio = lp.t_id
    LEFT JOIN cca_derechotipo ld2 ON ld2.t_id = ld.tipo 
    LEFT JOIN cca_interesado li ON li.t_id = ld.interesado
    LEFT JOIN cca_prediotipo lpt ON lpt.t_id = lp.predio_tipo 
    WHERE lpt.ilicode = 'Predio.Publico.Baldio'
      AND ld2.ilicode = 'Ocupacion'
),
tb_cond_2_12 AS (
    SELECT *,
        CASE 
            WHEN razon_social IS NOT NULL 
                 AND (lower(razon_social) LIKE '%la naci%n%' 
                      OR lower(razon_social) LIKE '%municipio%' 
                      OR lower(razon_social) LIKE '%agencia nacional de tierras%') 
            THEN 'fail' 
            ELSE 'ok' 
        END AS cond_2_12
    FROM base
)
SELECT * FROM tb_cond_2_12 WHERE cond_2_12 = 'Fail';