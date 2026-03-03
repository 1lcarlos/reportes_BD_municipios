WITH tb24 as(
SELECT cc.total_plantas,cu.T_Id,cc.T_Id
,case when cc.total_plantas is not null and cc.total_plantas >0  then 'Ok' else 'Fail' end as cond_3_24
FROM cca_unidadconstruccion cu
LEFT JOIN cca_caracteristicasunidadconstruccion cc ON cc.T_id = cu.caracteristicasunidadconstruccion)
select * from tb24
where cond_3_24 ='Fail'