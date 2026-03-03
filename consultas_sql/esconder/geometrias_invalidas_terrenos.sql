--Geometrias invalidas
SELECT id AS id_geom_invalida,
       ST_IsValidReason(geometria) AS razon
FROM gc_terreno
WHERE geometria IS NOT NULL AND NOT ST_IsValid(geometria);