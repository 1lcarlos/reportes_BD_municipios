--Criterio de tolerancia 1040-746 IGAC
SELECT 
    gp.numero_predial, 
    CASE 
        WHEN substring(gp.numero_predial, 6, 2) = '00' THEN 'Rural'
        ELSE 'Urbano'
    END AS clase_suelo,    
    gp.area AS area_catastral, 
    ST_Area(gt.geometria) AS area_geometrica,    
    -- Diferencia porcentual
    CASE 
	    WHEN gp.area IS NULL THEN NULL
	    ELSE ROUND(((ABS(ST_Area(gt.geometria) - gp.area) / ST_Area(gt.geometria)) * 100)::numeric, 2)
	END AS diferencia_porcentual,
    -- Tolerancia máxima según clase de suelo y área catastral
    CASE 
        WHEN gp.area IS NULL THEN NULL
        WHEN substring(gp.numero_predial, 6, 2) = '00' THEN -- Rural
            CASE 
                WHEN gp.area <= 2000 THEN 10
                WHEN gp.area > 2000 AND gp.area <= 10000 THEN 9
                WHEN gp.area > 10000 AND gp.area <= 100000 THEN 7
                WHEN gp.area > 100000 AND gp.area <= 500000 THEN 4
                ELSE 2
            END
        ELSE -- Urbano
            CASE 
                WHEN gp.area <= 80 THEN 7
                WHEN gp.area > 80 AND gp.area <= 250 THEN 6
                WHEN gp.area > 250 AND gp.area <= 500 THEN 4
                ELSE 3
            END
    END AS tolerancia_permitida,
    -- Validación de cumplimiento (booleano)
    CASE 
        WHEN gp.area IS NULL THEN NULL
        ELSE 
            CASE 
                WHEN (ABS(ST_Area(gt.geometria) - gp.area) / ST_Area(gt.geometria)) * 100 
                     <= 
                     CASE 
                        WHEN substring(gp.numero_predial, 6, 2) = '00' THEN 
                             CASE 
				                WHEN gp.area <= 2000 THEN 10
				                WHEN gp.area > 2000 AND gp.area <= 10000 THEN 9
				                WHEN gp.area > 10000 AND gp.area <= 100000 THEN 7
				                WHEN gp.area > 100000 AND gp.area <= 500000 THEN 4
				                ELSE 2
				            END
                        ELSE 
                           CASE 
                                WHEN gp.area <= 80 THEN 7
                                WHEN gp.area > 80 AND gp.area <= 250 THEN 6
                                WHEN gp.area > 250 AND gp.area <= 500 THEN 4
                                ELSE 3
                            END
                    END
                THEN TRUE
                ELSE FALSE
            END
    END AS cumple_tolerancia,
    -- Indicador si se debe tomar el área geométrica
    CASE 
        WHEN gp.area IS NULL THEN 'Area catastral es NULL - usar área geométrica'
        WHEN (ABS(ST_Area(gt.geometria) - gp.area) / ST_Area(gt.geometria)) * 100 >
             CASE 
                WHEN substring(gp.numero_predial, 6, 2) = '00' THEN 
                    CASE 
		                WHEN gp.area <= 2000 THEN 10
		                WHEN gp.area > 2000 AND gp.area <= 10000 THEN 9
		                WHEN gp.area > 10000 AND gp.area <= 100000 THEN 7
		                WHEN gp.area > 100000 AND gp.area <= 500000 THEN 4
		                ELSE 2
		            END
                ELSE 
                  CASE 
                        WHEN gp.area <= 80 THEN 7
                        WHEN gp.area > 80 AND gp.area <= 250 THEN 6
                        WHEN gp.area > 250 AND gp.area <= 500 THEN 4
                        ELSE 3
                    END  
            END
        THEN 'Usar área geométrica'
        ELSE 'Mantener área catastral'
    END AS accion_sugerida
FROM gc_predio gp 
JOIN col_uebaunit cu ON gp.id = cu.unidad 
JOIN gc_terreno gt ON cu.ue_gc_terreno = gt.id;