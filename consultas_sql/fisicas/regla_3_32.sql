select ca.T_Id Id_construccion, cu.T_Id Id_unidad ,ct.ilicode tipo_construccion_c, cc.tipo_construccion tipo_construccion_carac,
'Fail' cond_3_32
from cca_unidadconstruccion cu
LEFT JOIN cca_caracteristicasunidadconstruccion cc ON cc.T_Id = cu.caracteristicasunidadconstruccion
inner join cca_construccion ca on ca.t_id =cu.construccion 
left join cca_construcciontipo ct on ct.t_id=ca.tipo_construccion 
where ct.T_Id<>cc.tipo_construccion 