--cond 1_1
with tb_cond_1_1 as(
select lp.numero_predial,
cca.ilicode condicion, substring(lp.numero_predial,22,1),
substring(lp.numero_predial,23,8),
case when cca.ilicode='NPH' 				and substring(lp.numero_predial,22,1)='0' and substring(lp.numero_predial,23,8) ='00000000' then 'OK'
	 when cca.ilicode='Bien_Uso_Publico' and substring(lp.numero_predial,22,1)='3' and substring(lp.numero_predial,23,8) ='00000000' then 'OK'
	 when cca.ilicode='Via'				and substring(lp.numero_predial,22,1)='4' and substring(lp.numero_predial,23,8) ='00000000' then 'OK'
	 when cca.ilicode in ('Parque_Cementerio.Matriz') 
	 									and substring(lp.numero_predial,22,1)='7' and substring(lp.numero_predial,23,8) ='00000000' then 'OK'
	 when cca.ilicode='Condominio.Matriz' 		and substring(lp.numero_predial,22,1)='8' and substring(lp.numero_predial,23,8) ='00000000' then 'OK'
	 when cca.ilicode='PH.Matriz' 		and substring(lp.numero_predial,22,1)='9' and substring(lp.numero_predial,23,8) ='00000000' then 'OK'
	 else 'Fail' end as cond_1_1
	 from cca_predio lp 
inner join cca_condicionprediotipo cca on cca.t_id =lp.condicion_predio 
where cca.ilicode in
(
'NPH'
,'Bien_Uso_Publico'
,'Via'
,'Parque_Cementerio.Matriz'
,'Condominio.Matriz'
,'PH.Matriz'
))
select t.numero_predial, t.condicion, t.cond_1_1  
from tb_cond_1_1 t 
where cond_1_1 ='Fail'
;