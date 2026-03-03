-- ============================================================================
-- VALIDACIÓN: Unidades Informales - Superposición Geométrica
-- ============================================================================

WITH unidades_informales AS (
    -- Filtrar solo unidades de construcciones informales
    SELECT 
        uc.t_id AS unidad_id,
        uc.construccion,
        uc.planta_ubicacion,
        uc.tipo_planta,
        cplt.dispname AS planta_tipo,
        uc.geometria,
        p.numero_predial,
        cpt.dispname AS condicion_predio
    FROM lev_cca_manta2.cca_unidadconstruccion uc
    INNER JOIN lev_cca_manta2.cca_construccion c ON uc.construccion = c.t_id
    INNER JOIN lev_cca_manta2.cca_predio p ON c.predio = p.t_id
    INNER JOIN lev_cca_manta2.cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
    INNER JOIN lev_cca_manta2.cca_construccionplantatipo cplt ON uc.tipo_planta = cplt.t_id
    WHERE 
        -- Solo predios informales
        (cpt.dispname = 'Informal' 
         OR SUBSTRING(p.numero_predial, 22, 1) = '2')
        AND uc.geometria IS NOT NULL
)
-- Detectar unidades que se superponen en el mismo grupo
SELECT 
    -- Información de la primera unidad
    u1.unidad_id AS unidad_1_id,
    u1.planta_ubicacion AS planta_ubicacion_1,    
    -- Información de la segunda unidad
    u2.unidad_id AS unidad_2_id,
    u2.planta_ubicacion AS planta_ubicacion_2,    
    -- Información del grupo
    u1.construccion,
    u1.planta_tipo,
    u1.numero_predial,
    u1.condicion_predio,    
    -- Análisis de superposición
    ST_Area(ST_Intersection(u1.geometria, u2.geometria)) AS area_superposicion_m2,
    ST_Area(u1.geometria) AS area_unidad_1_m2,
    ST_Area(u2.geometria) AS area_unidad_2_m2,
    ROUND(
        (ST_Area(ST_Intersection(u1.geometria, u2.geometria)) / ST_Area(u1.geometria) * 100)::numeric, 
        2
    ) AS porcentaje_afectacion_u1,
    ROUND(
        (ST_Area(ST_Intersection(u1.geometria, u2.geometria)) / ST_Area(u2.geometria) * 100)::numeric, 
        2
    ) AS porcentaje_afectacion_u2,    
    -- Geometría de la intersección (opcional)
    ST_Intersection(u1.geometria, u2.geometria) AS geometria_interseccion
FROM unidades_informales u1
INNER JOIN unidades_informales u2 
    ON u1.construccion = u2.construccion          -- Misma construcción
    AND u1.planta_ubicacion = u2.planta_ubicacion -- Misma planta_ubicacion
    AND u1.planta_tipo = u2.planta_tipo           -- Mismo tipo_planta
    AND u1.unidad_id < u2.unidad_id               -- Evitar duplicados y auto-comparación
    AND ST_Overlaps(u1.geometria, u2.geometria)   -- Solo superposiciones reales
ORDER BY 
    u1.construccion, 
    u1.planta_ubicacion, 
    u1.planta_tipo, 
    area_superposicion_m2 DESC;