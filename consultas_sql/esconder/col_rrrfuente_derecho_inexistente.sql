---col_rrrfuente relacionando derechos inexistentes
SELECT cr.*
FROM col_rrrfuente cr
LEFT JOIN gc_derecho gd ON cr.rrr_gc_derecho = gd.id
WHERE gd.id IS NULL;