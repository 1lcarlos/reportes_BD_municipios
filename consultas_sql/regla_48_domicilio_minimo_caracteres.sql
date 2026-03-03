-- =========================================================
-- REGLA 48: Domicilio de notificaciones mínimo 7 caracteres
-- =========================================================
-- Descripción:
-- El campo Domicilio_Notificaciones de la tabla de contacto
-- debe contener al menos 7 caracteres
-- =========================================================

-- Nota: Este campo puede estar en una tabla relacionada o como
-- parte de ExtDireccion. Consulta conceptual.

SELECT
    p.t_id,
    p.numero_predial,
    'Error: El domicilio de notificaciones debe tener al menos 7 caracteres' AS mensaje_error
FROM cca_predio p
-- Ajustar según la estructura real donde esté el domicilio de notificaciones
/*
INNER JOIN cca_contacto_visita cv ON cv.predio = p.t_id
WHERE cv.domicilio_notificaciones IS NOT NULL
  AND cv.domicilio_notificaciones != ''
  AND LENGTH(cv.domicilio_notificaciones) < 7
*/
WHERE FALSE;

-- Nota: Requiere adaptación según estructura real
