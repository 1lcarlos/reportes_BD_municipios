SELECT  t.*
FROM gc_terreno t
LEFT JOIN col_uebaunit col ON t.id = col.ue_gc_terreno
LEFT JOIN gc_predio as gp ON gp.id = col.unidad
WHERE col.ue_gc_terreno IS NULL 


