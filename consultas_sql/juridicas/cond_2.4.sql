--cond 2.4

WITH base AS (
    SELECT 
        lp.numero_predial,
        ld2.ilicode AS tipo_derecho,
        ld.fecha_inicio_tenencia,
        lp.fecha_visita_predial,
        CASE 
            WHEN lp.fecha_visita_predial IS NOT NULL AND ld.fecha_inicio_tenencia < lp.fecha_visita_predial THEN 'Ok'
            WHEN lp.fecha_visita_predial IS NULL AND ld.fecha_inicio_tenencia < date('now') THEN 'Ok' 
            ELSE 'Fail' 
        END AS cond_2_4
    FROM cca_predio lp 
    INNER JOIN cca_derecho ld ON ld.predio = lp.t_id 
    LEFT JOIN cca_derechotipo ld2 ON ld2.t_id = ld.tipo
)
SELECT * FROM base WHERE cond_2_4 = 'Fail';