---Consulta para identificar problemas en la geometría de terrenos y sus colindantes
WITH poligono_objetivo AS (
  SELECT geometria, codigo, ST_Envelope(geometria) AS env_obj
  FROM gc_terreno
  WHERE codigo in ('252690001000000080543000000000',
'252690100000000280042000000000',
'252690100000000540006000000000',
'252690100000000790225000000000',
'252690100000001120002000000000',
'252690100000001120003000000000',
'252690100000001520020000000000',
'252690100000001540012000000000',
'252690100000001540025000000000',
'252690100000001750001000000000',
'252690100000001860030000000000',
'252690100000002140007000000000',
'252690100000002280001000000000',
'252690100000002410001000000000',
'252690100000002760001000000000',
'252690100000005480001000000000',
'252690100000006100009000000000',
'252690100000007490084000000000')
),
problemas AS (
  SELECT
    t.codigo AS codigo,
    CASE
      WHEN ST_IsEmpty(t.geometria) THEN 'Geometría vacía'
      WHEN NOT ST_IsValid(t.geometria) THEN 'Geometría no válida'
      WHEN EXISTS (
        SELECT 1
        FROM gc_terreno t2
        WHERE t2.codigo <> t.codigo AND ST_Equals(t2.geometria, t.geometria)
      ) THEN 'Geometría duplicada'
      ELSE 'Geometría válida'
    END AS estado_geometria,
    NULL::text AS codigo_relacionado,
    NULL::double precision AS distancia_metros,
    NULL::text AS direccion_cardinal,
    NULL::text AS tipo_contacto,
    NULL::double precision AS longitud_contacto
  FROM gc_terreno t
  WHERE t.codigo in ('252690001000000080543000000000',
'252690100000000280042000000000',
'252690100000000540006000000000',
'252690100000000790225000000000',
'252690100000001120002000000000',
'252690100000001120003000000000',
'252690100000001520020000000000',
'252690100000001540012000000000',
'252690100000001540025000000000',
'252690100000001750001000000000',
'252690100000001860030000000000',
'252690100000002140007000000000',
'252690100000002280001000000000',
'252690100000002410001000000000',
'252690100000002760001000000000',
'252690100000005480001000000000',
'252690100000006100009000000000',
'252690100000007490084000000000')
),
colindantes AS (
  SELECT
    t1.codigo AS codigo,
    'Colindante' AS estado_geometria,
    t2.codigo AS codigo_relacionado,
    ST_Distance(t1.geometria, t2.geometria) AS distancia_metros,

    -- Dirección cardinal basada en envelope completo del colindante
    CASE
      WHEN abs((ST_YMax(env_col) + ST_YMin(env_col))/2 - (ST_YMax(t1.env_obj) + ST_YMin(t1.env_obj))/2) >
           abs((ST_XMax(env_col) + ST_XMin(env_col))/2 - (ST_XMax(t1.env_obj) + ST_XMin(t1.env_obj))/2)
        THEN
          CASE
            WHEN (ST_YMax(env_col) + ST_YMin(env_col))/2 > (ST_YMax(t1.env_obj) + ST_YMin(t1.env_obj))/2 THEN 'norte'
            ELSE 'sur'
          END
      ELSE
          CASE
            WHEN (ST_XMax(env_col) + ST_XMin(env_col))/2 > (ST_XMax(t1.env_obj) + ST_XMin(t1.env_obj))/2 THEN 'oriente'
            ELSE 'occidente'
          END
    END AS direccion_cardinal,

    -- Tipo de contacto
    CASE
      WHEN GeometryType(inter_geom) IN ('LINESTRING', 'MULTILINESTRING') THEN 'segmento'
      WHEN GeometryType(inter_geom) IN ('POINT', 'MULTIPOINT') THEN 'punto'
      WHEN GeometryType(inter_geom) IN ('POLYGON', 'MULTIPOLYGON') THEN 'area'
      ELSE 'otro'
    END AS tipo_contacto,

    -- Longitud del contacto (solo para líneas y polígonos)
    CASE
      WHEN GeometryType(inter_geom) IN ('LINESTRING', 'MULTILINESTRING', 'POLYGON', 'MULTIPOLYGON')
        THEN ST_Length(inter_geom)
      ELSE 0
    END AS longitud_contacto

  FROM poligono_objetivo t1
  JOIN gc_terreno t2
    ON t2.codigo <> t1.codigo
   AND (
        ST_Touches(t1.geometria, t2.geometria)
        OR ST_DWithin(t1.geometria, t2.geometria, 0.2)
       )
  CROSS JOIN LATERAL (
    SELECT
      ST_Intersection(t1.geometria, t2.geometria) AS inter_geom,
      ST_Envelope(t2.geometria) AS env_col
  ) inter
  WHERE
    GeometryType(inter_geom) IN ('LINESTRING', 'MULTILINESTRING', 'POLYGON', 'MULTIPOLYGON', 'POINT', 'MULTIPOINT')
)
SELECT * FROM problemas
UNION ALL
SELECT * FROM colindantes
order by codigo