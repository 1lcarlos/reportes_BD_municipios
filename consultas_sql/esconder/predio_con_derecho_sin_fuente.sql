--Predios que pueden tener derecho pero no fuente administrativa asociada
SELECT gp.*, 
       CASE 
           WHEN gf.id IS NOT NULL THEN '⚠ Tiene fuente sin derecho relacionado'
           ELSE '✔ Sin derecho ni fuente'
       END AS estado_relacional
FROM gc_predio gp
LEFT JOIN gc_derecho gd ON gp.id = gd.baunit
LEFT JOIN col_rrrfuente cr ON gd.id = cr.rrr_gc_derecho
LEFT JOIN gc_fuenteadministrativa gf ON cr.fuente_administrativa = gf.id
WHERE gd.id IS NULL;