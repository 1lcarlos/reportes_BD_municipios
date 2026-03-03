
--unidades de construccion sin caracteristicas de unidad de construccion asociada

select uc.* from  
gc_unidadconstruccion as uc
left join gc_caracteristicasunidadconstruccion as cu
on uc.gc_caracteristicasunidadconstruccion = cu.id
where cu.id is null