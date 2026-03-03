-- =========================================================
-- REGLA 44: Contacto visita no puede ser NIT
-- =========================================================
-- Descripción:
-- Si existe registro en contacto visita, no puede relacionar
-- tipo documento igual a NIT
-- =========================================================

-- Consulta que identifica predios con contacto de tipo NIT
SELECT
    p.t_id,
    p.numero_predial,
    idt.ilicode AS tipo_documento_quien_atendio,
    p.numero_documento_quien_atendio,
    p.nombres_apellidos_quien_atendio,
    'Error: El tipo de documento de quien atendió no puede ser NIT' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_interesadodocumentotipo idt ON p.tipo_documento_quien_atendio = idt.t_id
WHERE idt.ilicode = 'NIT'
  AND (
      p.numero_documento_quien_atendio IS NOT NULL
      AND p.numero_documento_quien_atendio != ''
  );
