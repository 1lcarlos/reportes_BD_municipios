WITH tb25 as(
SELECT cc.uso,cu.T_Id,cc.T_Id
,case when cc.uso is not null then 'Ok' else 'Fail' end as cond_3_25
FROM cca_unidadconstruccion cu
LEFT JOIN cca_caracteristicasunidadconstruccion cc ON cc.T_id = cu.caracteristicasunidadconstruccion)
select * from tb25
where cond_3_25 ='Fail'
