--cond 2.7
WITH base AS (
    SELECT 
        lp.numero_predial,
        lp2.ilicode AS tipo_predio,
        ld2.ilicode AS tipo_derecho,
        CASE 
            WHEN lp2.ilicode = 'Predio.Privado' THEN 'Ok' 
            ELSE 'Fail' 
        END AS cond_2_7
    FROM cca_predio lp
    LEFT JOIN cca_derecho ld ON ld.predio = lp.t_id
    LEFT JOIN cca_derechotipo ld2 ON ld2.t_id = ld.tipo 
    LEFT JOIN cca_prediotipo lp2 ON lp2.t_id = lp.predio_tipo
    WHERE ld2.ilicode = 'Posesion'
)
SELECT * 
FROM base 
WHERE cond_2_7 = 'Fail';