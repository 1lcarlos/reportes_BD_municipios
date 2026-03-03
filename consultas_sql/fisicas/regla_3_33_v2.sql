with query1 as (
    select 
        p.numero_predial as numero_predial, 
        cpt.dispname as condicion, 
        count(cu.t_id) as cantidad_unidades,
        sum(cu.area_construida) as sum_area_construida_uni, 
        cc.t_id as id_construccion,  
        cc.area_construccion_alfanumerica as area_construccion
    from cca_unidadconstruccion cu 
    left join cca_construccion cc on cu.construccion = cc.t_id 
    left join cca_predio p on cc.predio = p.t_id
    left join cca_condicionprediotipo cpt on p.condicion_predio = cpt.t_id 
    group by 1,2,5,6
)
select 
    numero_predial,
    condicion,
    id_construccion, 
    area_construccion, 
    cantidad_unidades, 
    sum_area_construida_uni,
    case 
        when sum_area_construida_uni <> area_construccion 
             and condicion not in ('Condominio.Unidad Predial', 'PH.Unidad Predial')
        then 'fail'
        else ''
    end as resultado
from query1
where sum_area_construida_uni <> area_construccion 
  and condicion not in ('Condominio.Unidad Predial', 'PH.Unidad Predial')