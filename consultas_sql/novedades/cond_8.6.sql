--cond 8.6: 
--Cuando sea por división material, 
--El número predial tabla cca_Predio debe existir en el registro 1 (R1) o en la base de conservacion de insumo inicial o periódico si y solo si tiene la novedad de cancelación

select p.numero_predial, cetn.dispname as novedad_tipo
,p2.numero_predial as numero_predial_conservacion
,'Fail, El numero predial no se encuentra en la base de conservacion' as observacion
from cca_predio p 
left join cca_estructuranovedadnumeropredial enp
on p.t_id = enp.cca_predio_novedad_numeros_prediales 
join cca_estructuranovedadnumeropredial_tipo_novedad cetn 
on enp.tipo_novedad = cetn.t_id
left join public.predio p2 on p.numero_predial = p2.numero_predial  
where cetn.dispname ilike '%cance%' and p2.numero_predial is null