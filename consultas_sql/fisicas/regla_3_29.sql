WITH tb29 as(
SELECT p.numero_predial,p.resultado_visita,cru.T_Id, ct.ilicode tipo_construccion,
uct.ilicode tipo_unidad_construccion, ut.ilicode,cru.total_habitaciones
,case when ut.T_id in ('1','2','3','4','10','12','13','14','15') and cru.total_habitaciones >0 and cru.total_habitaciones is not null then 'Ok'
	when ut.T_id not in ('1','2','3','4','10','12','13','14','15') and (cru.total_habitaciones is null or cru.total_habitaciones = 0) then 'Ok'
else 'Fail' end as cond_3_29
FROM cca_predio p 
INNER join cca_construccion as ca on ca.predio = p.T_Id
INNER JOIN cca_unidadconstruccion as cu on cu.construccion = ca.T_Id and cu.construccion is not null
left join cca_caracteristicasunidadconstruccion cru on cru.T_Id = cu.caracteristicasunidadconstruccion
LEFT JOIN cca_unidadconstrucciontipo uct ON uct.T_Id = cru.tipo_unidad_construccion 
LEFT JOIN cca_usouconstipo ut ON ut.T_Id = cru.uso 
LEFT JOIN cca_construcciontipo AS ct ON ca.tipo_construccion = ct.T_Id
WHERE p.resultado_visita = '1' AND uct.T_id = '1')
select * from tb29
where cond_3_29 ='Fail'