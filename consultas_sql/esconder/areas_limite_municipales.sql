--- Consulta para obtener el área en hectáreas de los límites municipales
select st_Area(cl.geometria)/10000 as area_ha from cc_limitemunicipio cl 