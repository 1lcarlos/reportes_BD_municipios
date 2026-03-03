with tb4 as(select 
p.numero_predial
,c.ilicode condicion_predio, 
cru.T_Id,
cru.identificador,
cs.T_id, 
cs.iliCode uso
,case when cs.ilicode is null then 'Fail' when cs.ilicode not like '%PH%' then 'OK' else 'Fail' end as cond_3_4
from cca_predio p 
left join cca_condicionprediotipo c on c.T_Id = p.condicion_predio 
left join cca_construccion as ca on ca.predio = p.T_Id
left join cca_unidadconstruccion as cu on cu.construccion = ca.T_Id and cu.construccion is not null
left join cca_caracteristicasunidadconstruccion cru on cru.T_Id = cu.caracteristicasunidadconstruccion
left join cca_usouconstipo cs on cs.T_id = cru.uso
where c.T_id not in ('2','3','4','5') and c.T_id is not null)
select * from tb4 where cond_3_4 ='FAIL'