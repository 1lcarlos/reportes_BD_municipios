--cond 2.14
WITH base AS (
    SELECT 
        lp.numero_predial,
        lpt.ilicode AS tipo_predio,
        lc.ilicode AS condicion_predio,
        ld2.ilicode AS derecho_tipo,
        CASE 
            WHEN (lc.ilicode = 'Bien_Uso_Publico' OR lc.ilicode = 'Via')
                 AND lpt.ilicode = 'Predio.Publico.Uso_Publico' 
                 AND ld2.ilicode = 'Dominio' 
            THEN 'Ok' 
            ELSE 'Fail' 
        END AS cond_2_14
    FROM cca_predio lp 
    LEFT JOIN cca_condicionprediotipo lc ON lc.t_id = lp.condicion_predio 
    LEFT JOIN cca_derecho ld ON ld.predio = lp.t_id 
    LEFT JOIN cca_derechotipo ld2 ON ld2.t_id = ld.tipo
    LEFT JOIN cca_prediotipo lpt ON lpt.t_id = lp.predio_tipo 
)
SELECT * 
FROM base
WHERE cond_2_14 = 'Fail'
  AND condicion_predio IN ('Bien_Uso_Publico', 'Via');