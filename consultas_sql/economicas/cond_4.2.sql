--cond 4.2
with base as(
select 
distinct
cp.numero_predial,
cc2.T_id id_caracteristica_unidad,
ct2.ilicode AS tipo_cons_caracteristica,
cc2.identificador,
ut.iliCode tipo_unidad,
tt.iliCode tipo_tipologia,
---case when ca.T_id is null then 'Fail' else 'Ok' end as cond_4_2
case when cc2.tipo_anexo is null then 'Fail' else 'Ok' end as cond_4_2
from cca_predio cp
left join cca_construccion cc on cp.T_Id=cc.predio 
left join cca_construcciontipo ct on ct.T_id=cc.tipo_construccion
left join cca_unidadconstruccion cu on cc.T_Id=cu.construccion 
left join cca_caracteristicasunidadconstruccion cc2 on cc2.T_id=cu.caracteristicasunidadconstruccion
left join cca_unidadconstrucciontipo ut on ut.T_id= cc2.tipo_unidad_construccion 
LEFT JOIN cca_construcciontipo ct2 on ct2.T_id=cc2.tipo_construccion
left join cca_tipologiatipo tt on tt.T_id= cc2.tipo_tipologia
left join cca_anexotipo ca on ca.T_id= cc2.tipo_anexo
where ct2.ilicode  = 'No_Convencional'
order by cp.numero_predial
)
select * from base
where cond_4_2='Fail';