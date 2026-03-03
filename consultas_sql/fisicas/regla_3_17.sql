with tb17 as(
select 
p.numero_predial
,cu.planta_ubicacion 
,case when cu.planta_ubicacion <=0 or cu.planta_ubicacion is null then 'Fail' else 'Ok' end as cond_3_17
from cca_predio p
inner join cca_construccion as ca on ca.predio = p.T_Id
LEFT join cca_unidadconstruccion as cu on cu.construccion = ca.T_Id and cu.construccion is not null
)
select * from tb17
where cond_3_17 ='Fail'