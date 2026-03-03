--Fuentes administrativas sin derechos asociados
SELECT gf.*, cr.*
FROM gc_fuenteadministrativa gf
LEFT JOIN col_rrrfuente cr ON gf.id = cr.fuente_administrativa
LEFT JOIN gc_derecho gd ON cr.rrr_gc_derecho = gd.id
WHERE gd.id IS NULL;
