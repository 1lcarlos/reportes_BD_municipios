 -- ============================================================================
-- VALIDACIÓN: Direcciones con mismas coordenadas en el mismo predio
-- Solo reporta como error si AMBOS predios son formales
-- ============================================================================

SELECT 
    d1.t_id AS direccion_1_id,
    d1.cca_predio_direccion AS predio_1_id,
    p1.numero_predial AS numero_predial_1,
    SUBSTRING(p1.numero_predial, 22, 1) AS posicion_22_predio_1,
    ST_AsText(d1.localizacion) AS coordenadas,
    ST_X(d1.localizacion) AS longitud,
    ST_Y(d1.localizacion) AS latitud,
    d2.t_id AS direccion_2_id,
    d2.cca_predio_direccion AS predio_2_id,
    p2.numero_predial AS numero_predial_2,
    SUBSTRING(p2.numero_predial, 22, 1) AS posicion_22_predio_2,
    ST_Distance(d1.localizacion, d2.localizacion) AS distancia_metros,
    'Diferentes Predios - Coordenadas Duplicadas' AS tipo_problema
FROM lev_cca_manta2.extdireccion d1
INNER JOIN lev_cca_manta2.extdireccion d2 
    ON d1.cca_predio_direccion <> d2.cca_predio_direccion
    AND d1.t_id < d2.t_id
    AND ST_Equals(d1.localizacion, d2.localizacion)
INNER JOIN lev_cca_manta2.cca_predio p1 
    ON d1.cca_predio_direccion = p1.t_id
INNER JOIN lev_cca_manta2.cca_predio p2 
    ON d2.cca_predio_direccion = p2.t_id
WHERE 
    d1.localizacion IS NOT NULL 
    AND d2.localizacion IS NOT NULL
    AND SUBSTRING(p1.numero_predial, 22, 1) <> '2'  -- Predio 1 formal
    AND SUBSTRING(p2.numero_predial, 22, 1) <> '2'  -- Predio 2 formal
ORDER BY ST_X(d1.localizacion), ST_Y(d1.localizacion);