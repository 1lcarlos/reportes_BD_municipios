--cond 1_42
with tb_cond_1_42_1 as(
select 
lp.t_id 
,lp.numero_predial
,lp.total_unidades_privadas
from cca_predio lp
--left join cca_datosphcondominio ld on ld.cca_predio =lp.t_id
where substring(lp.numero_predial,22,9)='800000000'
)
,predios_asociados as (
select 
lp.numero_predial predio_matriz, 
tt.total_unidades_privadas,
count(lpc.t_id) conteo
from cca_predio lp
inner join tb_cond_1_42_1 tt on tt.t_id=lp.t_id
left join cca_predio_copropiedad lpc on lpc.matriz =lp.t_id 
group by lp.numero_predial ,tt.total_unidades_privadas
)
select *,'Fail' cond_1_42 from predios_asociados pa
where coalesce(pa.total_unidades_privadas,0)=conteo or conteo=0;