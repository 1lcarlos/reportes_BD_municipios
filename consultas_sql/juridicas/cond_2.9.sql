--cond 2.9
WITH base AS (
    SELECT 
        cp.numero_predial,
        cpt.ilicode AS tipo_predio,
        cd2.ilicode AS tipo_derecho,
        CASE 
            WHEN cd2.ilicode = 'Posesion' THEN 'Fail'
            ELSE 'Ok'
        END AS cond_2_9
    FROM cca_predio cp
    LEFT JOIN cca_derecho cd ON cd.predio = cp.T_Id
    LEFT JOIN cca_derechotipo cd2 ON cd2.T_Id = cd.tipo 
    LEFT JOIN cca_prediotipo cpt ON cpt.T_Id = cp.predio_tipo 
    WHERE cpt.ilicode IN (
        'Predio.Publico.Uso_Publico',
        'Predio.Publico.Patrimonial',
        'Predio.Publico.Fiscal',
        'Predio.Publico.Baldio',
        'Predio.Publico.Ejido'
    )
)
SELECT *
FROM base
WHERE cond_2_9 = 'Fail';