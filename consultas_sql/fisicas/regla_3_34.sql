WITH tb34 as(
SELECT 
    construccion_id,
    SUM(altura_maxima) AS altura_total,
    altura_cons
FROM (
    SELECT 
        ca.T_id AS construccion_id,
        cu.planta_ubicacion,
        ca.altura altura_cons,
        cu.T_Id,
        MAX(cu.altura) AS altura_maxima
    FROM 
        cca_predio p
    INNER JOIN 
        cca_construccion ca ON ca.predio = p.T_Id
    INNER JOIN 
        cca_unidadconstruccion cu ON cu.construccion = ca.T_Id
    LEFT JOIN 
        cca_caracteristicasunidadconstruccion cru ON cru.T_Id = cu.caracteristicasunidadconstruccion
    GROUP BY 
        ca.T_id, cu.planta_ubicacion
) AS max_alturas
GROUP BY 
    construccion_id
)
,
tb_cond_3_34 as(
select *
,case when altura_total=altura_cons then 'OK' else 'Fail' end as cond_3_34 from tb34)
select * from tb_cond_3_34
where cond_3_34 ='Fail'
