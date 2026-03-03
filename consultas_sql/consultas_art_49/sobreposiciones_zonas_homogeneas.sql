SELECT 
    a.id AS id_poligono_1,
    a.codigo_zona_geoeconomica AS codigo_zona_1,
    b.id AS id_poligono_2,
    b.codigo_zona_geoeconomica AS codigo_zona_2,
    ST_Area(ST_Intersection(a.geometria, b.geometria)) AS area_sobreposicion_m2,
    ST_Area(a.geometria) AS area_poligono_1_m2,
    ST_Area(b.geometria) AS area_poligono_2_m2,
    ROUND((ST_Area(ST_Intersection(a.geometria, b.geometria)) / ST_Area(a.geometria) * 100)::numeric, 2) AS porcentaje_sobre_poligono_1,
    ROUND((ST_Area(ST_Intersection(a.geometria, b.geometria)) / ST_Area(b.geometria) * 100)::numeric, 2) AS porcentaje_sobre_poligono_2,
    ST_Intersection(a.geometria, b.geometria) AS geometria_sobreposicion
FROM 
    zhg_rural a
    INNER JOIN zhg_rural b 
        ON ST_Intersects(a.geometria, b.geometria)
WHERE 
    a.id < b.id
    AND NOT ST_Touches(a.geometria, b.geometria)
    AND ST_Area(ST_Intersection(a.geometria, b.geometria)) > 10  -- Umbral mínimo 10 m²
ORDER BY 
    area_sobreposicion_m2 DESC;