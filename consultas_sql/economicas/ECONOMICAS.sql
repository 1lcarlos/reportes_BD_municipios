BEGIN;

--cond 4.1
WITH base AS (
    SELECT DISTINCT
        cp.numero_predial,
        cc2.T_id AS id_caracteristica_unidad,
        ct2.ilicode AS tipo_construccion_caracteristica,
        cc2.identificador,
        ut.iliCode AS tipo_unidad,
        tt.iliCode AS tipo_tipologia,
        cc3.total_calificacion,
        CASE
            WHEN tt.T_Id IS NOT NULL OR cc3.total_calificacion IS NOT NULL THEN 'Ok'
            ELSE 'Fail'
        END AS cond_4_1
    FROM cca_predio cp
    LEFT JOIN cca_construccion cc ON cp.T_Id = cc.predio
    LEFT JOIN cca_construcciontipo ct ON ct.T_id = cc.tipo_construccion
    LEFT JOIN cca_unidadconstruccion cu ON cc.T_Id = cu.construccion
    LEFT JOIN cca_caracteristicasunidadconstruccion cc2 ON cc2.T_id = cu.caracteristicasunidadconstruccion
    LEFT JOIN cca_unidadconstrucciontipo ut ON ut.T_id = cc2.tipo_unidad_construccion
    LEFT JOIN cca_construcciontipo ct2 ON ct2.T_id = cc2.tipo_construccion
    LEFT JOIN cca_tipologiatipo tt ON tt.T_id = cc2.tipo_tipologia
    LEFT JOIN cca_calificacionconvencional cc3 ON cc3.T_id = cc2.calificacion_convencional
    WHERE ct2.ilicode  = 'Convencional'
)
SELECT * FROM base WHERE cond_4_1 = 'Fail';

--cond 4.2
with base as(
select 
distinct
cp.numero_predial,
cc2.T_id id_caracteristica_unidad,
ct2.ilicode AS tipo_cons_caracteristica,
cc2.identificador,
ut.iliCode tipo_unidad,
tt.iliCode tipo_tipologia,
---case when ca.T_id is null then 'Fail' else 'Ok' end as cond_4_2
case when cc2.tipo_anexo is null then 'Fail' else 'Ok' end as cond_4_2
from cca_predio cp
left join cca_construccion cc on cp.T_Id=cc.predio 
left join cca_construcciontipo ct on ct.T_id=cc.tipo_construccion
left join cca_unidadconstruccion cu on cc.T_Id=cu.construccion 
left join cca_caracteristicasunidadconstruccion cc2 on cc2.T_id=cu.caracteristicasunidadconstruccion
left join cca_unidadconstrucciontipo ut on ut.T_id= cc2.tipo_unidad_construccion 
LEFT JOIN cca_construcciontipo ct2 on ct2.T_id=cc2.tipo_construccion
left join cca_tipologiatipo tt on tt.T_id= cc2.tipo_tipologia
left join cca_anexotipo ca on ca.T_id= cc2.tipo_anexo
where ct2.ilicode  = 'No_Convencional'
order by cp.numero_predial
)
select * from base
where cond_4_2='Fail';

--cond 4.3
WITH base AS (
    SELECT DISTINCT
        cp.numero_predial,
        cc2.T_id AS id_caracteristica_unidad,
        ct.iliCode AS tipo_construccion,
        ut.iliCode AS tipo_unidad,
        tt.iliCode AS tipo_tipologia,
        CASE WHEN tt.ilicode LIKE 'Residencial%' THEN 'Ok' ELSE 'Fail' END AS cond_4_3
    FROM cca_predio cp
    LEFT JOIN cca_construccion cc ON cp.T_Id = cc.predio
    LEFT JOIN cca_construcciontipo ct ON ct.T_id = cc.tipo_construccion
    LEFT JOIN cca_unidadconstruccion cu ON cc.T_Id = cu.construccion
    LEFT JOIN cca_caracteristicasunidadconstruccion cc2 ON cc2.T_id = cu.caracteristicasunidadconstruccion
    LEFT JOIN cca_unidadconstrucciontipo ut ON ut.T_id = cc2.tipo_unidad_construccion
    LEFT JOIN cca_tipologiatipo tt ON tt.T_id = cc2.tipo_tipologia
    WHERE ct.iliCode = 'Convencional' AND ut.iliCode = 'Residencial'
)
SELECT * FROM base WHERE cond_4_3 = 'Fail';

--cond 4.4
WITH base AS (
    SELECT DISTINCT
        cp.numero_predial,
        cc2.T_id AS id_caracteristica_unidad,
        ct.iliCode AS tipo_construccion,
        ut.iliCode AS tipo_unidad,
        tt.iliCode AS tipo_tipologia,
        CASE WHEN tt.ilicode LIKE 'Comercial%' THEN 'Ok' ELSE 'Fail' END AS cond_4_4
    FROM cca_predio cp
    LEFT JOIN cca_construccion cc ON cp.T_Id = cc.predio
    LEFT JOIN cca_construcciontipo ct ON ct.T_id = cc.tipo_construccion
    LEFT JOIN cca_unidadconstruccion cu ON cc.T_Id = cu.construccion
    LEFT JOIN cca_caracteristicasunidadconstruccion cc2 ON cc2.T_id = cu.caracteristicasunidadconstruccion
    LEFT JOIN cca_unidadconstrucciontipo ut ON ut.T_id = cc2.tipo_unidad_construccion
    LEFT JOIN cca_tipologiatipo tt ON tt.T_id = cc2.tipo_tipologia
    WHERE ct.iliCode = 'Convencional' AND ut.iliCode = 'Comercial'
)
SELECT * FROM base WHERE cond_4_4 = 'Fail';

--cond 4.5
WITH base AS (
    SELECT DISTINCT
        cp.numero_predial,
        cc2.T_id AS id_caracteristica_unidad,
        ct.iliCode AS tipo_construccion,
        ut.iliCode AS tipo_unidad,
        tt.iliCode AS tipo_tipologia,
        CASE WHEN tt.ilicode LIKE 'Industrial%' THEN 'Ok' ELSE 'Fail' END AS cond_4_5
    FROM cca_predio cp
    LEFT JOIN cca_construccion cc ON cp.T_Id = cc.predio
    LEFT JOIN cca_construcciontipo ct ON ct.T_id = cc.tipo_construccion
    LEFT JOIN cca_unidadconstruccion cu ON cc.T_Id = cu.construccion
    LEFT JOIN cca_caracteristicasunidadconstruccion cc2 ON cc2.T_id = cu.caracteristicasunidadconstruccion
    LEFT JOIN cca_unidadconstrucciontipo ut ON ut.T_id = cc2.tipo_unidad_construccion
    LEFT JOIN cca_tipologiatipo tt ON tt.T_id = cc2.tipo_tipologia
    WHERE ct.iliCode = 'Convencional' AND ut.iliCode = 'Industrial'
)
SELECT * FROM base WHERE cond_4_5 = 'Fail';

--cond 4.6
WITH base AS (
    SELECT DISTINCT
        cp.numero_predial,
        cc2.T_id AS id_caracteristica_unidad,
        ct.iliCode AS tipo_construccion,
        ut.iliCode AS tipo_unidad,
        tt.iliCode AS tipo_tipologia,
        CASE WHEN tt.ilicode = 'Otro' THEN 'Ok' ELSE 'Fail' END AS cond_4_6
    FROM cca_predio cp
    LEFT JOIN cca_construccion cc ON cp.T_Id = cc.predio
    LEFT JOIN cca_construcciontipo ct ON ct.T_id = cc.tipo_construccion
    LEFT JOIN cca_unidadconstruccion cu ON cc.T_Id = cu.construccion
    LEFT JOIN cca_caracteristicasunidadconstruccion cc2 ON cc2.T_id = cu.caracteristicasunidadconstruccion
    LEFT JOIN cca_unidadconstrucciontipo ut ON ut.T_id = cc2.tipo_unidad_construccion
    LEFT JOIN cca_tipologiatipo tt ON tt.T_id = cc2.tipo_tipologia
    WHERE ct.iliCode = 'Convencional' AND ut.iliCode = 'Institucional'
)
SELECT * FROM base WHERE cond_4_6 = 'Fail';

--cond 4.7
WITH base AS (
    SELECT
        cp.numero_predial,
        cc.T_id AS construccion_id,
        cu.T_id AS unidad_id,
        cc2.T_id AS caracteristica_id,
        ct.iliCode AS tipo_construccion,
        ut.iliCode AS tipo_unidad,
        ct2.iliCode AS tipo_calificar,
        cct.iliCode AS clase_calificacion,
        cct.itfCode AS clase_itfcode,
        -- Atributos obligatorios según clase (en cc3)
        cc3.armazon,
        cc3.muros,
        cc3.cubierta,
        cc3.fachada,
        cc3.cubrimiento_muros,
        cc3.piso,
        cc3.tamanio_banio,
        cc3.enchape_banio,
        cc3.mobiliario_banio,
        cc3.tamanio_cocina,
        cc3.enchape_cocina,
        cc3.mobiliario_cocina
    FROM cca_predio cp
    LEFT JOIN cca_construccion cc ON cp.T_Id = cc.predio
    LEFT JOIN cca_construcciontipo ct ON ct.T_id = cc.tipo_construccion
    LEFT JOIN cca_unidadconstruccion cu ON cc.T_Id = cu.construccion
    LEFT JOIN cca_caracteristicasunidadconstruccion cc2 ON cc2.T_id = cu.caracteristicasunidadconstruccion
    LEFT JOIN cca_calificacionconvencional cc3 ON cc3.T_id = cc2.calificacion_convencional
    LEFT JOIN cca_calificartipo ct2 ON ct2.T_id = cc3.tipo_calificar
    LEFT JOIN cca_clasecalificaciontipo cct ON cct.T_id = cc3.clase_calificacion
    LEFT JOIN cca_unidadconstrucciontipo ut ON ut.T_id = cc2.tipo_unidad_construccion
    WHERE ct.iliCode = 'Convencional'
),
conteos AS (
    SELECT
        numero_predial,
        tipo_calificar,
        clase_calificacion,
        COUNT(*) AS total_registros,
        COUNT(DISTINCT armazon) AS total_armazon,
        COUNT(DISTINCT muros) AS total_muro,
        COUNT(DISTINCT cubierta) AS total_cubierta,
        COUNT(DISTINCT fachada) AS total_fachada,
        COUNT(DISTINCT cubrimiento_muros) AS total_cubrimiento_muros,
        COUNT(DISTINCT piso) AS total_piso,
        COUNT(DISTINCT tamanio_banio) AS total_tamano_banio,
        COUNT(DISTINCT enchape_banio) AS total_enchape_banio,
        COUNT(DISTINCT mobiliario_banio) AS total_mobiliario_banio,
        COUNT(DISTINCT tamanio_cocina) AS total_tamano_cocina,
        COUNT(DISTINCT enchape_cocina) AS total_enchape_cocina,
        COUNT(DISTINCT mobiliario_cocina) AS total_mobiliario_cocina,
        COUNT(DISTINCT CASE WHEN tipo_calificar = 'Industrial' THEN 1 END) AS total_complemento_industria
    FROM base
    GROUP BY numero_predial, tipo_calificar, clase_calificacion
),
reglas AS (
    SELECT
        *,
        CASE
            -- 1. Duplicados por tipo y clase
            WHEN tipo_calificar IN ('Residencial','Comercial','Institucional')
                 AND clase_calificacion IN ('Estructura','Acabados_Principales','Banio','Cocina')
                 AND total_registros > 1
            THEN 'Fail'
            
            WHEN tipo_calificar = 'Industrial'
                 AND clase_calificacion IN ('Estructura','Acabados_Principales')
                 AND total_registros > 1
            THEN 'Fail'
            
            -- 2. Validación atributos obligatorios según clase
            WHEN clase_calificacion = 'Estructura'
                 AND (total_armazon > 1 OR total_muro > 1 OR total_cubierta > 1)
            THEN 'Fail'
            
            WHEN clase_calificacion = 'Acabados_Principales'
                 AND (total_fachada > 1 OR total_cubrimiento_muros > 1 OR total_piso > 1)
            THEN 'Fail'
            
            WHEN clase_calificacion = 'Banio'
                 AND (total_tamano_banio > 1 OR total_enchape_banio > 1 OR total_mobiliario_banio > 1)
            THEN 'Fail'
            
            WHEN clase_calificacion = 'Cocina'
                 AND (total_tamano_cocina > 1 OR total_enchape_cocina > 1 OR total_mobiliario_cocina > 1)
            THEN 'Fail'
            
            -- 3. Industrial no debe tener Banio o Cocina
            WHEN tipo_calificar = 'Industrial'
                 AND clase_calificacion IN ('Banio','Cocina')
            THEN 'Fail'
            
            -- 4. Industrial debe tener Complemento Industria
            WHEN tipo_calificar = 'Industrial'
                 AND total_complemento_industria = 0
            THEN 'Fail'
            
            ELSE 'Ok'
        END AS cond_4_7
    FROM conteos
)
SELECT *
FROM reglas
WHERE cond_4_7 = 'Fail'
ORDER BY numero_predial, tipo_calificar, clase_calificacion;

--cond 4.8
WITH base AS (
    SELECT 
        ccv.t_id,
        cc.ilicode AS tipo_calificar,
        --cl.ilicode AS clase_calificacion,

        -- Estructura
        ccv.armazon,
        ccv.muros,
        ccv.cubierta,
        ce.ilicode  AS conservacion_estructura,
        ccv.subtotal_estructura,

        -- Acabados
        ccv.fachada,
        ccv.cubrimiento_muros,
        ccv.piso,
        ce2.ilicode AS conservacion_acabados,
        ccv.subtotal_acabados,

        -- Baños
        ccv.tamanio_banio,
        ccv.enchape_banio,
        ccv.mobiliario_banio,
        ce3.ilicode AS conservacion_banio,
        ccv.subtotal_banio,

        -- Cocinas
        ccv.tamanio_cocina,
        ccv.enchape_cocina,
        ccv.mobiliario_cocina,
        ce4.ilicode AS conservacion_cocina,
        ccv.subtotal_cocina,

        -- Cerchas
        ccv.cerchas,
        ccv.subtotal_cerchas,

        -- Total general
        ccv.total_calificacion
    FROM cca_calificacionconvencional ccv
    JOIN cca_calificartipo cc ON cc.t_id = ccv.tipo_calificar
    JOIN cca_clasecalificaciontipo cl ON cl.t_id = ccv.clase_calificacion
    JOIN cca_estadoconservaciontipo ce  ON ce.t_id  = ccv.conservacion_estructura
    JOIN cca_estadoconservaciontipo ce2 ON ce2.t_id = ccv.conservacion_acabados
    JOIN cca_estadoconservaciontipo ce3 ON ce3.t_id = ccv.conservacion_banio
    JOIN cca_estadoconservaciontipo ce4 ON ce4.t_id = ccv.conservacion_cocina
)

SELECT 
    b.t_id,
    b.tipo_calificar,
    --b.clase_calificacion,

    CASE 
      WHEN b.tipo_calificar = 'Residencial' 
           AND (b.armazon IS NULL OR b.muros IS NULL OR b.cubierta IS NULL) 
      THEN 'FAIL' ELSE 'OK' 
    END AS cond_1_estructura_residencial,

    CASE 
      WHEN b.tipo_calificar = 'Residencial' 
           AND (b.fachada IS NULL OR b.cubrimiento_muros IS NULL OR b.piso IS NULL)
      THEN 'FAIL' ELSE 'OK'
    END AS cond_2_acabados_residencial,

    CASE 
      WHEN b.tipo_calificar = 'Residencial' 
           AND (b.tamanio_banio IS NULL OR b.enchape_banio IS NULL OR b.mobiliario_banio IS NULL)
      THEN 'FAIL' ELSE 'OK'
    END AS cond_3_banio_residencial,

    CASE 
      WHEN b.tipo_calificar = 'Residencial' 
           AND (b.tamanio_cocina IS NULL OR b.enchape_cocina IS NULL OR b.mobiliario_cocina IS NULL)
      THEN 'FAIL' ELSE 'OK'
    END AS cond_4_cocina_residencial,

    CASE 
      WHEN b.tipo_calificar IN ('Comercial', 'Institucional') 
           AND (b.armazon IS NULL OR b.muros IS NULL OR b.cubierta IS NULL)
      THEN 'FAIL' ELSE 'OK'
    END AS cond_5_estructura_comercial,

    CASE 
      WHEN b.tipo_calificar IN ('Comercial', 'Institucional') 
           AND (b.fachada IS NULL OR b.cubrimiento_muros IS NULL OR b.piso IS NULL)
      THEN 'FAIL' ELSE 'OK'
    END AS cond_6_acabados_comercial,

    CASE 
      WHEN b.tipo_calificar IN ('Comercial', 'Institucional') 
           AND (b.tamanio_banio IS NULL OR b.enchape_banio IS NULL OR b.mobiliario_banio IS NULL)
      THEN 'FAIL' ELSE 'OK'
    END AS cond_7_banio_comercial,

    CASE 
      WHEN b.tipo_calificar IN ('Comercial', 'Institucional') 
           AND (b.tamanio_cocina IS NULL OR b.enchape_cocina IS NULL OR b.mobiliario_cocina IS NULL)
      THEN 'FAIL' ELSE 'OK'
    END AS cond_8_cocina_comercial,

    CASE 
      WHEN b.tipo_calificar = 'Industrial' 
           AND (b.armazon IS NULL OR b.muros IS NULL OR b.cubierta IS NULL)
      THEN 'FAIL' ELSE 'OK'
    END AS cond_9_estructura_industrial,

    CASE 
      WHEN b.tipo_calificar = 'Industrial' 
           AND (b.cerchas IS NULL)
      THEN 'FAIL' ELSE 'OK'
    END AS cond_10_cerchas_industrial,
   
    CASE 
      WHEN b.conservacion_estructura = 'Malo'      AND b.subtotal_estructura <> 0 THEN 'FAIL'
      WHEN b.conservacion_estructura = 'Regular'   AND b.subtotal_estructura <> 2 THEN 'FAIL'
      WHEN b.conservacion_estructura = 'Bueno'     AND b.subtotal_estructura <> 4 THEN 'FAIL'
      WHEN b.conservacion_estructura = 'Excelente' AND b.subtotal_estructura <> 5 THEN 'FAIL'
      ELSE 'OK'
    END AS cond_12_estructura_puntaje,
   
    CASE 
      WHEN b.conservacion_acabados = 'Malo'      AND b.subtotal_acabados <> 0 THEN 'FAIL'
      WHEN b.conservacion_acabados = 'Regular'   AND b.subtotal_acabados <> 2 THEN 'FAIL'
      WHEN b.conservacion_acabados = 'Bueno'     AND b.subtotal_acabados <> 4 THEN 'FAIL'
      WHEN b.conservacion_acabados = 'Excelente' AND b.subtotal_acabados <> 5 THEN 'FAIL'
      ELSE 'OK'
    END AS cond_13_acabados_puntaje,


    CASE 
      WHEN b.conservacion_banio = 'Malo'      AND b.subtotal_banio <> 0 THEN 'FAIL'
      WHEN b.conservacion_banio = 'Regular'   AND b.subtotal_banio <> 2 THEN 'FAIL'
      WHEN b.conservacion_banio = 'Bueno'     AND b.subtotal_banio <> 4 THEN 'FAIL'
      WHEN b.conservacion_banio = 'Excelente' AND b.subtotal_banio <> 5 THEN 'FAIL'
      ELSE 'OK'
    END AS cond_14_banio_puntaje,


    CASE 
      WHEN b.conservacion_cocina = 'Malo'      AND b.subtotal_cocina <> 0 THEN 'FAIL'
      WHEN b.conservacion_cocina = 'Regular'   AND b.subtotal_cocina <> 2 THEN 'FAIL'
      WHEN b.conservacion_cocina = 'Bueno'     AND b.subtotal_cocina <> 4 THEN 'FAIL'
      WHEN b.conservacion_cocina = 'Excelente' AND b.subtotal_cocina <> 5 THEN 'FAIL'
      ELSE 'OK'
    END AS cond_15_cocina_puntaje,

    CASE 
      WHEN b.total_calificacion <> 
           COALESCE(b.subtotal_estructura,0)
         + COALESCE(b.subtotal_acabados,0)
         + COALESCE(b.subtotal_banio,0)
         + COALESCE(b.subtotal_cocina,0)
         + COALESCE(b.subtotal_cerchas,0)
      THEN 'FAIL' ELSE 'OK'
    END AS cond_total_calificacion

FROM base b;

--cond 4.9
WITH base AS (
    SELECT
        cp.numero_predial,
        cc2.T_id AS id_caracteristica_unidad,
        cc2.identificador,
        ct2.iliCode AS tipo_calificar,
        cct.iliCode AS clase_calificacion,
        cc3.conservacion_estructura,
        cc3.conservacion_acabados,
        cc3.conservacion_banio,
        cc3.conservacion_cocina,
        CASE
            WHEN ct2.iliCode = 'Residencial'
                 AND (
                     (cct.iliCode = 'Estructura' AND cc3.conservacion_estructura IS NULL) OR
                     (cct.iliCode = 'Acabados_Principales' AND cc3.conservacion_acabados IS NULL) OR
                     (cct.iliCode = 'Banio' AND cc3.conservacion_banio IS NULL) OR
                     (cct.iliCode = 'Cocina' AND cc3.conservacion_cocina IS NULL)
                 )
            THEN 'Fail'
            ELSE 'Ok'
        END AS cond_4_9
    FROM cca_predio cp
    LEFT JOIN cca_construccion cc ON cp.T_Id = cc.predio
    LEFT JOIN cca_construcciontipo ct ON ct.T_id = cc.tipo_construccion
    LEFT JOIN cca_unidadconstruccion cu ON cc.T_Id = cu.construccion
    LEFT JOIN cca_caracteristicasunidadconstruccion cc2 ON cc2.T_id = cu.caracteristicasunidadconstruccion
    LEFT JOIN cca_unidadconstrucciontipo ut ON ut.T_id = cc2.tipo_unidad_construccion
    LEFT JOIN cca_calificacionconvencional cc3 ON cc3.T_id = cc2.calificacion_convencional
    LEFT JOIN cca_calificartipo ct2 ON ct2.T_id = cc3.tipo_calificar
    LEFT JOIN cca_clasecalificaciontipo cct ON cct.T_id = cc3.clase_calificacion
    WHERE ct.iliCode = 'Convencional' AND cc3.T_id IS NOT NULL
)
SELECT * FROM base WHERE cond_4_9 = 'Fail';

--cond 4.10
WITH base AS (
    SELECT
        cp.numero_predial,
        cc2.T_id AS id_caracteristica_unidad,
        cc2.identificador,
        ct2.iliCode AS tipo_calificar,
        cct.iliCode AS clase_calificacion,
        cc3.conservacion_estructura,
        cc3.conservacion_acabados,
        CASE
            WHEN ct2.iliCode IN ('Comercial', 'Industrial', 'Institucional')
                 AND (
                     (cct.iliCode = 'Estructura' AND cc3.conservacion_estructura IS NULL)
                     OR
                     (cct.iliCode = 'Acabados_Principales' AND cc3.conservacion_acabados IS NULL)
                 )
            THEN 'Fail'
            ELSE 'Ok'
        END AS cond_4_10
    FROM cca_predio cp
    LEFT JOIN cca_construccion cc ON cp.T_Id = cc.predio
    LEFT JOIN cca_construcciontipo ct ON ct.T_id = cc.tipo_construccion
    LEFT JOIN cca_unidadconstruccion cu ON cc.T_Id = cu.construccion
    LEFT JOIN cca_caracteristicasunidadconstruccion cc2 ON cc2.T_id = cu.caracteristicasunidadconstruccion
    LEFT JOIN cca_calificacionconvencional cc3 ON cc3.T_id = cc2.calificacion_convencional
    LEFT JOIN cca_calificartipo ct2 ON ct2.T_id = cc3.tipo_calificar
    LEFT JOIN cca_clasecalificaciontipo cct ON cct.T_id = cc3.clase_calificacion
    WHERE ct.iliCode = 'Convencional'
)
SELECT *
FROM base
WHERE cond_4_10 = 'Fail';

--cond 4.11
WITH unidades_comerciales AS (
    SELECT 
        DISTINCT
        cp.numero_predial,
        cc2.T_id AS id_caracteristica_unidad,
        cc2.identificador, 
        ct2.iliCode AS tipo_calificar,
        cct.iliCode AS clase_calificacion,
        ce2.iliCode AS conservacion_banio,
        ce3.iliCode AS conservacion_cocina,
        mt1.ilicode AS mobiliario_banio,
        mt2.ilicode AS mobiliario_cocina,
        tbt.ilicode AS tamanio_banio,
        en.ilicode AS enchape_banio,
        cc3.conservacion_banio AS conservacion_banio_registro,
        tct.ilicode AS tamanio_cocina,
        en1.ilicode AS enchape_cocina,
        cc3.conservacion_cocina AS conservacion_cocina_registro
    FROM cca_predio cp
    LEFT JOIN cca_construccion cc ON cp.T_Id = cc.predio 
    LEFT JOIN cca_construcciontipo ct ON ct.T_id = cc.tipo_construccion
    LEFT JOIN cca_unidadconstruccion cu ON cc.T_Id = cu.construccion 
    LEFT JOIN cca_caracteristicasunidadconstruccion cc2 ON cc2.T_id = cu.caracteristicasunidadconstruccion 
    LEFT JOIN cca_unidadconstrucciontipo ut ON ut.T_id = cc2.tipo_unidad_construccion 
    LEFT JOIN cca_calificacionconvencional cc3 ON cc3.T_id = cc2.calificacion_convencional
    LEFT JOIN cca_calificartipo ct2 ON ct2.T_id = cc3.tipo_calificar
    LEFT JOIN cca_clasecalificaciontipo cct ON cct.T_id = cc3.clase_calificacion
    LEFT JOIN cca_estadoconservaciontipo ce2 ON ce2.T_id = cc3.conservacion_banio
    LEFT JOIN cca_estadoconservaciontipo ce3 ON ce3.T_id = cc3.conservacion_cocina
    LEFT JOIN cca_mobiliariotipo mt1 on mt1.T_id = cc3.mobiliario_banio
    LEFT JOIN cca_mobiliariotipo mt2 on mt2.T_id = cc3.mobiliario_cocina
    LEFT JOIN cca_tamaniobaniotipo tbt ON tbt.T_id = cc3.tamanio_banio
    LEFT JOIN cca_tamaniococinatipo tct ON tct.T_id = cc3.tamanio_cocina
    LEFT JOIN cca_enchapetipo en on en.T_id = cc3.enchape_banio
    LEFT JOIN cca_enchapetipo en1 on en1.T_id = cc3.enchape_cocina
    WHERE ct2.iliCode = 'Comercial'
)
SELECT 
    numero_predial,
    id_caracteristica_unidad,
    identificador,
    tipo_calificar,
    clase_calificacion,
    conservacion_banio,
    conservacion_cocina,
    mobiliario_banio,
    mobiliario_cocina,
    tamanio_banio,
    enchape_banio,
    --conservacion_banio_registro,
    tamanio_cocina,
    enchape_cocina,
    --conservacion_cocina_registro,
    CASE 
        -- Caso donde hay valores en campos de baño y cocina, excepto mobiliario_banio o mobiliario_cocina
        WHEN mobiliario_banio IS NOT NULL AND (
                tamanio_banio IS NOT NULL OR enchape_banio IS NOT NULL OR conservacion_banio_registro IS NOT NULL
            ) THEN 'Fail'
        WHEN mobiliario_cocina IS NOT NULL AND (
                tamanio_cocina IS NOT NULL OR enchape_cocina IS NOT NULL OR conservacion_cocina_registro IS NOT NULL
            ) THEN 'Fail'
        
        -- Caso donde no hay valores en mobiliario_banio o mobiliario_cocina pero sí en otros campos
        WHEN mobiliario_banio IS NULL AND (
                tamanio_banio IS NOT NULL OR enchape_banio IS NOT NULL OR conservacion_banio_registro IS NOT NULL
            ) THEN 'Fail'
        WHEN mobiliario_cocina IS NULL AND (
                tamanio_cocina IS NOT NULL OR enchape_cocina IS NOT NULL OR conservacion_cocina_registro IS NOT NULL
            ) THEN 'Fail'
        
        ELSE 'OK'
    END AS resultado_regla
FROM unidades_comerciales
WHERE (
    mobiliario_banio IS NOT NULL OR mobiliario_cocina IS NOT NULL
    OR tamanio_banio IS NOT NULL OR enchape_banio IS NOT NULL OR conservacion_banio_registro IS NOT NULL
    OR tamanio_cocina IS NOT NULL OR enchape_cocina IS NOT NULL OR conservacion_cocina_registro IS NOT NULL
)
AND (
    -- Filtra únicamente los registros 'Fail'
    CASE 
        WHEN mobiliario_banio IS NOT NULL AND (
                tamanio_banio IS NOT NULL OR enchape_banio IS NOT NULL OR conservacion_banio_registro IS NOT NULL
            ) THEN 'Fail'
        WHEN mobiliario_cocina IS NOT NULL AND (
                tamanio_cocina IS NOT NULL OR enchape_cocina IS NOT NULL OR conservacion_cocina_registro IS NOT NULL
            ) THEN 'Fail'
        WHEN mobiliario_banio IS NULL AND (
                tamanio_banio IS NOT NULL OR enchape_banio IS NOT NULL OR conservacion_banio_registro IS NOT NULL
            ) THEN 'Fail'
        WHEN mobiliario_cocina IS NULL AND (
                tamanio_cocina IS NOT NULL OR enchape_cocina IS NOT NULL OR conservacion_cocina_registro IS NOT NULL
            ) THEN 'Fail'
        ELSE 'OK'
    END = 'Fail'
);

--cond 4.12
WITH base AS (
    SELECT
        cp.numero_predial,
        cc2.T_id AS id_caracteristica_unidad,
        cc2.identificador,
        ct2.iliCode AS tipo_calificar,
        cct.iliCode AS clase_calificacion,
        cc3.subtotal_estructura,
        cc3.subtotal_acabados,
        cc3.subtotal_banio,
        cc3.subtotal_cocina,
        cc3.total_calificacion,
        COALESCE(cc3.subtotal_estructura,0)
        + COALESCE(cc3.subtotal_acabados,0)
        + COALESCE(cc3.subtotal_banio,0)
        + COALESCE(cc3.subtotal_cocina,0) AS suma_subtotales,
        CASE
            WHEN cc3.total_calificacion IS NULL
                 OR cc3.total_calificacion = 0
                 OR cc3.total_calificacion <> 
                    (COALESCE(cc3.subtotal_estructura,0)
                    + COALESCE(cc3.subtotal_acabados,0)
                    + COALESCE(cc3.subtotal_banio,0)
                    + COALESCE(cc3.subtotal_cocina,0))
            THEN 'Fail'
            ELSE 'Ok'
        END AS cond_4_12
    FROM cca_predio cp
    LEFT JOIN cca_construccion cc ON cp.T_Id = cc.predio
    LEFT JOIN cca_construcciontipo ct ON ct.T_id = cc.tipo_construccion
    LEFT JOIN cca_unidadconstruccion cu ON cc.T_Id = cu.construccion
    LEFT JOIN cca_caracteristicasunidadconstruccion cc2 ON cc2.T_id = cu.caracteristicasunidadconstruccion
    LEFT JOIN cca_calificacionconvencional cc3 ON cc3.T_id = cc2.calificacion_convencional
    LEFT JOIN cca_calificartipo ct2 ON ct2.T_id = cc3.tipo_calificar
    LEFT JOIN cca_clasecalificaciontipo cct ON cct.T_id = cc3.clase_calificacion
    WHERE ct.iliCode = 'Convencional'
)
SELECT *
FROM base
WHERE cond_4_12 = 'Fail';

--cond 4.13
with base as(
select 
cp.numero_predial,
ot.ilicode,
om.valor_pedido,
om.valor_negociado,
CASE 
    WHEN om.valor_pedido is not null and 
         om.valor_negociado is not null and 
         om.valor_negociado > 0 and om.valor_pedido > 0 
    THEN 'Ok' 
    ELSE 'Fail' 
END AS cond_4_13
from cca_predio cp
inner join cca_ofertasmercadoinmobiliario om on cp.T_Id = om.predio 
left JOIN cca_ofertatipo ot ON ot.T_Id = om.tipo_oferta
where ot.ilicode in ('Venta','Arriendo')
)
select * from base
where cond_4_13='Fail';

--cond 4.14
with base as(
select 
distinct
cp.numero_predial,
om.fecha_captura_oferta,
cp.fecha_visita_predial,
CASE 
    WHEN om.fecha_captura_oferta > cp.fecha_visita_predial 
    THEN 'Fail' 
    ELSE 'Ok' 
END AS cond_4_14
from cca_predio cp
inner join cca_ofertasmercadoinmobiliario om on cp.T_Id = om.predio 
left JOIN cca_ofertatipo ot ON ot.T_Id = om.tipo_oferta
where ot.ilicode in ('Venta','Arriendo')
)
select * from base
where cond_4_14='Fail';

--cond 4.15
WITH base AS (
  SELECT 
    cp.numero_predial,
    om.numero_contacto_oferente,
    CASE 
        WHEN om.numero_contacto_oferente !~ '^[0-9]{7,10}$' THEN 'Fail'
        WHEN om.numero_contacto_oferente LIKE '0000%' THEN 'Fail'ELSE 'Ok' 
    END AS cond_4_15
  FROM cca_predio cp
  INNER JOIN cca_ofertasmercadoinmobiliario om ON cp.T_Id = om.predio
)
SELECT * 
FROM base
WHERE cond_4_15 = 'Fail';

COMMIT;