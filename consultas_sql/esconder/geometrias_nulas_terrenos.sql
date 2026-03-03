---Geometrias nulas
SELECT id AS id_geom_nula, codigo 
FROM gc_terreno
WHERE geometria IS NULL;
