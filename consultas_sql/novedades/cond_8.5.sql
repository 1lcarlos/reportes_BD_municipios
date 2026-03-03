--cond 8.5 
--Cuando sea por venta parcial: 
----De los registros asociados al predio solamente uno debe ser el mismo número predial 
--de la tabla cca_EstructuraNovedadNumeroPredial y numero predial de la tabla cca_Predio con novedad de desenglobe.
select enp.numero_predial as numero_predial_novedad
,cp.numero_predial as numero_predial_predio  
,count(enp.numero_predial) as cantidad 
, 'Fail, Un numero predial de la tabla cca_Predio con novedad de desenglobe, solamente puede estar asociado a un número predial 
--de la tabla cca_EstructuraNovedadNumeroPredial '
from cca_estructuranovedadnumeropredial enp 
join cca_estructuranovedadnumeropredial_tipo_novedad cetn on enp.tipo_novedad = cetn.t_id
left join cca_predio cp on enp.cca_predio_novedad_numeros_prediales = cp.t_id  
where cetn.dispname ilike '%desenglobe%' 
group by enp.numero_predial,cp.numero_predial 
having count(enp.numero_predial) > 1
order by enp.numero_predial 