--cond 1_28 (nueva) 
SELECT lp.numero_predial, 'Fail' AS cond_1_28 
FROM cca_predio lp 
LEFT JOIN cca_predio lp2 
    ON SUBSTR(lp.numero_predial, 1, 22) = SUBSTR(lp2.numero_predial, 1, 22)  
    AND SUBSTR(lp2.numero_predial, -8) = '00000000'
WHERE SUBSTR(lp.numero_predial, 22, 1) IN ('8', '9') 
    AND SUBSTR(lp.numero_predial, -8) <> '00000000'
    AND lp2.numero_predial IS NULL;