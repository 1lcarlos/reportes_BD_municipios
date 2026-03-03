-- ============================================================================
-- VALIDACIÓN: Unidades Formales - Superposición Geométrica y Orden Lógico
-- ============================================================================

WITH unidades_formales AS (
    -- Filtrar solo unidades de construcciones formales
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
        -- Solo predios formales (NO informales)
        cpt.dispname <> 'Informal' 
        AND SUBSTRING(p.numero_predial, 22, 1) <> '2'
        AND uc.geometria IS NOT NULL
),
superposiciones_geometricas AS (
    -- Detectar unidades que se superponen geométricamente en el mismo grupo
    SELECT DISTINCT
        u1.unidad_id AS unidad_1_id,
        u1.planta_ubicacion AS planta_1,
        u2.unidad_id AS unidad_2_id,
        u2.planta_ubicacion AS planta_2,
        u1.construccion,
        u1.planta_tipo,
        u1.numero_predial,
        ST_Area(ST_Intersection(u1.geometria, u2.geometria)) AS area_superposicion_m2,
        'Superposición Geométrica' AS tipo_violacion
    FROM unidades_formales u1
    INNER JOIN unidades_formales u2 
        ON u1.construccion = u2.construccion
        AND u1.planta_tipo = u2.planta_tipo
        AND u1.unidad_id < u2.unidad_id  -- Evitar duplicados y auto-comparación
        AND ST_Overlaps(u1.geometria, u2.geometria)  -- Solo superposiciones reales (no toques)
),
orden_plantas AS (
    -- Verificar orden lógico de planta_ubicacion
    SELECT 
        unidad_id,
        planta_ubicacion,
        construccion,
        planta_tipo,
        numero_predial,
        LAG(planta_ubicacion) OVER (
            PARTITION BY construccion, planta_tipo 
            ORDER BY planta_ubicacion
        ) AS planta_anterior,
        LEAD(planta_ubicacion) OVER (
            PARTITION BY construccion, planta_tipo 
            ORDER BY planta_ubicacion
        ) AS planta_siguiente,
        ROW_NUMBER() OVER (
            PARTITION BY construccion, planta_tipo 
            ORDER BY planta_ubicacion
        ) AS posicion_actual
    FROM unidades_formales
),
violaciones_orden AS (
    -- Detectar unidades con planta_ubicacion duplicada o fuera de secuencia
    SELECT 
        op1.unidad_id AS unidad_1_id,
        op1.planta_ubicacion AS planta_1,
        op2.unidad_id AS unidad_2_id,
        op2.planta_ubicacion AS planta_2,
        op1.construccion,
        op1.planta_tipo,
        op1.numero_predial,
        NULL::numeric AS area_superposicion_m2,
        CASE 
            WHEN op1.planta_ubicacion = op2.planta_ubicacion 
                THEN 'Planta Duplicada'
            ELSE 'Desorden en Secuencia'
        END AS tipo_violacion
    FROM orden_plantas op1
    INNER JOIN orden_plantas op2 
        ON op1.construccion = op2.construccion
        AND op1.planta_tipo = op2.planta_tipo
        AND op1.unidad_id < op2.unidad_id
    WHERE 
        -- Detectar plantas duplicadas
        op1.planta_ubicacion = op2.planta_ubicacion
        -- O desorden: una planta posterior tiene valor menor
        OR (op1.posicion_actual < op2.posicion_actual 
            AND op1.planta_ubicacion > op2.planta_ubicacion)
)
-- RESULTADO FINAL: Unión de todas las violaciones
SELECT * FROM superposiciones_geometricas
UNION ALL
SELECT * FROM violaciones_orden
ORDER BY construccion, planta_tipo, tipo_violacion, unidad_1_id;