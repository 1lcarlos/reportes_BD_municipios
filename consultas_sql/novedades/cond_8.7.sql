--cond 8.7
--Cuando sea por división material: 
--(1) De los registros asociados al predio, solamente uno debe tener el mismo valor de numero predial anterior y resultante y la novedad asociada debe ser cancelación.
--(2) Los registros restantes deben estar asociado a predio nuevo.

with division_material as (
select enp.numero_predial as numero_predial_estructura
,cetn.dispname as novedad_tipo
,count(p.numero_predial) as cantidad 
from cca_predio p
left join cca_estructuranovedadnumeropredial enp
on p.t_id = enp.cca_predio_novedad_numeros_prediales 
join cca_estructuranovedadnumeropredial_tipo_novedad cetn 
on enp.tipo_novedad = cetn.t_id
where cetn.dispname in ('Cancelacion', 'Desenglobe')
group by cetn.dispname, enp.numero_predial
order by enp.numero_predial )
select * from division_material as dm
where (dm.novedad_tipo = 'Cancelacion' and dm.cantidad > 1)
order by dm.numero_predial_estructura