WITH tb8 AS (
SELECT p.numero_predial, t.area_terreno, st_area(t.geometria) AS area_geometria,
abs((t.area_terreno - st_area(t.geometria)::numeric) / t.area_terreno) * 100 AS porcentaje_error,
CASE WHEN abs((t.area_terreno - st_area(t.geometria)::numeric) / t.area_terreno) * 100 > 1 THEN 'Fail' ELSE 'Ok' END AS cond_3_8
FROM cca_predio p
INNER JOIN cca_terreno t ON p.T_id = t.predio
)
SELECT * FROM tb8
WHERE cond_3_8 = 'Fail'
