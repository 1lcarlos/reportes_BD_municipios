---cond_4.16 
--- Busca unidades de construcciones que son de tipo convencional y que no tienen todos los atributos obligatorios llenos 

SELECT
        --cp.numero_predial,
        --cc.T_id AS construccion_id,
        cu.T_id AS unidad_id,
        cc2.T_id AS caracteristica_id,
        ct.iliCode AS tipo_construccion,
        ut.iliCode AS tipo_unidad,
        ct2.iliCode AS tipo_calificar,
        --cct.iliCode AS clase_calificacion,
        --cct.itfCode AS clase_itfcode,
        -- Atributos obligatorios según clase (en cc3)
        cc3.armazon,
        cc3.muros,
        cc3.cubierta,
        cc3.subtotal_estructura, 
        cc3.fachada,
        cc3.cubrimiento_muros,
        cc3.piso,
        cc3.subtotal_acabados, 
        cc3.tamanio_banio,
        cc3.enchape_banio,
        cc3.mobiliario_banio,
        cc3.subtotal_banio, 
        cc3.tamanio_cocina,
        cc3.enchape_cocina,
        cc3.mobiliario_cocina,
        cc3.subtotal_cocina
    FROM cca_predio cp
    LEFT JOIN cca_construccion cc ON cp.T_Id = cc.predio
    LEFT JOIN cca_construcciontipo ct ON ct.T_id = cc.tipo_construccion
    LEFT JOIN cca_unidadconstruccion cu ON cc.T_Id = cu.construccion
    LEFT JOIN cca_caracteristicasunidadconstruccion cc2 ON cc2.T_id = cu.caracteristicasunidadconstruccion
    LEFT JOIN cca_calificacionconvencional cc3 ON cc3.T_id = cc2.calificacion_convencional
    LEFT JOIN cca_calificartipo ct2 ON ct2.T_id = cc3.tipo_calificar
    LEFT JOIN cca_clasecalificaciontipo cct ON cct.T_id = cc3.clase_calificacion
    LEFT JOIN cca_unidadconstrucciontipo ut ON ut.T_id = cc2.tipo_unidad_construccion
    WHERE ct.iliCode = 'Convencional'  and 
    (cc3.subtotal_estructura is null or cc3.subtotal_acabados is null
    or cc3.subtotal_cocina is null or cc3.subtotal_banio is null)