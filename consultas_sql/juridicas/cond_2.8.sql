--cond 2.8
WITH base AS (
    SELECT 
        lp.numero_predial,
        lpt.ilicode AS tipo_predio,
        ld2.ilicode AS tipo_derecho
    FROM cca_predio lp
    LEFT JOIN cca_prediotipo lpt ON lpt.t_id = lp.predio_tipo 
    LEFT JOIN cca_derecho ld ON ld.predio = lp.t_id
    LEFT JOIN cca_derechotipo ld2 ON ld2.t_id = ld.tipo
    WHERE lpt.ilicode = 'Predio.Privado' AND ld2.ilicode = 'Ocupacion'
)
SELECT 
    numero_predial,
    tipo_predio,
    tipo_derecho,
    'Fail' AS cond_2_8
FROM base;