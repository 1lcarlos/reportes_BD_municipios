---predios que tienen registro alfanumérico sin terreno geográfico
--Condición Propiedad (0-8-9-2)

select p.t_id  as id_predio 
,p.numero_predial
, ent.dispname as tipo_novedad
, t.t_id as id_terreno
, 'Predio sin terreno-Posible omision'
from cca_predio p
left join cca_terreno t on p.t_id = t.predio
left join cca_estructuranovedadnumeropredial ennp on p.t_id = ennp.cca_predio_novedad_numeros_prediales 
join cca_estructuranovedadnumeropredial_tipo_novedad ent on ennp.tipo_novedad = ent.t_id  
where t.t_id is null and substring(p.numero_predial, 22,1 ) in ('8','0','9','2') and ent.ilicode <> 'Cancelacion'