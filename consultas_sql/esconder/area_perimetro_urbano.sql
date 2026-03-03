-----Consulta para obtener el área en hectáreas del perímetro urbano
select st_Area(cp.geometria )/10000 as area_ha  from cc_perimetrourbano cp 