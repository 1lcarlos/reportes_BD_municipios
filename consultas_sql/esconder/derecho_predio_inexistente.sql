--derechos que apuntan a predios inexistentes
SELECT gd.*
FROM gc_derecho gd
LEFT JOIN gc_predio gp ON gd.baunit = gp.id
WHERE gp.id IS NULL;