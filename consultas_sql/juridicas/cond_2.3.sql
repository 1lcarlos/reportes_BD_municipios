--cond 2.3
with base as
(
select 
lp.numero_predial
,ld2.ilicode tipo_derecho
,ld.fraccion_derecho
,case when ld.fraccion_derecho between 0 and 1 then 'Ok' else 'Fail' end as cond_2_3
from cca_predio lp 
inner join cca_derecho ld on ld.predio =lp.t_id 
left join cca_derechotipo ld2 on ld2.t_id =ld.tipo
where ld2.ilicode in ('Ocupacion','Posesion')
)
select * from base
where cond_2_3 ='Fail';