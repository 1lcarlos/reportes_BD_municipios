/* Se simplifica el CASE y se asegura que la columna cond_3_6 tenga 'Fail' solo cuando el área es menor a 5, y 'Ok' en caso contrario:
 */
WITH tb6 AS (
    SELECT 
        p.numero_predial, 
        ROUND(ST_Area(t.geometria)::numeric, 2) AS areaVal,
        CASE 
            WHEN ROUND(ST_Area(t.geometria)::numeric, 2) < 5 THEN 'Fail'
            ELSE 'Ok'
        END AS cond_3_6
    FROM cca_predio p
    INNER JOIN cca_terreno t ON p.t_id = t.predio
)
SELECT * FROM tb6 WHERE cond_3_6 = 'Fail'