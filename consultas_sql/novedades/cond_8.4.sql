SELECT 
    numero_predial,
    'Fail: posición 18 tiene 9 o letra (A-Z/a-z)' AS observacion
FROM cca_estructuranovedadnumeropredial
WHERE SUBSTRING(numero_predial FROM 18 FOR 1) = '9'
   OR SUBSTRING(numero_predial FROM 18 FOR 1) ~ '^[A-Za-z]$'
ORDER BY numero_predial;