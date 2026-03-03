SELECT  uc.id, uc.*
FROM gc_unidadconstruccion uc
LEFT JOIN col_uebaunit col ON uc.id = col.ue_gc_unidadconstruccion
LEFT JOIN gc_predio as gp ON gp.id = col.unidad
WHERE col.ue_gc_unidadconstruccion IS NULL 

