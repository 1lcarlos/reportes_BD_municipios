
--unidades de construccion sin construcciones asociadas

select uc.* from  
gc_unidadconstruccion as uc
left join gc_construccion as c
on uc.gc_construccion = c.id
where c.id is null