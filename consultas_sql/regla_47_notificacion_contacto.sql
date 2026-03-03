-- =========================================================
-- REGLA 47: Autorización de notificación requiere contacto
-- =========================================================
-- Descripción:
-- Si existe información en contacto de visita y el campo
-- autoriza notificaciones es verdadero, entonces el campo
-- celular y/o correo electrónico debe estar diligenciado
-- =========================================================

-- Nota: Este campo no parece estar en el modelo actual, pero la regla
-- se implementa conceptualmente

SELECT
    p.t_id,
    p.numero_predial,
    p.celular,
    p.correo_electronico,
    'Error: Si autoriza notificaciones, debe tener celular o correo diligenciado' AS mensaje_error
FROM cca_predio p
WHERE p.numero_documento_quien_atendio IS NOT NULL
  AND p.numero_documento_quien_atendio != ''
  -- Agregar condición de autoriza_notificaciones si existe el campo
  -- AND p.autoriza_notificaciones = TRUE
  AND (
      (p.celular IS NULL OR p.celular = '')
      AND (p.correo_electronico IS NULL OR p.correo_electronico = '')
  );
