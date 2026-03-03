select  lp.numero_predial,lc.total_habitaciones,lc.total_banios,  lc.total_locales, 'Fail'  cond_3_23
FROM cca_caracteristicasunidadconstruccion lc 
left join cca_unidadconstruccion lu2 on lc.t_id = lu2.caracteristicasunidadconstruccion 
left join cca_construccion lc2 on lu2.construccion = lc2.t_id 
left join cca_predio lp on lp.t_id = lc2.predio 
where lc.total_habitaciones is null or lc.total_banios is null or lc.total_locales is null;