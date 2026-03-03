WITH tb39 as(
SELECT 
p.numero_predial numeropredial,
p.condicion_predio condicion_P ,
---st_area(cu.geometria) AS area_geometria,
cru.T_Id Id_carcons,
sum(cu.area_construida) totalsuma, 
cru.area_construida area_cons,
cru.area_privada_construida area_cons_piv
FROM cca_predio p 
INNER join cca_construccion as ca on ca.predio = p.T_Id
INNER JOIN cca_unidadconstruccion as cu on cu.construccion = ca.T_Id and cu.construccion is not null
left join cca_caracteristicasunidadconstruccion cru on cru.T_Id = cu.caracteristicasunidadconstruccion
LEFT JOIN cca_unidadconstrucciontipo uct ON uct.T_Id = cru.tipo_unidad_construccion 
LEFT JOIN cca_usouconstipo ut ON ut.T_Id = cru.uso 
LEFT JOIN cca_construcciontipo AS ct ON ca.tipo_construccion = ct.T_Id
GROUP BY cu.caracteristicasunidadconstruccion),
tb39_1 as(
SELECT *
,case when condicion_P in ('3','5') and totalsuma = area_cons_piv then 'Ok' ELSE 'Fail' END AS cond_3_39_1
FROM tb39 where condicion_P IN ('3','5')
),
tb39_2 as(
SELECT *
,case when condicion_P NOT in ('3','5') and totalsuma = area_cons then 'Ok' ELSE 'Fail' END AS cond_3_39_2
FROM tb39 where condicion_P NOT IN ('3','5')
)
SELECT numeropredial, condicion_P, Id_carcons, totalsuma, area_cons, area_cons_piv, cond_3_39_1, NULL AS cond_3_39_2
FROM tb39_1
UNION ALL
SELECT numeropredial, condicion_P, Id_carcons, totalsuma, area_cons, area_cons_piv, NULL AS cond_3_39_1, cond_3_39_2