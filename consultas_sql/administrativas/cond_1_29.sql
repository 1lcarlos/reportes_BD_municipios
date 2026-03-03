--cond 1_29
with tb_cond_1_29
as 
(
select 
lp.numero_predial
,lp.area_total_terreno 
,lp.area_total_terreno_privada 
,lp.area_total_terreno_comun
,lt.area_terreno
,case when lt.area_terreno <> lp.area_total_terreno 
        or lt.area_terreno <> lp.area_total_terreno_privada 
        or lt.area_terreno <> lp.area_total_terreno_comun 
      then 'Fail' 
      when lp.area_total_terreno is null or lp.area_total_terreno_privada is null or lp.area_total_terreno_comun is null then 'Fail'
      else 'OK' end as cond_1_29
from cca_predio lp
--left join cca_datosphcondominio ld on ld.cca_predio =lp.t_id 
--left join col_uebaunit cu on cu.baunit =lp.t_id and cu.ue_cca_terreno is not null
--left join cca_terreno lt on lt.t_id =cu.ue_cca_terreno 
left join cca_terreno lt on lt.predio = lp.t_id 
where substring(lp.numero_predial,22,9)='900000000' 
)
select * from tb_cond_1_29
where cond_1_29 ='Fail'
order by numero_predial
;