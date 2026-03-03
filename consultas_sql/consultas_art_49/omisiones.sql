select substring(gp.numero_predial, 6,2 ) as suelo, 
substring(gp.numero_predial, 14,4) as vereda, substring(gp.numero_predial, 18,4 ) as terreno,  
substring(gp.numero_predial, 22,1 ) as condicion,
gp.numero_predial, gt.id as terreno, gt.geometria 
from gc_predio gp 
left join col_uebaunit cu on gp.id=cu.unidad 
left join gc_terreno gt on cu.ue_gc_terreno = gt.id 
where substring(gp.numero_predial, 6,2 ) = '00' and cu.ue_gc_terreno is null
and substring(gp.numero_predial, 22,1 ) in  ('0')