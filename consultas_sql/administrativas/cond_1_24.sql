--cond 1_24 
WITH condiciones_validas AS (
    SELECT T_Id 
    FROM cca_condicionprediotipo 
    WHERE iliCode IN ('NPH', 'PH.Matriz', 'Condominio.Matriz', 'Condominio.Unidad_Predial', 'Informal',
                      'Via', 'Bien_Uso_Publico', 'Parque_Cementerio.Matriz', 'Parque_Cementerio.Unidad_Predial')
),

-- Condición 1: Predios con condiciones válidas deben estar en terreno
predios_sin_terreno AS (
    SELECT 
        p.numero_predial,
        p.condicion_predio,
        cp.iliCode AS condicion_predio_ili,
        t.T_Id AS terreno_id
    FROM cca_predio p
    LEFT JOIN cca_terreno t ON t.predio = p.T_Id
    LEFT JOIN cca_condicionprediotipo cp ON cp.T_Id = p.condicion_predio
    WHERE cp.T_Id IN (SELECT T_Id FROM condiciones_validas) -- Solo predios con condiciones válidas
    AND t.T_Id IS NULL -- No tienen representación en terreno
),

-- Condición 2: Terrenos deben tener predios con condiciones válidas
terrenos_sin_predio AS (
    SELECT 
        t.T_Id AS terreno_id,
        p.numero_predial,
        cp.iliCode AS condicion_predio_ili
    FROM cca_terreno t
    LEFT JOIN cca_predio p ON t.predio = p.T_Id
    LEFT JOIN cca_condicionprediotipo cp ON cp.T_Id = p.condicion_predio
    WHERE p.T_Id IS NULL -- Terreno sin predio asociado
    OR cp.T_Id NOT IN (SELECT T_Id FROM condiciones_validas) -- No tienen condiciones válidas
)

-- Resultado final combinando ambas condiciones
SELECT 
    'Condicion 1: Predios sin Terreno' AS cond_1_24, 
    numero_predial, 
    condicion_predio_ili, 
    NULL AS terreno_id
FROM predios_sin_terreno

UNION ALL

SELECT 
    'Condicion 2: Terrenos sin Predio' AS cond_1_24, 
    NULL AS numero_predial, 
    condicion_predio_ili, 
    terreno_id
FROM terrenos_sin_predio;