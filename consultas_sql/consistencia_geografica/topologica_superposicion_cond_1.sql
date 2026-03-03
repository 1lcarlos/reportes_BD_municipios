---Terreno-Informal (NP posición 22 igual "2") asociado a un derecho de "Posesión" no debe superponerse con un Terreno asociado a un Predio.Tipo  “Público”.
WITH terrenos_informales_posesion AS (
    -- Terrenos asociados a predios informales (pos 22 = '2') con derecho de Posesión
    SELECT DISTINCT
        t.t_id AS terreno_id,
        t.geometria,
        p.numero_predial,
        p.t_id AS predio_id,
        pt.dispname AS tipo_predio
        ,dt.ilicode as dercho_tipo
    FROM lev_cca_manta2.cca_terreno t
    INNER JOIN lev_cca_manta2.cca_predio p ON t.predio = p.t_id
    INNER JOIN lev_cca_manta2.cca_prediotipo pt ON p.predio_tipo = pt.t_id
    INNER JOIN lev_cca_manta2.cca_derecho d ON p.t_id = d.predio
    INNER JOIN lev_cca_manta2.cca_derechotipo dt ON d.tipo = dt.t_id
    WHERE 
        -- Validar que el carácter en posición 22 sea '2' (informal)
        SUBSTRING(p.numero_predial, 22, 1) = '2'
        -- Validar que tenga al menos un derecho de Posesión
        AND dt.ilicode = 'Posesion'
        -- Asegurar que la geometría sea válida
        AND t.geometria IS NOT NULL
),
terrenos_publicos AS (
    -- Terrenos asociados a predios públicos
    SELECT DISTINCT
        t.t_id AS terreno_id,
        t.geometria,
        p.numero_predial,
        p.t_id AS predio_id,
        pt.dispname AS tipo_predio		
    FROM lev_cca_manta2.cca_terreno t
    INNER JOIN lev_cca_manta2.cca_predio p ON t.predio = p.t_id
    INNER JOIN lev_cca_manta2.cca_prediotipo pt ON p.predio_tipo = pt.t_id
    WHERE 
        pt.ilicode ilike '%Publico%'
        AND t.geometria IS NOT NULL
) 
-- Detectar superposiciones espaciales
SELECT     -- Información del terreno informal
    tip.terreno_id AS terreno_informal_id,
    tip.numero_predial AS numero_predial_informal,
    tip.predio_id AS predio_informal_id,
    tip.tipo_predio AS tipo_predio_informal,    
    -- Información del terreno público
    tpub.terreno_id AS terreno_publico_id,
    tpub.numero_predial AS numero_predial_publico,
    tpub.predio_id AS predio_publico_id,
    tpub.tipo_predio AS tipo_predio_publico,    
    -- Análisis espacial
    ST_Area(ST_Intersection(tip.geometria, tpub.geometria)) AS area_superposicion_m2,
    ST_Area(tip.geometria) AS area_informal_m2,
    ROUND(
        (ST_Area(ST_Intersection(tip.geometria, tpub.geometria)) / ST_Area(tip.geometria) * 100)::numeric, 
        2
    ) AS porcentaje_afectacion,    
    -- Geometría de la intersección (opcional, comentar si no se necesita)
    ST_Intersection(tip.geometria, tpub.geometria) AS geometria_interseccion
FROM terrenos_informales_posesion tip
INNER JOIN terrenos_publicos tpub 
    ON ST_Intersects(tip.geometria, tpub.geometria)
 where ROUND(
        (ST_Area(ST_Intersection(tip.geometria, tpub.geometria)) / ST_Area(tip.geometria) * 100)::numeric, 
        2
    ) > 0
ORDER BY area_superposicion_m2 DESC;