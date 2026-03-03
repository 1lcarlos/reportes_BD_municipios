-- =========================================================
-- REGLA 18: Validación de área registral vs FMI
-- =========================================================
-- Descripción:
-- Si los campos Codigo_ORIP y Matricula_Inmobiliaria no están
-- diligenciados, entonces Area_Registral_M2 debe ser cero.
-- De igual manera, si Area_Registral_M2 es mayor a cero,
-- los campos Codigo_ORIP y Matricula_Inmobiliaria deben estar
-- diligenciados.
-- =========================================================

-- Consulta que identifica predios que no cumplen la consistencia
SELECT
    p.t_id,
    p.numero_predial,
    p.codigo_orip,
    p.matricula_inmobiliaria,
    p.area_registral_m2,
    CASE
        WHEN (p.codigo_orip IS NULL OR p.codigo_orip = '' OR
              p.matricula_inmobiliaria IS NULL OR p.matricula_inmobiliaria = '')
             AND COALESCE(p.area_registral_m2, 0) > 0
            THEN 'Error: Si no hay FMI/ORIP, el área registral debe ser cero'
        WHEN COALESCE(p.area_registral_m2, 0) > 0
             AND (p.codigo_orip IS NULL OR p.codigo_orip = ''
                  OR p.matricula_inmobiliaria IS NULL OR p.matricula_inmobiliaria = '')
            THEN 'Error: Si hay área registral mayor a cero, debe existir FMI y código ORIP'
    END AS mensaje_error
FROM cca_predio p
WHERE
    -- Caso 1: Sin FMI/ORIP pero con área registral > 0
    (
        (p.codigo_orip IS NULL OR p.codigo_orip = '' OR
         p.matricula_inmobiliaria IS NULL OR p.matricula_inmobiliaria = '')
        AND COALESCE(p.area_registral_m2, 0) > 0
    )
    OR
    -- Caso 2: Con área registral > 0 pero sin FMI/ORIP
    (
        COALESCE(p.area_registral_m2, 0) > 0
        AND (p.codigo_orip IS NULL OR p.codigo_orip = ''
             OR p.matricula_inmobiliaria IS NULL OR p.matricula_inmobiliaria = '')
    );
