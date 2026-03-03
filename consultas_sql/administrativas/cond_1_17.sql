--cond 1_17
SELECT
cr.T_Id,
p.numero_predial,
cr.identificador,
us.ilicode,
cr.tipo_anexo,
cr.calificacion_convencional 
FROM cca_caracteristicasunidadconstruccion cr
LEFT JOIN cca_usouconstipo us on us.T_id = cr.uso
LEFT JOIN cca_unidadconstruccion uc on uc.caracteristicasunidadconstruccion = cr.T_Id
left join cca_construccion co on co.T_id = uc.construccion
LEFT JOIN cca_predio p on p.T_id = co.predio
WHERE tipo_anexo IS NOT NULL
  AND calificacion_convencional IS NOT NULL;