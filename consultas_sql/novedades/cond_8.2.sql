--cond 8.2
--El número predial tabla LC_EstructuraNovedadNumeroPredial debe existir en el registro 1 (R1) de insumo inicial o periódico
--comparacion hecha con la base de conservacion

select enp.numero_predial as novedad_numero_predial, cetn.dispname as tipo_novedad
,p.numero_predial as r1_numero_predial
, 'Fail-No se encuentran en la base de conservacion' as validacion
from cca_estructuranovedadnumeropredial enp
left join public.predio p on enp.numero_predial = p.numero_predial
join cca_estructuranovedadnumeropredial_tipo_novedad cetn on enp.tipo_novedad = cetn.t_id 
where p.numero_predial is null and cetn.dispname not ilike '%nuevo%'