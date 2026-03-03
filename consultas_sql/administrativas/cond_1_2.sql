with tb_cond_1_2 as(
    select ennp.numero_predial, 'Fail' as cond_1_2 from cca_estructuranovedadnumeropredial ennp
    where length(ennp.numero_predial) <>30
    UNION
    SELECT  lp.numero_predial, 'Fail' as cond_1_2 FROM cca_predio lp 
    WHERE length(lp.numero_predial)<>30
)
SELECT t.numero_predial, t.cond_1_2  
FROM tb_cond_1_2 t 
WHERE cond_1_2 ='Fail';
