-- =========================================================
-- REGLA 51: Relación de informalidad correcta
-- =========================================================
-- Descripción:
-- En la tabla cca_predio_informalidad únicamente se deben relacionar
-- predios formales en el campo cca_predio_formal y predios informales
-- en el campo cca_predio_informal
-- =========================================================

-- Consulta que identifica relaciones incorrectas en informalidad
SELECT
    pi.t_id,
    pf.t_id AS predio_formal_id,
    pf.numero_predial AS numero_predial_formal,
    cpt_formal.ilicode AS condicion_formal,
    pinf.t_id AS predio_informal_id,
    pinf.numero_predial AS numero_predial_informal,
    cpt_informal.ilicode AS condicion_informal,
    CASE
        WHEN cpt_formal.ilicode = 'Informal'
            THEN 'Error: El campo cca_predio_formal contiene un predio informal'
        WHEN cpt_informal.ilicode != 'Informal'
            THEN 'Error: El campo cca_predio_informal contiene un predio no informal'
    END AS mensaje_error
FROM cca_predio_informalidad pi
INNER JOIN cca_predio pf ON pf.t_id = pi.cca_predio_formal
LEFT JOIN cca_condicionprediotipo cpt_formal ON pf.condicion_predio = cpt_formal.t_id
INNER JOIN cca_predio pinf ON pinf.t_id = pi.cca_predio_informal
LEFT JOIN cca_condicionprediotipo cpt_informal ON pinf.condicion_predio = cpt_informal.t_id
WHERE cpt_formal.ilicode = 'Informal'
   OR cpt_informal.ilicode != 'Informal';
