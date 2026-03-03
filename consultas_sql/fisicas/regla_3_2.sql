with tb2 as(select 
p.numero_predial
,c.ilicode condicion_predio,
cru.T_Id,
cru.identificador,
cru.tipo_dominio
,case when c.ilicode = 'Privado' then 'Fail' when cd.ilicode ='Comun' then 'Ok' else 'Fail' end as cond_3_2
from cca_predio p 
left join cca_condicionprediotipo c on c.T_Id = p.condicion_predio 
left join cca_construccion as ca on ca.predio = p.T_Id
left join cca_unidadconstruccion as cu on cu.construccion = ca.T_Id and cu.construccion is not null
left join cca_caracteristicasunidadconstruccion cru on cru.T_Id = cu.caracteristicasunidadconstruccion
left join cca_dominioconstrucciontipo cd on cd.T_id = cru.tipo_dominio
where c.T_id in ('2','4'))
select * from tb2 where cond_3_2 ='Fail'
