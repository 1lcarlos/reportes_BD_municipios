SELECT 
    a.id AS id_1, a.codigo as codigo_1, 
    b.id AS id_2, b.codigo as codigo_2,
    ROUND(ST_Area(ST_Intersection(a.geometria, b.geometria))::numeric, 2) AS aSolapem2,
    ST_Intersection(a.geometria, b.geometria) AS geometria
FROM {{schema}}.gc_terreno a
JOIN {{schema}}.gc_terreno b
  ON a.id < b.id
WHERE substring(a.codigo,22,1) NOT IN ('2','5') AND substring(B.codigo,22,1) NOT IN ('2','5') 
    AND a.geometria IS NOT NULL AND b.geometria IS NOT NULL -- Validar que ambas geometrías no sean NULL y sean válidas
    AND ST_IsValid(a.geometria)
    AND ST_IsValid(b.geometria)-- Validar que se intersectan (realmente se solapan)ST_Intersects(a.geometria, b.geometria)
  AND NOT ST_Touches(a.geometria, b.geometria)
  AND ST_Area(ST_Intersection(a.geometria, b.geometria)) > 0.0001
ORDER BY aSolapem2 DESC;