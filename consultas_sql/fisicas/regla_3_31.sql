---Agrupo todas las construcciones por numero predial pero tambien por cu.planta_ubicacion, cc.total_plantas, ca.numero_pisos
WITH tb31 AS (
    SELECT 
        p.numero_predial, 
        cu.planta_ubicacion,
        ---cc.T_Id,
        ca.T_Id,
        ca.T_id AS id_construccion,
        MAX(cu.planta_ubicacion) AS max_planta_ubicacion, 
        cc.total_plantas, 
        ca.numero_pisos,
        CASE WHEN MAX(cu.planta_ubicacion) > cc.total_plantas THEN 'Fail'WHEN cc.total_plantas > ca.numero_pisos THEN 'Fail' ELSE 'Ok' END AS cond_3_31
    FROM cca_predio p
    INNER JOIN cca_construccion ca ON ca.predio = p.T_Id
    INNER JOIN cca_unidadconstruccion cu ON cu.construccion = ca.T_Id AND cu.construccion IS NOT NULL
    LEFT JOIN cca_caracteristicasunidadconstruccion cc ON cc.T_Id = cu.caracteristicasunidadconstruccion
    GROUP BY p.numero_predial, ca.T_id,  cu.planta_ubicacion, cc.total_plantas, ca.numero_pisos
)
SELECT 
    numero_predial, 
    id_construccion, 
    max_planta_ubicacion, 
    total_plantas, 
    numero_pisos, 
    cond_3_31
FROM tb31
WHERE cond_3_31 = 'Fail';