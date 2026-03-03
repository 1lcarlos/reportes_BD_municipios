--Terreno geográfico sin registro alfanumérico
--Condición Propiedad (0-8-9-2) posibles comisiones

select 
p.numero_predial
,p.nupre
,gt.codigo_terreno as codigo_terreno_consevacion
from public.gc_terreno gt 
left join cca_predio p on gt.numero_predial = p.numero_predial 
left join cca_terreno t on p.t_id  = t.predio
left join cca_estructuranovedadnumeropredial ennp on gt.codigo_terreno = ennp.numero_predial 
where p.numero_predial is null and substring (gt.codigo_terreno, 6 , 2) <> ('01') and ennp.numero_predial is null
