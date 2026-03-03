WITH tb18 as(
SELECT p.resultado_visita,cru.T_Id,ct.ilicode tipo_construccion,
uct.ilicode tipo_unidad_construccion, ut.ilicode,cru.total_locales
,case when ut.ilicode is null then 'Fail' 
 when ut.ilicode LIKE 'Comercial.%' AND ut.ilicode NOT IN ('Comercial.Parqueaderos','Comercial.Parqueaderos_en_PH') and (cru.total_locales >0 and cru.total_locales is not null) then 'Ok'
else 'Fail' end as cond_3_18
FROM cca_predio p 
INNER JOIN cca_construccion as ca on ca.predio = p.T_Id
INNER join cca_unidadconstruccion as cu on cu.construccion = ca.T_Id and cu.construccion is not null
left join cca_caracteristicasunidadconstruccion cru on cru.T_Id = cu.caracteristicasunidadconstruccion
LEFT JOIN cca_unidadconstrucciontipo uct ON uct.T_Id = cru.tipo_unidad_construccion 
LEFT JOIN cca_usouconstipo ut ON ut.T_Id = cru.uso 
LEFT JOIN cca_construcciontipo AS ct ON ca.tipo_construccion = ct.T_Id
where uct.T_id ='2' AND p.resultado_visita = '1')

select * from tb18
where cond_3_18 ='Fail'
