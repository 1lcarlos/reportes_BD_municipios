--cond 4.1
WITH base AS (
    SELECT DISTINCT
        cp.numero_predial,
        cc2.T_id AS id_caracteristica_unidad,
        ct2.ilicode AS tipo_construccion_caracteristica,
        cc2.identificador,
        ut.iliCode AS tipo_unidad,
        tt.iliCode AS tipo_tipologia,
        cc3.total_calificacion,
        CASE
            WHEN tt.T_Id IS NOT NULL OR cc3.total_calificacion IS NOT NULL THEN 'Ok'
            ELSE 'Fail'
        END AS cond_4_1
    FROM cca_predio cp
    LEFT JOIN cca_construccion cc ON cp.T_Id = cc.predio
    LEFT JOIN cca_construcciontipo ct ON ct.T_id = cc.tipo_construccion
    LEFT JOIN cca_unidadconstruccion cu ON cc.T_Id = cu.construccion
    LEFT JOIN cca_caracteristicasunidadconstruccion cc2 ON cc2.T_id = cu.caracteristicasunidadconstruccion
    LEFT JOIN cca_unidadconstrucciontipo ut ON ut.T_id = cc2.tipo_unidad_construccion
    LEFT JOIN cca_construcciontipo ct2 ON ct2.T_id = cc2.tipo_construccion
    LEFT JOIN cca_tipologiatipo tt ON tt.T_id = cc2.tipo_tipologia
    LEFT JOIN cca_calificacionconvencional cc3 ON cc3.T_id = cc2.calificacion_convencional
    WHERE ct2.ilicode  = 'Convencional'
)
SELECT * FROM base WHERE cond_4_1 = 'Fail';