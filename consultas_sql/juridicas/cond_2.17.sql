--cond 2.17
with base as(
select 
lp.numero_predial
,b.ilicode as tiene_fmi
,lp.matricula_inmobiliaria 
,case when b.ilicode ='Si' then 'Fail' else 'Ok' end as cond_2_17
from cca_predio lp
JOIN cca_booleanotipo b ON lp.tiene_fmi = b.t_id
where length(lp.matricula_inmobiliaria)>7
)
select * from base
where cond_2_17='Fail';