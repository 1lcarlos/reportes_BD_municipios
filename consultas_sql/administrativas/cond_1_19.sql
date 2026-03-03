--cond 1_19
with tb_cond_1_19 as 
(
select 
lp.numero_predial
,ld.ilicode  
,case when cu.identificador is not null --or 
	       --cu.ue_cca_unidadconstruccion is not null 
	  then 'OK' else 'Fail' end as cond_1_19
from cca_predio lp 
inner join cca_destinacioneconomicatipo ld on ld.t_id =lp.destinacion_economica 
inner join cca_construccion cu on cu.predio=lp.t_id and cu.identificador  is null --and cu.servidumbre_transito  is null
where ld.ilicode in ('Comercial'
,'Educativo'
,'Habitacional'
,'Industrial'
,'Institucional'
,'Salubridad'
))
select * from tb_cond_1_19 
where cond_1_19 ='Fail';