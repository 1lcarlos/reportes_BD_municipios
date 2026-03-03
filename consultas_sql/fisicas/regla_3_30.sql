/* Reemplacé strftime('%Y', p.fecha_visita_predial) por EXTRACT(YEAR FROM p.fecha_visita_predial). */

WITH tb30 AS (
    SELECT 
        p.numero_predial, 
        ca.anio_construccion,
        p.fecha_visita_predial,
        CASE 
            WHEN ca.anio_construccion IS NOT NULL 
                 AND ca.anio_construccion > 0 
                 AND ca.anio_construccion <= EXTRACT(YEAR FROM p.fecha_visita_predial) 
            THEN 'Ok' 
            ELSE 'Fail' 
        END AS cond_3_30
    FROM cca_predio p 
    INNER JOIN cca_construccion ca ON ca.predio = p.t_id
    INNER JOIN cca_unidadconstruccion cu ON cu.construccion = ca.t_id AND cu.construccion IS NOT NULL
)
SELECT * FROM tb30
WHERE cond_3_30 = 'Fail'
