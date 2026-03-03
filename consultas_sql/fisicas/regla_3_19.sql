WITH tb19 as(
SELECT p.resultado_visita,cru.T_Id,ct.ilicode tipo_construccion,
uct.ilicode tipo_unidad_construccion, ut.ilicode,cru.total_locales
,case when cru.total_locales is null then 'Ok'
	else 'Fail' end as cond_3_19
FROM cca_predio p 
INNER join cca_construccion as ca on ca.predio = p.T_Id
INNER JOIN cca_unidadconstruccion as cu on cu.construccion = ca.T_Id and cu.construccion is not null
left join cca_caracteristicasunidadconstruccion cru on cru.T_Id = cu.caracteristicasunidadconstruccion
LEFT JOIN cca_unidadconstrucciontipo uct ON uct.T_Id = cru.tipo_unidad_construccion 
LEFT JOIN cca_usouconstipo ut ON ut.T_Id = cru.uso 
LEFT JOIN cca_construcciontipo AS ct ON ca.tipo_construccion = ct.T_Id
WHERE uct.T_Id <> '2' AND cru.total_locales > 0)

select * from tb19
where cond_3_19 ='Fail'

