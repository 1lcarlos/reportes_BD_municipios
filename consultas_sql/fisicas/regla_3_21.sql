/* Cambié substr e instr por substring y position.
Ajusté comillas en el filtro de d.t_id.
Mejoré la condición de existencia de 'Comercial' usando not exists. */

with base as (
    select  
        distinct
        p.numero_predial,
        d.ilicode as destinacion_economica,
        substring(ut.ilicode from 1 for position('.' in ut.ilicode) - 1) as uso,
        cru.area_construida as area_construida
    from cca_predio p  
    left join cca_destinacioneconomicatipo d on d.t_id = p.destinacion_economica 
    left join cca_construccion ca on ca.predio = p.t_id
    left join cca_unidadconstruccion cu on cu.construccion = ca.t_id and cu.construccion is not null 
    left join cca_caracteristicasunidadconstruccion cru on cru.t_id = cu.caracteristicasunidadconstruccion 
    left join cca_usouconstipo ut on ut.t_id = cru.uso 
    where d.ilicode ='Comercial'
),
tb1 as (
    select 
        numero_predial,
        destinacion_economica,
        uso,
        sum(coalesce(area_construida, 0)) as area_construida_total_uso
    from base
    group by 1,2,3
),
tb_final as (
    select 
        numero_predial, 
        uso,
        area_construida_total_uso,
        case 
            when (select area_construida_total_uso from tb1 tt where tt.numero_predial = t.numero_predial and tt.uso = 'Comercial') < t.area_construida_total_uso and uso <> 'Comercial' then 'Fail'
            when not exists (select 1 from tb1 tt1 where tt1.numero_predial = t.numero_predial and tt1.uso = 'Comercial') then 'Fail'
            else 'Ok' 
        end as cond_3_21_1
    from tb1 t
    order by numero_predial
)
select 
    numero_predial,
    'Comercial' as dest_eco,
    uso,
    area_construida_total_uso,
    'Fail' as cond_3_21
from tb_final 
where numero_predial in (select numero_predial from tb_final where cond_3_21_1 = 'Fail')
order by numero_predial