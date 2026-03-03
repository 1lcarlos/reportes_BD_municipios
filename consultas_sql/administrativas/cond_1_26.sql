--cond 1_26 Y 1_27 (nueva) 
SELECT lp.numero_predial, 'Fail' AS cond_1_26_27 
FROM cca_predio lp 
LEFT JOIN cca_predio lp2 
    ON SUBSTR(lp.numero_predial, 1, 22) = SUBSTR(lp2.numero_predial, 1, 22) 
    AND lp.numero_predial <> lp2.numero_predial 
WHERE SUBSTR(lp.numero_predial, 22, 9) IN ('800000000', '900000000')
GROUP BY lp.numero_predial
HAVING COUNT(*) < 2;