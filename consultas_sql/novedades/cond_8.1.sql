--cond 8.1
--Predios asociados a desenglobes que NO tienen folio de matricula
SELECT
    enp.cca_predio_novedad_numeros_prediales AS predio_id,
    cp.tiene_fmi,
    cp.matricula_inmobiliaria,
    bt.ilicode AS tiene_fmi_texto,
    'Fail: desenglobe sin fmi' AS observacion
FROM cca_estructuranovedadnumeropredial enp
JOIN cca_estructuranovedadnumeropredial_tipo_novedad tn ON tn.t_id = enp.tipo_novedad
LEFT JOIN cca_predio cp ON cp.t_id = enp.cca_predio_novedad_numeros_prediales
LEFT JOIN cca_booleanotipo bt ON bt.t_id = cp.tiene_fmi
WHERE tn.dispname ilike '%desenglobe%'  
AND (cp.tiene_fmi IS NULL OR cp.matricula_inmobiliaria is null); 