---col_rrrfuente relacionando fuentes inexistentes
SELECT cr.*
FROM col_rrrfuente cr
LEFT JOIN gc_fuenteadministrativa gf ON cr.fuente_administrativa = gf.id
WHERE gf.id IS NULL;
