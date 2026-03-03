SELECT t.T_Id terreno_id, count(p.T_Id) conteo,'Fail' as cond_3_5 FROM cca_terreno t
LEFT JOIN cca_predio p on p.t_id = t.predio 
group by t.T_Id
having count(p.t_id)>1
union all 
SELECT c.T_Id cons_id, count(p.T_Id) conteo,'Fail' as cond_3_5  FROM cca_construccion c
LEFT JOIN cca_predio p on p.t_id = c.predio 
group by c.T_Id
having count(p.t_id)>1
union all 
SELECT uc.T_Id unidad_id, count(p.T_Id) conteo,'Fail' as cond_3_5  FROM cca_unidadconstruccion uc
LEFT JOIN cca_construccion c on c.t_id = uc.construccion
LEFT JOIN cca_predio p ON p.T_Id = c.predio
group by uc.T_Id
having count(p.t_id)>1
