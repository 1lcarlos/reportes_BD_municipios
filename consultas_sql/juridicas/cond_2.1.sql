--cond 2.1
with base as
(
select 
cp.numero_predial,
cp.tiene_fmi,
cp.matricula_inmobiliaria,
case 
when length(cp.matricula_inmobiliaria) between 1 and 7 
and cp.matricula_inmobiliaria ~ '^[0-9]+$' 
then 'Ok' else 'Fail' 
end as cond_2_1
from cca_predio cp 
where cp.tiene_fmi = 1 ---no es de tipo boolean, sino bigint (entero) -- se cambia el TRUE POR 1
)
select * from base
where cond_2_1 ='Fail';