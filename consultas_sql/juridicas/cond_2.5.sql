--cond 2.5
SELECT 
    lp.numero_predial,
    CAST(COUNT(*) AS TEXT) AS cantidad_derechos,
    ld2.ilicode AS derecho_tipo,
    'Fail' AS cond_2_5
FROM cca_predio lp
LEFT JOIN cca_derecho ld ON ld.predio = lp.t_id
LEFT JOIN cca_derechotipo ld2 ON ld2.t_id = ld.tipo 
WHERE substr(lp.numero_predial, 22, 1) <> '2'
    AND ld2.ilicode = 'Dominio'
GROUP BY lp.numero_predial, ld2.ilicode
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    lp.numero_predial, 
    'n/a' AS cantidad_derechos,
    ld2.ilicode AS derecho_tipo,
    'Fail' AS cond_2_5
FROM cca_predio lp
LEFT JOIN cca_derecho ld ON ld.predio = lp.t_id
LEFT JOIN cca_derechotipo ld2 ON ld2.t_id = ld.tipo 
WHERE substr(lp.numero_predial, 22, 1) = '2'
    AND ld2.ilicode = 'Dominio';