-- =========================================================
-- REGLA 02: Validación de longitud del número predial
-- =========================================================
-- Descripción:
-- El campo numero_predial debe contener exactamente 30 dígitos
-- tanto en cca_predio como en estructuras de novedad
-- =========================================================

-- Consulta que identifica predios con número predial que NO tiene 30 dígitos
SELECT
    p.t_id,
    p.numero_predial,
    LENGTH(p.numero_predial) AS longitud_actual,
    30 AS longitud_esperada,
    'Error: El número predial no contiene 30 dígitos' AS mensaje_error
FROM cca_predio p
WHERE LENGTH(p.numero_predial) != 30
   OR p.numero_predial !~ '^[0-9]{30}$';
