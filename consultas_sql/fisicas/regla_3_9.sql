with base as(
select
distinct
p.numero_predial 
, cuc.identificador  
, cuc.tipo_dominio 
, cuc.tipo_construccion 
, cuc.tipo_unidad_construccion 
, cuc.tipo_planta 
, cuc.total_habitaciones 
, cuc.total_banios 
, cuc.uso 
, cuc.anio_construccion 
, cuc.tipo_tipologia
, cuc.calificacion_convencional
, cv.total_calificacion 
, cuc.tipo_anexo 
, cuc.tipo_tipologia 
from cca_predio p
inner join cca_construccion as ca on ca.predio = p.T_Id
inner join cca_unidadconstruccion as cu on cu.construccion = ca.T_Id and cu.construccion is not null
left join cca_caracteristicasunidadconstruccion cuc on cuc.t_id = cu.caracteristicasunidadconstruccion
left join cca_unidadconstrucciontipo cut on cuc.tipo_unidad_construccion = cut.t_id 
left join cca_calificacionconvencional cv on cv.t_id = cuc.calificacion_convencional 
left join cca_tipologiatipo tp on tp.T_Id = cuc.tipo_tipologia
order by p.numero_predial, cuc.identificador)
,
base2 AS (
    SELECT *,
        CASE 
            WHEN LENGTH(TRIM(identificador)) = 1 THEN unicode(TRIM(identificador)) - 64 
            WHEN LENGTH(TRIM(identificador)) = 2 THEN 
                (unicode(substr(identificador, 1, 1)) - 64) * 26 + 
                (unicode(substr(identificador, 2, 1)) - 64) 
        END AS letter_number,
        ROW_NUMBER() OVER (PARTITION BY numero_predial ORDER BY numero_predial, identificador) AS rn,
        CASE 
            WHEN LENGTH(TRIM(identificador)) = 1 
                 AND (unicode(identificador) - 64) = ROW_NUMBER() OVER (PARTITION BY numero_predial ORDER BY numero_predial, identificador) 
            THEN 'Ok' 
            WHEN LENGTH(TRIM(identificador)) = 2 
                 AND ((unicode(substr(identificador, 1, 1)) - 64) * 26 + 
                      (unicode(substr(identificador, 2, 1)) - 64)) = ROW_NUMBER() OVER (PARTITION BY numero_predial ORDER BY numero_predial, identificador) 
            THEN 'Ok' 
            ELSE 'Fail' 
        END AS regla_3_9
    FROM base
    ORDER BY base.numero_predial, base.identificador, ROW_NUMBER() OVER (PARTITION BY base.numero_predial ORDER BY base.numero_predial)
)
SELECT numero_predial, identificador, rn, letter_number,  regla_3_9 
FROM base2
WHERE numero_predial IN (
    SELECT numero_predial 
    FROM base2 
    WHERE regla_3_9 = 'Fail'
)
ORDER BY numero_predial, identificador;