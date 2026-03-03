--Predios con numero predial o nupre repetido

select 
'Numero predial repetido' as validacion
,p.numero_predial, count(*) as repetidos  
from cca_predio p
group by p.numero_predial 
having count(*) > 1
UNION ALL
select
'Nupre repetido'
,p.nupre, count(*) as repetidos  
from cca_predio p
group by p.nupre 
having count(*) > 1
order by repetidos desc