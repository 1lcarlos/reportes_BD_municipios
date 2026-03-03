-- =========================================================
-- REGLA 49: Complemento de dirección para unidades prediales
-- =========================================================
-- Descripción:
-- Para predios con condición PH.Unidad_Predial o Condominio.Unidad_Predial,
-- la dirección asociada debe contener en el campo complemento al menos:
-- AP, BQ, BD, CS, ED, ET, GA, IN, L, LO, MZ, OF, PQ, PN, TO, UN, UR
-- (Apartamento, Bloque, Bodega, Casa, Edificio, Etapa, Garaje, Interior,
-- Local, Lote, Manzana, Oficina, Parqueadero, Pent-House, Torre, Unidad, Urbanización)
-- =========================================================

-- Consulta conceptual
SELECT
    p.t_id,
    p.numero_predial,
    cpt.ilicode AS condicion_predio,
    'Error: Unidades prediales de PH/Condominio deben tener complemento de dirección' AS mensaje_error
FROM cca_predio p
LEFT JOIN cca_condicionprediotipo cpt ON p.condicion_predio = cpt.t_id
WHERE cpt.ilicode IN ('PH.Unidad_Predial', 'Condominio.Unidad_Predial')
-- Ajustar según estructura real de direcciones
/*
  AND NOT EXISTS (
      SELECT 1 FROM extdireccion d
      WHERE d.cca_predio_direccion = p.t_id
        AND (
            d.complemento ~* '(^|[^A-Z])(AP|BQ|BD|CS|ED|ET|GA|IN|L|LO|MZ|OF|PQ|PN|TO|UN|UR)([^A-Z]|$)'
            OR d.complemento ~* '(APARTAMENTO|BLOQUE|BODEGA|CASA|EDIFICIO|ETAPA|GARAJE|INTERIOR|LOCAL|LOTE|MANZANA|OFICINA|PARQUEADERO|PENT.?HOUSE|TORRE|UNIDAD|URBANIZACION)'
        )
  )
*/
  AND FALSE;

-- Nota: Requiere adaptación según estructura real de direcciones
