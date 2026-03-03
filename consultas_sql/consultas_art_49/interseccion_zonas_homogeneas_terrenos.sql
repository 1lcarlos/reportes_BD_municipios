SET work_mem = '1GB';
-- EXPLAIN ANALYZE
WITH intersecciones_raw AS (
    SELECT 
        p.departamento,
        p.municipio,
        p.numero_predial_anterior,
        p.numero_predial,
        p.codigo_orip,
        p.matricula_inmobiliaria,
        SUBSTRING(p.numero_predial FROM 18 FOR 4) AS codigo_lote,
        dt.dispname AS destino_economico,
        a.avaluo_catastral AS valor_avaluo,
        p.area AS area_terreno_m2,
        p.area_construida AS area_construida_m2,
        z.codigo_zona_geoeconomica,
        z.valor_hectarea_agropecuario,
        t.geometria,        
        ST_Intersection(t.geometria, z.geometria) AS geom_interseccion
    FROM 
        gc_predio AS p
    INNER JOIN 
        col_uebaunit AS col ON p.id = col.unidad
    INNER JOIN 
        gc_terreno AS t ON t.id = col.ue_gc_terreno
    INNER JOIN 
        gc_destinacioneconomicatipo AS dt ON p.destinacion_economica = dt.id
    INNER JOIN 
        extavaluo AS a ON a.gc_predio_avaluo = p.id
    INNER JOIN 
        zhg_rural AS z ON t.geometria && z.geometria 
                                AND ST_Intersects(t.geometria, z.geometria)
    WHERE 
        a.vigencia = '2025-01-01' and
        substring(p.numero_predial, 6,2 ) = '00'
        --AND p.numero_predial = '258850001000000130057000000000'
),
intersecciones AS (
    SELECT 
        *,        
        ST_Area(geom_interseccion) AS area_en_zonageoeconomica_m2
    FROM intersecciones_raw
),
total_area AS (
    SELECT 
        numero_predial,
        SUM(area_en_zonageoeconomica_m2) AS suma_area_zonageo_m2
    FROM intersecciones
    GROUP BY numero_predial
)
SELECT 
    i.departamento,
    i.municipio,
    i.numero_predial_anterior,
    i.numero_predial,
    i.codigo_orip,
    i.matricula_inmobiliaria,
    i.codigo_lote,
    i.destino_economico,
    i.valor_avaluo,
    i.area_terreno_m2,
    i.area_en_zonageoeconomica_m2,
    (i.area_en_zonageoeconomica_m2 / NULLIF(t.suma_area_zonageo_m2, 0)) * 100 AS porcentaje_en_zonageo_respecto_suma,
    i.area_construida_m2,
    i.codigo_zona_geoeconomica,
    i.valor_hectarea_agropecuario,
    i.geom_interseccion AS geometria_interseccion,
    i.geometria
FROM 
    intersecciones i
JOIN 
    total_area t ON i.numero_predial = t.numero_predial
ORDER BY 
    porcentaje_en_zonageo_respecto_suma DESC;