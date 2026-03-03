--cond 1_8
with tb_cond_1_8 as 
(
select 
lp.numero_predial, 
case when substring (lp.numero_predial,22,1) not in ('1','5','6') 
	 then 'OK' else 'Fail' end as cond_1_8
from cca_predio lp 
)
select * from tb_cond_1_8 
where cond_1_8 ='Fail';