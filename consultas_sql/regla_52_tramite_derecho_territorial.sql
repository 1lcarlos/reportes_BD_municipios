-- =========================================================
-- REGLA 52: Trámite de derecho territorial consistente
-- =========================================================
-- Descripción:
-- Si se registra algún tipo de trámite de derecho territorial,
-- el trámite y la entidad deben ser correspondientes
-- =========================================================

-- Nota: Esta regla requiere conocer la estructura de trámites
-- y las relaciones válidas entre tipo de trámite y entidad

SELECT
    p.t_id,
    p.numero_predial,
    'Error: El tipo de trámite no corresponde con la entidad' AS mensaje_error
FROM cca_predio p
-- Ajustar según estructura real de trámites
/*
INNER JOIN cca_tramite_derecho td ON td.predio = p.t_id
LEFT JOIN cca_tramitetipo tt ON td.tipo_tramite = tt.t_id
LEFT JOIN cca_entidadtipo et ON td.entidad = et.t_id
WHERE NOT (
    -- Definir las correspondencias válidas entre trámite y entidad
    (tt.ilicode = 'X' AND et.ilicode = 'Y')
    OR (tt.ilicode = 'A' AND et.ilicode = 'B')
    -- ... más correspondencias
)
*/
WHERE FALSE;

-- Nota: Requiere conocer las correspondencias válidas entre
-- tipos de trámite y entidades según la normativa aplicable
