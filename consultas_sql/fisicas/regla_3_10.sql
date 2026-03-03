WITH tb10 as(
SELECT uc.T_id,cc.T_id,ct.iliCode,uc.T_Id,uct.ilicode,
case when uct.T_Id is null then 'Fail' when uct.T_Id in ('1','2','3','4') 
AND ct.T_Id ='1' then 'Ok' else 'Fail' end as cond_3_10
FROM cca_unidadconstruccion uc
LEFT JOIN cca_caracteristicasunidadconstruccion cc ON  cc.T_id = uc.caracteristicasunidadconstruccion
INNER JOIN cca_construccion as c on uc.construccion = c.T_Id and uc.construccion is not NULL
LEFT JOIN cca_construcciontipo AS ct ON c.tipo_construccion = ct.T_Id 
LEFT JOIN cca_unidadconstrucciontipo uct ON uct.T_Id = cc.tipo_unidad_construccion 
where ct.T_id ='1')
select * from tb10
where cond_3_10 ='Fail'
