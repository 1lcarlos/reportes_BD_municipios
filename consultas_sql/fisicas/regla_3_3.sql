with tb3 as(select 
p.numero_predial
,c.ilicode condicion_predio, 
cru.T_Id,
cru.identificador,
cs.T_id, 
cs.iliCode uso
,case when cs.ilicode is null then 'Fail' when cs.ilicode like '%PH%' then 'OK' else 'Fail' end as cond_3_3
from cca_predio p 
left join cca_condicionprediotipo c on c.T_Id = p.condicion_predio 
left join cca_construccion as ca on ca.predio = p.T_Id
left join cca_unidadconstruccion as cu on cu.construccion = ca.T_Id and cu.construccion is not null
left join cca_caracteristicasunidadconstruccion cru on cru.T_Id = cu.caracteristicasunidadconstruccion
left join cca_usouconstipo cs on cs.T_id = cru.uso
where c.T_id in ('2','3','4','5'))
select * from tb3 where cond_3_3 ='FAIL'