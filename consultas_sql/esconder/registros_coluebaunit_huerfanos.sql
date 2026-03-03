-- Consulta para identificar registros en col_uebaunit con claves foráneas inválidas
SELECT cu.*
FROM col_uebaunit cu
left join gc_predio gp on cu.unidad = gp.id 
LEFT JOIN gc_construccion gc ON cu.ue_gc_construccion = gc.id
LEFT JOIN gc_terreno gt ON cu.ue_gc_terreno = gt.id
LEFT JOIN gc_unidadconstruccion guc ON cu.ue_gc_unidadconstruccion = guc.id
LEFT JOIN gc_servidumbretransito gs ON cu.ue_gc_servidumbretransito = gs.id
WHERE 
	(cu.unidad is not null and gp.id is null) or
    (cu.ue_gc_construccion IS NOT NULL AND gc.id IS NULL) OR
    (cu.ue_gc_terreno IS NOT NULL AND gt.id IS NULL) OR
    (cu.ue_gc_unidadconstruccion IS NOT NULL AND guc.id IS NULL) OR
    (cu.ue_gc_servidumbretransito IS NOT NULL AND gs.id IS NULL);