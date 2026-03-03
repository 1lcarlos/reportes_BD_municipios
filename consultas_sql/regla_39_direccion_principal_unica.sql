-- =========================================================
-- REGLA 39: Dirección principal única
-- =========================================================
-- Descripción:
-- Si el predio tiene más de una dirección asignada,
-- solo una debe ser principal
-- =========================================================

-- Nota: Esta regla depende de cómo se almacenen las direcciones en el modelo.
-- Asumiendo que las direcciones están en un campo BAG dentro de cca_predio
-- o en una tabla relacionada, esta consulta es un ejemplo conceptual.

-- Consulta para verificar direcciones principales múltiples
-- (requiere adaptación según la estructura real de almacenamiento)

SELECT
    p.t_id,
    p.numero_predial,
    'Error: El predio tiene más de una dirección marcada como principal' AS mensaje_error
FROM cca_predio p
-- La siguiente subconsulta debe adaptarse a la estructura real
-- Si las direcciones están en una tabla separada:
/*
INNER JOIN (
    SELECT
        predio_id,
        COUNT(*) FILTER (WHERE es_principal = TRUE) AS principales
    FROM extdireccion
    GROUP BY predio_id
    HAVING COUNT(*) FILTER (WHERE es_principal = TRUE) > 1
) dir ON dir.predio_id = p.t_id
*/
-- Placeholder: Esta regla requiere ajuste según estructura de direcciones
WHERE FALSE;

-- Nota: Ajustar esta consulta según la estructura real de las direcciones
-- en el modelo INTERLIS (ExtDireccion como BAG en cca_predio)
