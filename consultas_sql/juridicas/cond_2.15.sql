--cond 2.15
WITH interesados_relacionados AS (
    SELECT
        i.T_Id AS id_interesado,
        CASE 
            WHEN m.interesado IS NOT NULL THEN 'Relacionado con miembro'
            WHEN d.interesado IS NOT NULL THEN 'Relacionado con derecho'
            ELSE 'Fail'
        END AS estado_relacion
    FROM cca_interesado i
    LEFT JOIN cca_miembros m ON i.T_Id = m.interesado
    LEFT JOIN cca_derecho d ON i.T_Id = d.interesado
)
SELECT *
FROM interesados_relacionados
WHERE estado_relacion = 'Fail';