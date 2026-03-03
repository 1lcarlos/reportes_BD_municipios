with tb36 as(
SELECT c.T_Id,c.numero_pisos, CASE WHEN c.numero_pisos <> 0 AND c.numero_pisos IS NOT NULL THEN 'Ok' ELSE 'Fail' END AS cond_3_36
FROM cca_construccion c)
select * from tb36
where cond_3_36 ='Fail'
