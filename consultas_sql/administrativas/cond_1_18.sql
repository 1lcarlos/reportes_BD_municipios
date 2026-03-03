--cond 1_18
with tb_cond_1_18 as 
(
select 
lp.numero_predial,
ld.ilicode,
cu.identificador, 
--cu.ue_cca_unidadconstruccion,
case when cu.identificador is not null --or 
           --cu.identificador is not null 
      then 'Fail' else 'OK' end as cond_1_18
from cca_predio lp 
inner join cca_destinacioneconomicatipo ld on ld.t_id =lp.destinacion_economica 
inner join cca_construccion cu on cu.predio=lp.t_id 
where ld.ilicode ='Lote_Urbanizado_No_Construido'
)
select distinct * from tb_cond_1_18 
where cond_1_18 ='Fail';