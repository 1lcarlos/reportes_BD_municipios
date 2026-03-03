-- =========================================================
-- REGLA 46: Formato de correo electrónico válido
-- =========================================================
-- Descripción:
-- Si existe información en contacto visita y existe dato de
-- correo electrónico, debe tener una estructura lógica
-- (nombre del usuario@dominio)
-- =========================================================

-- Consulta que identifica correos con formato incorrecto
SELECT
    p.t_id,
    p.numero_predial,
    p.correo_electronico,
    'Error: El correo electrónico no tiene un formato válido' AS mensaje_error
FROM cca_predio p
WHERE p.correo_electronico IS NOT NULL
  AND p.correo_electronico != ''
  AND p.correo_electronico !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
