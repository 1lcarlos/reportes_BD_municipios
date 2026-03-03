--cond 1_12
with tb_cond_1_12 as (
    select 
        lp.numero_predial,
        --lp.tiene_fmi,
        cb.ilicode as Tiene_FMI,
        lp.codigo_orip,
        lp.matricula_inmobiliaria,
        case 
            when lp.tiene_fmi = '1' and  -- Asumiendo que 1 representa true
                 lp.codigo_orip <> '' and 
                 lp.codigo_orip is not null and 
                 lp.matricula_inmobiliaria <> '' and 
                 lp.matricula_inmobiliaria is not null 
            then 'OK' 
            when lp.tiene_fmi = '2' and  -- Asumiendo que 2 representa false
                 lp.codigo_orip is null and 
                 lp.matricula_inmobiliaria is null 
            then 'OK'
            else 'Fail' 
        end as cond_1_12
    from cca_predio lp
    left join cca_booleanotipo cb on  cb.t_id = lp.tiene_fmi   
)
select * from tb_cond_1_12 
where cond_1_12 = 'Fail';