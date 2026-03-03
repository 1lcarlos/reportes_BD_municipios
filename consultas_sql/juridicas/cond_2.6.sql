--cond 2.6
with base as 
(
select 
lp.numero_predial
,lp2.iliCode AS tipo_predio
,ld2.ilicode tipo_derecho
,b.ilicode AS tiene_fmi
,lp.matricula_inmobiliaria 
,case when b.ilicode ='No' then 'Fail'
	when b.ilicode ='Si' and lp.matricula_inmobiliaria is not null then 'OK' end as cond_2_6
from cca_predio lp
left join cca_derecho ld on ld.predio =lp.t_id
left join cca_derechotipo ld2 on ld2.t_id =ld.tipo 
LEFT JOIN cca_booleanotipo b ON lp.tiene_fmi = b.t_id
left JOIN cca_prediotipo lp2 ON lp2.t_id =lp.predio_tipo
where ld2.ilicode ='Dominio'
and lp2.ilicode = 'Predio.Privado'
)
select * from base where cond_2_6 ='Fail';