with tb28 as(
select 
distinct
p.numero_predial
,u.t_id 
,u.altura  
,case when u.altura <=0 or u.altura is null then 'Fail' else 'Ok' end as cond_3_28
from cca_predio p 
INNER JOIN cca_construccion as ca on ca.predio = p.T_Id
INNER JOIN cca_unidadconstruccion as u on u.construccion = ca.T_Id and u.construccion is not null
)
select * from tb28
where cond_3_28 ='Fail'
