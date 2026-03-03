-- =========================================================
-- REGLA 45: Documento de contacto debe ser numérico
-- =========================================================
-- Descripción:
-- Si existe registro en contacto visita, el número de documento
-- de quien atendió debe contener solamente caracteres numéricos
-- =========================================================

-- Consulta que identifica documentos con caracteres no numéricos
SELECT
    p.t_id,
    p.numero_predial,
    idt.ilicode AS tipo_documento_quien_atendio,
    p.numero_documento_quien_atendio,
    'Error: El número de documento de quien atendió debe ser solo numérico' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_interesadodocumentotipo idt ON p.tipo_documento_quien_atendio = idt.t_id
WHERE p.numero_documento_quien_atendio IS NOT NULL
  AND p.numero_documento_quien_atendio != ''
  AND p.numero_documento_quien_atendio !~ '^[0-9]+$';
