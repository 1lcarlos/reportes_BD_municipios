--cond 2.19
with base as(
select
lp.numero_predial
,lr2.ilicode AS tipo_servidumbre
,case when cu.servidumbre_transito is null then 'Fail' else 'Ok' end as cond_2_19
from cca_predio lp 
left join cca_restriccion lr on lr.predio =lp.t_id 
left join cca_restricciontipo lr2 on lr2.t_id=lr.tipo 
left join cca_terreno cu on cu.predio =lp.t_id and cu.servidumbre_transito is not null
where lr2.ilicode='Servidumbre.Transito'
)
select * from base
where cond_2_19 ='Fail';