---Fuentes administrativas almacenadas mas de una vez.
select distinct fa.id as id_fuenteAdministrativa,  fa.ente_emisor, fa.fecha_documento_fuente, fa.numero_fuente, fa.tipo, count(*) as cantidad
from gc_fuenteadministrativa fa 
group by fa.id, fa.ente_emisor, fa.fecha_documento_fuente, fa.numero_fuente, fa.tipo
having count(*) >1 
order by cantidad desc