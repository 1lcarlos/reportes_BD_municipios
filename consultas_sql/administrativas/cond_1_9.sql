--cond 1_9 SE UNIFICAN CONDICIONES 1.9 Y  1.10 DEPARTAMENTO Y MUNICIPIO CODIGO 25436
with tb_cond_1_9 as
(
select 
lp.numero_predial,
case when substring (lp.numero_predial,1,5)=lp.departamento_municipio then 'OK' else 'Fail' end as cond_1_9
from cca_predio lp 
)
select * from tb_cond_1_9
where cond_1_9='Fail';