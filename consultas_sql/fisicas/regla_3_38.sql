WITH tb38 AS (
SELECT uc.area_construida, st_area(uc.geometria) AS area_geometria,
abs((uc.area_construida - st_area(uc.geometria)::numeric) / uc.area_construida) * 100 AS porcentaje_error,
CASE WHEN abs((uc.area_construida - st_area(uc.geometria)::numeric)) < 0.001 THEN 'Ok' ELSE 'Fail' END AS cond_3_38
FROM cca_unidadconstruccion uc
)
SELECT * FROM tb38
WHERE cond_3_38 = 'Fail'
