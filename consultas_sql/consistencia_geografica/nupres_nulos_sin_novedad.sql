--nupres nulos que no tienen novedad de cancelacion

select
p.numero_predial ,
p.nupre
,ent.dispname as tipo_novedad
from cca_predio p
left join cca_estructuranovedadnumeropredial ennp on p.t_id = ennp.cca_predio_novedad_numeros_prediales 
join cca_estructuranovedadnumeropredial_tipo_novedad ent on ennp.tipo_novedad = ent.t_id  
where 
ent.ilicode <> 'Cancelacion' and 
p.nupre is null