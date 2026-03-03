 select cu.ue_gc_unidadconstruccion, count(cu.ue_gc_unidadconstruccion) as cantidad from gc_predio gp 
 left join col_uebaunit cu on gp.id=cu.unidad 
 left join gc_unidadconstruccion gu on cu.ue_gc_unidadconstruccion = gu.id
 left join gc_construccion gc on cu.ue_gc_construccion = gc.id 
 left join gc_terreno gt on cu.ue_gc_terreno = gt.id 
 where cu.ue_gc_unidadconstruccion is not null
 group by cu.ue_gc_unidadconstruccion