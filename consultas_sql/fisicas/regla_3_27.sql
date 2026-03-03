with tb27 as(select 
p.numero_predial,
c.T_id Id_condicion_predio
,c.ilicode condicion_predio,
cu.T_id,
cru.T_Id,
case when  cru.area_privada_construida IS null and cru.area_construida >0 and cru.area_construida is not null then 'OK'
	else 'Fail' end as cond_3_27
from cca_predio p 
left join cca_condicionprediotipo c on c.T_Id = p.condicion_predio 
INNER JOIN cca_construccion as ca on ca.predio = p.T_Id
left join cca_unidadconstruccion as cu on cu.construccion = ca.T_Id and cu.construccion is not null
left join cca_caracteristicasunidadconstruccion cru on cru.T_Id = cu.caracteristicasunidadconstruccion
where c.T_id NOT IN ('3','5'))
select * from tb27 where cond_3_27 ='Fail'