-- ============================================================================
-- VALIDACIÓN: Tolerancias de área catastral + Comparación con areas_manta_v2026
-- CORREGIDA - Conversión de tipos de datos
-- ============================================================================

WITH datos_base AS (
    SELECT 
        p.numero_predial AS numero_predial_actualizacion,
        p.area_registral_m2 AS area_registral_actualizacion,
        p.matricula_inmobiliaria,
        p.t_id AS predio_id,
        t.area_terreno,
        ROUND(ST_Area(t.geometria)::numeric, 2) AS area_geometrica,
        ent.dispname AS tipo_novedad,
        
        gt.numero_predial AS numero_predial_conservacion,
        gt.area_catastral AS area_catastral_conservacion,
        gt.area_construida AS area_construida_conservacion,
        
        CASE 
            WHEN gt.numero_predial IS NOT NULL THEN 'Sí'
            ELSE 'No'
        END AS tiene_dato_conservacion,
        
        SUBSTRING(p.numero_predial, 6, 2) AS codigo_zona,
        CASE 
            WHEN SUBSTRING(p.numero_predial, 6, 2) = '01' THEN 'Urbana'
            WHEN SUBSTRING(p.numero_predial, 6, 2) <> '00' THEN 'Rural con comportamiento urbano'
            ELSE 'Rural'
        END AS tipo_zona,
        
        CASE 
            WHEN p.matricula_inmobiliaria IS NOT NULL 
                 AND (p.area_registral_m2 IS NULL OR p.area_registral_m2 = 0)
            THEN 'ALERTA: Tiene matrícula sin área registral'
            ELSE NULL
        END AS alerta_matricula_sin_registral
        
    FROM lev_cca_manta2.cca_predio p
    INNER JOIN lev_cca_manta2.cca_terreno t ON p.t_id = t.predio
    LEFT JOIN public.gc_terreno gt ON p.numero_predial = gt.numero_predial
    LEFT JOIN lev_cca_manta2.cca_estructuranovedadnumeropredial ennp 
        ON p.t_id = ennp.cca_predio_novedad_numeros_prediales
    LEFT JOIN lev_cca_manta2.cca_estructuranovedadnumeropredial_tipo_novedad ent 
        ON ennp.tipo_novedad = ent.t_id
    WHERE t.geometria IS NOT NULL
),

comparacion_areas AS (
    SELECT 
        *,
        CASE 
            WHEN tiene_dato_conservacion = 'No' 
                 AND tipo_novedad IN ('Predio_Nuevo', 'Desenglobe', 'Englobe') 
            THEN TRUE
            ELSE FALSE
        END AS tiene_novedad_relevante,
        
        CASE 
            WHEN tiene_dato_conservacion = 'Sí' THEN area_catastral_conservacion
            ELSE
                CASE 
                    WHEN alerta_matricula_sin_registral IS NOT NULL THEN NULL
                    WHEN area_registral_actualizacion IS NOT NULL AND area_registral_actualizacion > 0 
                        THEN area_registral_actualizacion
                    ELSE NULL
                END
        END AS area_catastral_comparar,
        
        CASE 
            WHEN tiene_dato_conservacion = 'Sí' THEN 'Área Catastral vs Geométrica'
            ELSE
                CASE 
                    WHEN alerta_matricula_sin_registral IS NOT NULL 
                        THEN 'ALERTA: Tiene matrícula sin área registral'
                    WHEN area_registral_actualizacion IS NOT NULL AND area_registral_actualizacion > 0
                        THEN 'Área Registral vs Geométrica (Sin conservación)'
                    ELSE 'Solo Área Geométrica (Sin registral)'
                END
        END AS tipo_comparacion,
        
        CASE 
            WHEN area_geometrica > 0 
                 AND (
                     (tiene_dato_conservacion = 'Sí' AND area_catastral_conservacion IS NOT NULL)
                     OR (tiene_dato_conservacion = 'No' 
                         AND area_registral_actualizacion IS NOT NULL 
                         AND area_registral_actualizacion > 0
                         AND alerta_matricula_sin_registral IS NULL)
                 )
            THEN
                ROUND(
                    (ABS(area_geometrica - 
                        CASE 
                            WHEN tiene_dato_conservacion = 'Sí' THEN area_catastral_conservacion
                            ELSE area_registral_actualizacion
                        END
                    ) / area_geometrica * 100)::numeric, 
                    2
                )
            ELSE NULL
        END AS diferencia_porcentual,
        
        CASE 
            WHEN ROUND(area_terreno::numeric, 2) = ROUND(area_geometrica::numeric, 2) 
                THEN 'IGUAL'
            ELSE 'DIFERENTE - ALERTA'
        END AS validacion_area_terreno,
        
        ABS(ROUND(area_terreno::numeric, 2) - ROUND(area_geometrica::numeric, 2)) AS diferencia_area_terreno
        
    FROM datos_base
),

aplicar_tolerancias AS (
    SELECT 
        *,
        CASE 
            WHEN tipo_zona IN ('Urbana', 'Rural con comportamiento urbano') THEN
                CASE 
                    WHEN area_geometrica <= 80 THEN 7
                    WHEN area_geometrica > 80 AND area_geometrica <= 250 THEN 6
                    WHEN area_geometrica > 250 AND area_geometrica <= 500 THEN 4
                    WHEN area_geometrica > 500 THEN 3
                END
            WHEN tipo_zona = 'Rural sin comportamiento urbano' THEN
                CASE 
                    WHEN area_geometrica <= 2000 THEN 10
                    WHEN area_geometrica > 2000 AND area_geometrica <= 10000 THEN 9
                    WHEN area_geometrica > 10000 AND area_geometrica <= 100000 THEN 7
                    WHEN area_geometrica > 100000 AND area_geometrica <= 500000 THEN 4
                    WHEN area_geometrica > 500000 THEN 2
                END
        END AS tolerancia_porcentaje,
        
        CASE 
            WHEN tipo_zona IN ('Urbana', 'Rural con comportamiento urbano') THEN
                CASE 
                    WHEN area_geometrica <= 80 THEN 'Menor o igual a 80 m²'
                    WHEN area_geometrica > 80 AND area_geometrica <= 250 THEN 'Mayor a 80 m² y menor o igual 250 m²'
                    WHEN area_geometrica > 250 AND area_geometrica <= 500 THEN 'Mayor a 250 m² y menor o igual 500 m²'
                    WHEN area_geometrica > 500 THEN 'Mayor a 500 m²'
                END
            WHEN tipo_zona = 'Rural sin comportamiento urbano' THEN
                CASE 
                    WHEN area_geometrica <= 2000 THEN 'Menor o igual a 2,000 m² (0.2 Ha)'
                    WHEN area_geometrica > 2000 AND area_geometrica <= 10000 THEN 'Mayor a 2,000 m² y menor o igual a 1 Ha'
                    WHEN area_geometrica > 10000 AND area_geometrica <= 100000 THEN 'Mayor a 1 Ha y menor o igual a 10 Ha'
                    WHEN area_geometrica > 100000 AND area_geometrica <= 500000 THEN 'Mayor a 10 Ha y menor o igual a 50 Ha'
                    WHEN area_geometrica > 500000 THEN 'Mayor a 50 Ha'
                END
        END AS rango_area_aplicable
        
    FROM comparacion_areas
),

resultado_final AS (
    SELECT 
        *,
        CASE 
            WHEN diferencia_porcentual IS NULL THEN 'N/A'
            WHEN diferencia_porcentual <= tolerancia_porcentaje THEN 'CUMPLE'
            ELSE 'NO CUMPLE'
        END AS cumple_tolerancia,
        
        CASE 
            WHEN alerta_matricula_sin_registral IS NOT NULL THEN area_geometrica
            WHEN area_catastral_comparar IS NULL THEN area_geometrica
            WHEN tiene_dato_conservacion = 'Sí' THEN
                CASE 
                    WHEN diferencia_porcentual > tolerancia_porcentaje 
                        THEN area_geometrica
                    ELSE area_catastral_conservacion
                END
            WHEN tiene_dato_conservacion = 'No' 
                 AND area_registral_actualizacion IS NOT NULL 
                 AND area_registral_actualizacion > 0 THEN
                CASE 
                    WHEN diferencia_porcentual > tolerancia_porcentaje 
                        THEN area_geometrica
                    ELSE area_registral_actualizacion
                END
            ELSE area_geometrica
        END AS nueva_area_catastral,
        
        CASE 
            WHEN alerta_matricula_sin_registral IS NOT NULL 
                THEN 'Se adopta área geométrica (tiene matrícula sin área registral)'
            WHEN area_catastral_comparar IS NULL AND tiene_dato_conservacion = 'No'
                THEN 'Se adopta área geométrica (sin conservación ni área registral)'
            WHEN tiene_dato_conservacion = 'Sí' THEN
                CASE 
                    WHEN diferencia_porcentual > tolerancia_porcentaje 
                        THEN 'Se adopta área geométrica (supera tolerancia en conservación)'
                    ELSE 'Se mantiene área catastral (dentro de tolerancia en conservación)'
                END
            WHEN tiene_dato_conservacion = 'No' 
                 AND area_registral_actualizacion IS NOT NULL 
                 AND area_registral_actualizacion > 0 THEN
                CASE 
                    WHEN diferencia_porcentual > tolerancia_porcentaje 
                        THEN 'Se adopta área geométrica (supera tolerancia sin conservación)'
                    ELSE 'Se mantiene área registral (dentro de tolerancia sin conservación)'
                END
            ELSE 'Se adopta área geométrica (caso especial)'
        END AS justificacion_nueva_area
        
    FROM aplicar_tolerancias
),

comparacion_con_manta AS (
    -- JOIN con la tabla areas_manta_v2026 - CONVERTIR campos de texto a numérico
    SELECT 
        rf.*,
        -- Convertir Area_total_terreno de VARCHAR a NUMERIC
        CASE 
            WHEN am."Area_total_terreno" IS NOT NULL 
                 AND am."Area_total_terreno" ~ '^[0-9]+\.?[0-9]*$'  -- Validar que sea numérico
            THEN am."Area_total_terreno"::numeric
            ELSE NULL
        END AS area_total_terreno_manta_v2026,
        
        -- Convertir Area_total_construida de VARCHAR a NUMERIC
        CASE 
            WHEN am."Area_total_construida" IS NOT NULL 
                 AND am."Area_total_construida" ~ '^[0-9]+\.?[0-9]*$'
            THEN am."Area_total_construida"::numeric
            ELSE NULL
        END AS area_total_construida_manta_v2026,
        
        am."Numero_predial" AS existe_en_manta,
        
        -- Calcular diferencia en m² (con conversión)
        CASE 
            WHEN am."Area_total_terreno" IS NOT NULL 
                 AND am."Area_total_terreno" ~ '^[0-9]+\.?[0-9]*$'
            THEN ROUND(ABS(rf.nueva_area_catastral - am."Area_total_terreno"::numeric)::numeric, 2)
            ELSE NULL
        END AS diferencia_con_manta_m2,
        
        -- Calcular diferencia porcentual (con conversión)
        CASE 
            WHEN am."Area_total_terreno" IS NOT NULL 
                 AND am."Area_total_terreno" ~ '^[0-9]+\.?[0-9]*$'
                 AND am."Area_total_terreno"::numeric > 0
            THEN ROUND((ABS(rf.nueva_area_catastral - am."Area_total_terreno"::numeric) / am."Area_total_terreno"::numeric * 100)::numeric, 2)
            ELSE NULL
        END AS diferencia_con_manta_pct,
        
        -- Mensaje de validación con areas_manta_v2026
        CASE 
            -- Predio no existe en areas_manta_v2026
            WHEN am."Numero_predial" IS NULL 
                THEN 'Predio no existe en areas_manta_v2026'
            
            -- Area_total_terreno no es numérico válido
            WHEN am."Area_total_terreno" IS NULL 
                 OR NOT (am."Area_total_terreno" ~ '^[0-9]+\.?[0-9]*$')
                THEN 'Error: Area_total_terreno no es numérico'
            
            -- Áreas exactamente iguales (redondeadas a 2 decimales)
            WHEN ROUND(rf.nueva_area_catastral::numeric, 2) = ROUND(am."Area_total_terreno"::numeric, 2)
                THEN 'IGUAL'
            
            -- Áreas distintas - clasificar por magnitud de diferencia
            ELSE
                CASE 
                    -- Pequeña diferencia: <= 5% Y <= 5 m²
                    WHEN ABS(rf.nueva_area_catastral - am."Area_total_terreno"::numeric) <= 5
                         AND (ABS(rf.nueva_area_catastral - am."Area_total_terreno"::numeric) / NULLIF(am."Area_total_terreno"::numeric, 0) * 100) <= 5
                    THEN 'DISTINTA - Pequeña diferencia'
                    
                    -- Diferencia significativa: > 5% O > 5 m²
                    ELSE 'DISTINTA - Diferencia significativa'
                END
        END AS validacion_area_manta_v2026
        
    FROM resultado_final rf
    LEFT JOIN public.areas_manta_v2026 am 
        ON rf.numero_predial_actualizacion = am."Numero_predial"
)

-- RESULTADO FINAL CON COMPARACIÓN DE MANTA
SELECT 
    numero_predial_actualizacion AS numero_predial,
    tiene_dato_conservacion,
    tipo_zona,
    tipo_novedad,
    tipo_comparacion,
    alerta_matricula_sin_registral,
    
    -- Áreas involucradas en el análisis de tolerancia
    ROUND(area_catastral_comparar::numeric, 2) AS area_catastral_comparacion,
    ROUND(area_geometrica::numeric, 2) AS area_geometrica,
    ROUND(area_terreno::numeric, 2) AS area_terreno,
    
    -- Análisis de diferencias con tolerancia
    diferencia_porcentual AS diferencia_porcentual_calc,
    validacion_area_terreno,
    diferencia_area_terreno,
    
    -- Criterio de tolerancia aplicado
    rango_area_aplicable AS criterio_rango,
    tolerancia_porcentaje AS tolerancia_aplicada_pct,
    cumple_tolerancia,
    
    -- Nueva área catastral calculada
    ROUND(nueva_area_catastral::numeric, 2) AS nueva_area_catastral,
    justificacion_nueva_area,
    
    -- Comparación con areas_manta_v2026
    ROUND(area_total_terreno_manta_v2026::numeric, 2) AS area_total_terreno_manta_v2026,
    ROUND(area_total_construida_manta_v2026::numeric, 2) AS area_total_construida_manta_v2026,
    diferencia_con_manta_m2,
    diferencia_con_manta_pct,
    validacion_area_manta_v2026,
    
    -- Áreas originales para referencia
    ROUND(area_catastral_conservacion::numeric, 2) AS area_catastral_original,
    ROUND(area_registral_actualizacion::numeric, 2) AS area_registral_original,
    matricula_inmobiliaria

FROM comparacion_con_manta

ORDER BY 
    tiene_dato_conservacion DESC,
    CASE validacion_area_manta_v2026
        WHEN 'DISTINTA - Diferencia significativa' THEN 1
        WHEN 'DISTINTA - Pequeña diferencia' THEN 2
        WHEN 'Predio no existe en areas_manta_v2026' THEN 3
        WHEN 'Error: Area_total_terreno no es numérico' THEN 4
        WHEN 'IGUAL' THEN 5
        ELSE 6
    END,
    CASE 
        WHEN alerta_matricula_sin_registral IS NOT NULL THEN 1
        WHEN cumple_tolerancia = 'NO CUMPLE' THEN 2
        WHEN cumple_tolerancia = 'CUMPLE' THEN 3
        ELSE 4
    END,
    diferencia_con_manta_pct DESC NULLS LAST;