	--derechos sin predios, ni fuentes administrativas asociadas
	SELECT gd.*
	FROM gc_derecho gd
	LEFT JOIN gc_predio gp ON gd.baunit = gp.id
	LEFT JOIN col_rrrfuente cr ON gd.id = cr.rrr_gc_derecho
	LEFT JOIN gc_fuenteadministrativa gf ON cr.fuente_administrativa = gf.id
	WHERE gp.id IS NULL AND gf.id IS NULL;