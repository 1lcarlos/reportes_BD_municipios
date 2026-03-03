--cond 2.11
with base as 
(
select 
lp.numero_predial
,lpt.ilicode AS tipo_predio
,lg.ilicode grupo_etnico
,lpt.iliCode AS tipo_predio
,ld2.ilicode AS tipo_derecho
from cca_predio lp
left join cca_derecho ld on ld.predio =lp.t_id
left join cca_derechotipo ld2 on ld2.t_id =ld.tipo 
left join cca_interesado li on li.t_id =ld.interesado 
left join cca_grupoetnicotipo lg on lg.t_id =li.grupo_etnico
LEFT JOIN cca_prediotipo lpt ON lpt.t_id = lp.predio_tipo 
WHERE lpt.iliCode = 'Predio.Territorio_Colectivo'
)
select *,'Fail' cond_2_11 from base
WHERE grupo_etnico = 'Ninguno' OR grupo_etnico IS NULL OR grupo_etnico = '';