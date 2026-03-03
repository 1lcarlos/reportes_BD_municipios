SELECT gp.*
FROM gc_predio gp
LEFT JOIN col_uebaunit col ON gp.id = col.unidad
WHERE col.unidad IS NULL


