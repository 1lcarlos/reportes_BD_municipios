-- ============================================================================
-- VALIDACIÓN: Tolerancias de área catastral - TODOS los predios (CORREGIDA)
-- Para predios EN conservación: SIEMPRE área_catastral vs geométrica
-- Para predios SIN conservación: área_registral vs geométrica (si existe registral)
-- ============================================================================

WITH datos_base AS (
    -- LEFT JOIN desde cca_predio para incluir TODOS los predios
    SELECT 
        p.numero_predial AS numero_predial_actualizacion,
        p.area_registral_m2 AS area_registral_actualizacion,
        p.matricula_inmobiliaria,
        p.t_id AS predio_id,
        t.area_terreno,
        ROUND(ST_Area(t.geometria)::numeric, 2) AS area_geometrica,
        ent.dispname AS tipo_novedad,
        
        -- Datos de conservación (pueden ser NULL)
        gt.numero_predial AS numero_predial_conservacion,
        gt.area_catastral AS area_catastral_conservacion,
        gt.area_construida AS area_construida_conservacion,
        
        -- Indicador de si tiene dato de conservación
        CASE 
            WHEN gt.numero_predial IS NOT NULL THEN 'Sí'
            ELSE 'No'
        END AS tiene_dato_conservacion,
        
        -- Identificar tipo de zona según posiciones 6-7
        SUBSTRING(p.numero_predial, 6, 2) AS codigo_zona,
        CASE 
            WHEN SUBSTRING(p.numero_predial, 6, 2) = '01' THEN 'Urbana'
            WHEN SUBSTRING(p.numero_predial, 6, 2) <> '00' THEN 'Rural con comportamiento urbano'
            ELSE 'Rural sin comportamiento urbano'
        END AS tipo_zona,
        
        -- ALERTA: Tiene matrícula pero no tiene área registral
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
    -- Determinar qué área catastral usar y calcular diferencia porcentual
    SELECT 
        *,
        -- Determinar si tiene novedad relevante (solo aplica para predios SIN conservación)
        CASE 
            WHEN tiene_dato_conservacion = 'No' 
                 AND tipo_novedad IN ('Predio_Nuevo', 'Desenglobe', 'Englobe') 
            THEN TRUE
            ELSE FALSE
        END AS tiene_novedad_relevante,
        
        -- Determinar área catastral a comparar según el caso
        CASE 
            -- CASO 1: Predio CON conservación → SIEMPRE usar área_catastral
            WHEN tiene_dato_conservacion = 'Sí' THEN area_catastral_conservacion
            
            -- CASO 2: Predio SIN conservación
            ELSE
                CASE 
                    -- Si tiene alerta de matrícula sin registral, usar NULL para no comparar
                    WHEN alerta_matricula_sin_registral IS NOT NULL THEN NULL
                    -- Si tiene área registral, usarla
                    WHEN area_registral_actualizacion IS NOT NULL AND area_registral_actualizacion > 0 
                        THEN area_registral_actualizacion
                    -- Si no tiene área registral, no hay comparación (usar NULL)
                    ELSE NULL
                END
        END AS area_catastral_comparar,
        
        -- Determinar tipo de comparación realizada
        CASE 
            -- Casos CON conservación → SIEMPRE catastral vs geométrica
            WHEN tiene_dato_conservacion = 'Sí' THEN 'Área Catastral vs Geométrica'
            
            -- Casos SIN conservación
            ELSE
                CASE 
                    WHEN alerta_matricula_sin_registral IS NOT NULL 
                        THEN 'ALERTA: Tiene matrícula sin área registral'
                    WHEN area_registral_actualizacion IS NOT NULL AND area_registral_actualizacion > 0
                        THEN 'Área Registral vs Geométrica (Sin conservación)'
                    ELSE 'Solo Área Geométrica (Sin registral)'
                END
        END AS tipo_comparacion,
        
        -- Calcular diferencia porcentual: |Ageom - Acat| / Ageom * 100
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
        
        -- Validar si área_terreno = área_geométrica
        CASE 
            WHEN ROUND(area_terreno::numeric, 2) = ROUND(area_geometrica::numeric, 2) 
                THEN 'IGUAL'
            ELSE 'DIFERENTE - ALERTA'
        END AS validacion_area_terreno,
        
        ABS(ROUND(area_terreno::numeric, 2) - ROUND(area_geometrica::numeric, 2)) AS diferencia_area_terreno
        
    FROM datos_base
),

aplicar_tolerancias AS (
    -- Aplicar tabla de tolerancias según tipo de zona y rango de área
    SELECT 
        *,
        -- Determinar tolerancia aplicable
        CASE 
            -- Urbana o rural con comportamiento urbano
            WHEN tipo_zona IN ('Urbana', 'Rural con comportamiento urbano') THEN
                CASE 
                    WHEN area_geometrica <= 80 THEN 7
                    WHEN area_geometrica > 80 AND area_geometrica <= 250 THEN 6
                    WHEN area_geometrica > 250 AND area_geometrica <= 500 THEN 4
                    WHEN area_geometrica > 500 THEN 3
                END
            -- Rural sin comportamiento urbano
            WHEN tipo_zona = 'Rural sin comportamiento urbano' THEN
                CASE 
                    WHEN area_geometrica <= 2000 THEN 10
                    WHEN area_geometrica > 2000 AND area_geometrica <= 10000 THEN 9
                    WHEN area_geometrica > 10000 AND area_geometrica <= 100000 THEN 7
                    WHEN area_geometrica > 100000 AND area_geometrica <= 500000 THEN 4
                    WHEN area_geometrica > 500000 THEN 2
                END
        END AS tolerancia_porcentaje,
        
        -- Descripción del rango aplicable
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
    -- Determinar si cumple tolerancia y calcular nueva área catastral
    SELECT 
        *,
        -- Validar si cumple con la tolerancia
        CASE 
            WHEN diferencia_porcentual IS NULL THEN 'N/A'
            WHEN diferencia_porcentual <= tolerancia_porcentaje THEN 'CUMPLE'
            ELSE 'NO CUMPLE'
        END AS cumple_tolerancia,
        
        -- Determinar nueva área catastral según reglas
        CASE 
            -- Si hay alerta de matrícula sin registral, tomar geométrica
            WHEN alerta_matricula_sin_registral IS NOT NULL THEN area_geometrica
            
            -- Si no hay área para comparar (sin conservación y sin registral), tomar geométrica
            WHEN area_catastral_comparar IS NULL THEN area_geometrica
            
            -- Para predios CON conservación
            WHEN tiene_dato_conservacion = 'Sí' THEN
                CASE 
                    WHEN diferencia_porcentual > tolerancia_porcentaje 
                        THEN area_geometrica  -- Supera tolerancia → adopta geométrica
                    ELSE area_catastral_conservacion  -- Dentro de tolerancia → mantiene catastral
                END
            
            -- Para predios SIN conservación pero CON registral
            WHEN tiene_dato_conservacion = 'No' 
                 AND area_registral_actualizacion IS NOT NULL 
                 AND area_registral_actualizacion > 0 THEN
                CASE 
                    WHEN diferencia_porcentual > tolerancia_porcentaje 
                        THEN area_geometrica  -- Supera tolerancia → adopta geométrica
                    ELSE area_registral_actualizacion  -- Dentro de tolerancia → mantiene registral
                END
            
            -- Fallback: tomar geométrica
            ELSE area_geometrica
        END AS nueva_area_catastral,
        
        -- Justificación de la decisión
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
)

-- RESULTADO FINAL
SELECT 
    numero_predial_actualizacion AS numero_predial,
    tiene_dato_conservacion,
    tipo_zona,
    tipo_novedad,
    tipo_comparacion,
    alerta_matricula_sin_registral,
    
    -- Áreas involucradas
    ROUND(area_catastral_comparar::numeric, 2) AS area_catastral_comparacion,
    ROUND(area_geometrica::numeric, 2) AS area_geometrica,
    ROUND(area_terreno::numeric, 2) AS area_terreno,
    
    -- Análisis de diferencias
    diferencia_porcentual AS diferencia_porcentual_calc,
    
    -- Validación área_terreno vs área_geométrica
    validacion_area_terreno,
    diferencia_area_terreno,
    
    -- Criterio de tolerancia aplicado
    rango_area_aplicable AS criterio_rango,
    tolerancia_porcentaje AS tolerancia_aplicada_pct,
    cumple_tolerancia,
    
    -- Nueva área catastral
    ROUND(nueva_area_catastral::numeric, 2) AS nueva_area_catastral,
    justificacion_nueva_area,
    
    -- Áreas originales para referencia
    ROUND(area_catastral_conservacion::numeric, 2) AS area_catastral_original,
    ROUND(area_registral_actualizacion::numeric, 2) AS area_registral_original,
    matricula_inmobiliaria

FROM resultado_final

ORDER BY 
    tiene_dato_conservacion DESC,
    CASE 
        WHEN alerta_matricula_sin_registral IS NOT NULL THEN 1
        WHEN cumple_tolerancia = 'NO CUMPLE' THEN 2
        WHEN cumple_tolerancia = 'CUMPLE' THEN 3
        ELSE 4
    END,
    diferencia_porcentual DESC NULLS LAST;