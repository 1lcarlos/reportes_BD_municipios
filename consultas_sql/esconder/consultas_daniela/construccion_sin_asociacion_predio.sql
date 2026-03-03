--construcciones sin predio asociado
SELECT  c.id, c.*
FROM gc_construccion c
LEFT JOIN col_uebaunit col ON c.id = col.ue_gc_construccion
LEFT JOIN gc_predio as gp ON gp.id = col.unidad
WHERE col.ue_gc_construccion IS NULL

