SELECT fa.id AS fuente_id
FROM cun25489.gc_fuenteadministrativa fa
-- Ver derechos asociados
LEFT JOIN (
    SELECT rrf.fuente_administrativa,
           d.baunit
    FROM cun25489.col_rrrfuente rrf
    LEFT JOIN cun25489.gc_derecho d
           ON rrf.rrr_gc_derecho = d.id
    WHERE d.baunit IS NOT NULL
) AS derechos_predio
    ON derechos_predio.fuente_administrativa = fa.id
-- Excluimos fuentes que ya tienen col_unidadfuente
LEFT JOIN cun25489.col_unidadfuente uf
       ON uf.fuente_administrativa = fa.id
WHERE uf.fuente_administrativa IS NULL
  AND derechos_predio.baunit IS NOT NULL;