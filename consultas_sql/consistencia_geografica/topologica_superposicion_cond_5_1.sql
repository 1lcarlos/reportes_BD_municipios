-- ============================================================================
-- VALIDACIÓN: Direcciones con mismas coordenadas en el mismo predio
-- ============================================================================

SELECT 
    -- Información de la primera dirección
    d1.t_id AS direccion_1_id,
    d1.cca_predio_direccion AS predio_id,
    p.numero_predial,
    ST_AsText(d1.localizacion) AS coordenadas_1,
    ST_X(d1.localizacion) AS longitud_1,
    ST_Y(d1.localizacion) AS latitud_1,    
    -- Información de la segunda dirección
    d2.t_id AS direccion_2_id,
    ST_AsText(d2.localizacion) AS coordenadas_2,
    ST_X(d2.localizacion) AS longitud_2,
    ST_Y(d2.localizacion) AS latitud_2,
        -- Confirmación de igualdad
    ST_Distance(d1.localizacion, d2.localizacion) AS distancia_metros,
    'Mismo Predio - Coordenadas Duplicadas' AS tipo_problema
FROM lev_cca_manta2.extdireccion d1
INNER JOIN lev_cca_manta2.extdireccion d2 
    ON d1.cca_predio_direccion = d2.cca_predio_direccion  -- Mismo predio
    AND d1.t_id < d2.t_id                                  -- Evitar duplicados
    AND ST_Equals(d1.localizacion, d2.localizacion)        -- Mismas coordenadas exactas
LEFT JOIN lev_cca_manta2.cca_predio p 
    ON d1.cca_predio_direccion = p.t_id
WHERE 
    d1.localizacion IS NOT NULL 
    AND d2.localizacion IS NOT NULL
ORDER BY p.numero_predial, d1.t_id;
