with tb37 as(
SELECT ca.T_Id,max(cu.planta_ubicacion) plantas, ca.numero_pisos plantas_cons
FROM cca_unidadconstruccion cu
INNER JOIN cca_construccion ca ON ca.T_Id=cu.construccion
GROUP BY ca.T_id),
tb_cond_3_37 as(
select *
,case when plantas = plantas_cons then 'OK' else 'Fail' end as cond_3_37 from tb37)
select * from tb_cond_3_37
where cond_3_37 ='Fail'