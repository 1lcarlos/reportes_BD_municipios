--cond 2.16
with base as(
select 
lp.numero_predial
,lp.matricula_inmobiliaria
,b.ilicode AS tiene_fmi
,ld2.ilicode derecho_tipo
,ld.fecha_inicio_tenencia 
,cf.fecha_documento_fuente
,b.ilicode AS tiene_fmi
,case when ld.fecha_inicio_tenencia is null then 'Fail'
	when ld.fecha_inicio_tenencia is not null and ld.fecha_inicio_tenencia < cf.fecha_documento_fuente then 'Fail'
	when ld.fecha_inicio_tenencia is not null and ld.fecha_inicio_tenencia >= cf.fecha_documento_fuente then 'Ok'
	else 'Fail' end as cond_2_16
from cca_predio lp 
left join cca_derecho ld on ld.predio =lp.t_id 
left join cca_derechotipo ld2 on ld2.t_id =ld.tipo 
left join cca_adjunto ad on ad.cca_predio_adjunto = lp.t_id 
left join cca_fuenteadministrativa lf on lf.t_id =ad.cca_fuenteadminstrtiva_adjunto
left join cca_fuenteadministrativa_derecho cfd on ld.T_Id =cfd.derecho
left join cca_fuenteadministrativa cf on cfd.fuente_administrativa = cf.T_Id 
JOIN cca_booleanotipo b ON lp.tiene_fmi = b.t_id
where lp.matricula_inmobiliaria is not null and lp.matricula_inmobiliaria <>'0'
and ld2.ilicode ='Dominio'
)
select * from base
where cond_2_16 ='Fail';