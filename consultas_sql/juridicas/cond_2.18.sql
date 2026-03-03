--cond 2.18
WITH base AS (
    SELECT 
        lp.numero_predial,
        lp.fecha_visita_predial,
        b.ilicode AS tiene_fmi,
        lp.matricula_inmobiliaria,
        ld2.ilicode AS derecho_tipo,
        cf2.fecha_documento_fuente,
        cf.ilicode AS fuente_adm_tipo,
        cf2.numero_fuente,
        cf2.ente_emisor,
        CASE 
            WHEN cf2.fecha_documento_fuente IS NULL THEN 'Fail'
            WHEN cf.ilicode IS NULL OR TRIM(cf.ilicode) = '' THEN 'Fail'
            WHEN cf2.numero_fuente IS NULL OR TRIM(cf2.numero_fuente) = '' THEN 'Fail'
            WHEN cf2.ente_emisor IS NULL OR TRIM(cf2.ente_emisor) = '' THEN 'Fail'
            WHEN cf2.fecha_documento_fuente <= lp.fecha_visita_predial THEN 'Ok' 
            ELSE 'Fail' 
        END AS cond_2_18
    FROM cca_predio lp
    LEFT JOIN cca_derecho ld ON ld.predio = lp.t_id 
    LEFT JOIN cca_derechotipo ld2 ON ld2.t_id = ld.tipo 
    LEFT JOIN cca_adjunto ad ON ad.cca_predio_adjunto = lp.t_id 
    LEFT JOIN cca_fuenteadministrativa lf ON lf.t_id = ad.cca_fuenteadminstrtiva_adjunto
    left join cca_fuenteadministrativa_derecho cfd on ld.T_Id =cfd.derecho
    left join cca_fuenteadministrativa cf2 on cfd.fuente_administrativa = cf2.T_Id
	LEFT JOIN cca_fuenteadministrativatipo cf ON cf.t_id = cf2.tipo
    JOIN cca_booleanotipo b ON lp.tiene_fmi = b.t_id
    WHERE b.ilicode = 'Si'
)
SELECT DISTINCT * FROM base
WHERE cond_2_18 = 'Fail';