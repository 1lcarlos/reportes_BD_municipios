--cond 8.3
--El número predial de la tabla LC_EstructuraNovedadNumeroPredial y el numero predial de la tabla LC_Predio no debe ser un predio informal
SELECT     
    enp.numero_predial AS numero_predial_novedad,
    cetn.dispname as novedad_tipo
    ,cp.numero_predial AS numero_predial_predio,
    dt.dispname AS derecho_tipo,
    'Fail: predio identificado como informal' AS observacion
FROM cca_estructuranovedadnumeropredial enp
left JOIN cca_predio cp ON cp.t_id = enp.cca_predio_novedad_numeros_prediales
left JOIN cca_derecho d ON d.predio = cp.t_id
JOIN cca_derechotipo dt ON dt.t_id = d.tipo
left join cca_estructuranovedadnumeropredial_tipo_novedad cetn on enp.tipo_novedad = cetn.t_id 
WHERE (dt.dispname IN ('Posesión','Ocupación') 
OR substring(enp.numero_predial, 22,  1) IN ('2')) and cetn.dispname not ilike '%nuevo%';