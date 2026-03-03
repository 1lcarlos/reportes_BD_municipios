with tb1 as(select 
p.numero_predial
,c.ilicode condicion_predio
,case when c.T_Id is null then 'Fail' else 'Ok' end as cond_3_1
from cca_predio p 
left join cca_condicionprediotipo c on c.T_Id = p.condicion_predio 
left join cca_construccion as ca on ca.predio = p.T_Id
left join cca_unidadconstruccion as cu on cu.construccion = ca.T_Id and cu.construccion is not null
where c.itfCode = 2 )
select * from tb1 where cond_3_1 ='Fail'

