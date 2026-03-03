--cond 1_41
select 
lp.t_id 
,lp.numero_predial
,lp.numero_torres
,'Fail' cond_1_41
from cca_predio lp
--left join cca_datosphcondominio ld on ld.cca_predio =lp.t_id
where substring(lp.numero_predial,22,9)='800000000'
and (lp.numero_torres <> 0 or lp.numero_torres is null);