--cond 1_25
WITH predios_condicionados AS (
    SELECT 
        p.T_Id AS id_predio,
        p.numero_predial,
        p.coeficiente_copropiedad,
        ct.iliCode AS condicion_predio
    FROM cca_predio p
    LEFT JOIN cca_condicionprediotipo ct ON p.condicion_predio = ct.T_Id
    WHERE ct.iliCode IN ('PH.Unidad_Predial', 'Condominio.Unidad_Predial') -- Condiciones específicas
),
coeficientes_sumados AS (
    SELECT 
        pc.numero_predial,
        pc.condicion_predio,
        SUM(pc.coeficiente_copropiedad) AS total_coeficientes
    FROM predios_condicionados pc
    GROUP BY pc.numero_predial, pc.condicion_predio
)
SELECT 
    cs.numero_predial,
    cs.condicion_predio AS iliCode,
    cs.total_coeficientes,
    CASE 
        WHEN cs.total_coeficientes = 1 THEN 'OK'
        ELSE 'Fail'
    END AS resultado_regla
FROM coeficientes_sumados cs
WHERE cs.total_coeficientes != 1 OR cs.total_coeficientes IS NULL -- Mostrar solo incumplimientos
ORDER BY cs.numero_predial;