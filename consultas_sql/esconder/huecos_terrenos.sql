-- 4. DETECCIÓN DE HUECOS (ÁREAS VACÍAS ENTRE POLÍGONOS)
-- Se genera un polígono envolvente (bounding envelope) del conjunto
-- y se calcula la diferencia con el union de los terrenos

-- Paso 4.1: Crear geometría unificada (todos los polígonos)
WITH union_geom AS (
  SELECT ST_Union(t.geometria) AS geom_union
  FROM {{schema}}.gc_terreno t
),

-- Paso 4.2: Cálculo del bounding polygon
envolvente AS (
  SELECT ST_Envelope(geom_union) AS geom_env
  FROM union_geom
),

-- Paso 4.3: Cálculo de huecos (espacios sin cubrir)
huecos AS (
  SELECT ST_Multi(ST_Difference(e.geom_env, u.geom_union)) AS geom_huecos
  FROM union_geom u, envolvente e
),

-- Paso 4.4: Explode de posibles huecos individuales
partes_huecos AS (
  SELECT (ST_Dump(geom_huecos)).geom AS geom
  FROM huecos
),

-- Paso 4.5: Filtrado por tamaño de hueco (por ejemplo, mayor a 1 m²)
huecos_filtrados AS (
  SELECT geom,
         ST_Area(geom) AS area_m2
  FROM partes_huecos
  --WHERE ST_Area(geom) > 1  -- Ajusta el umbral según criterio
)

-- Resultado final de huecos sospechosos
SELECT *
FROM huecos_filtrados;