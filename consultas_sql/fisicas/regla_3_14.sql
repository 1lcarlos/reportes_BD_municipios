WITH tb14 as(
SELECT uc.T_id, ut.iliCode,uct.iliCode Tipo_Unidad_Construccion,ut.iliCode Tipo_Uso_Unidad,
case when ut.T_id is null then 'Fail' 
	 when ut.ilicode like 'Industrial%' AND uct.ilicode LIKE 'Industrial%'
	 then 'Ok' else 'Fail' end as cond_3_14
FROM cca_unidadconstruccion uc
LEFT JOIN cca_caracteristicasunidadconstruccion cc ON  cc.T_id = uc.caracteristicasunidadconstruccion
LEFT JOIN cca_unidadconstrucciontipo uct ON uct.T_Id = cc.tipo_unidad_construccion 
INNER JOIN cca_construccion as c on uc.construccion = c.T_Id and uc.construccion is not NULL
LEFT JOIN cca_usouconstipo ut ON ut.T_Id = cc.uso 
LEFT JOIN cca_construcciontipo AS ct ON c.tipo_construccion = ct.T_Id 
WHERE uct.iliCode NOT LIKE 'Residencial%' 
  AND uct.iliCode NOT LIKE 'Institucional%' 
  AND uct.iliCode NOT LIKE 'Anexo%' 
  AND uct.iliCode NOT LIKE 'Comercial%'
)
select * from tb14
where cond_3_14 ='Fail'
