--cond 2.13
with base as 
(
select 
cp.numero_predial,
cpt.ilicode tipo_predio,
cd2.ilicode tipo_derecho,
ci2.ilicode interesado_tipo
from cca_predio cp
left join cca_derecho cd on cd.predio =cp.T_Id
left join cca_derechotipo cd2 on cd2.T_Id =cd.tipo 
LEFT JOIN cca_prediotipo cpt ON cpt.T_Id = cp.predio_tipo 
left join cca_agrupacioninteresados cai on cai.T_Id = cd.agrupacion_interesados
left join cca_miembros cm on cm.agrupacion  =cai.T_Id
left join cca_interesado ci on ci.T_Id =cm.interesado
left join cca_interesadotipo ci2 on ci2.T_Id =ci.tipo 
left join cca_grupoetnicotipo cge on cge.T_Id =ci.grupo_etnico
where  cpt.ilicode in ('Predio.Publico.Uso_Publico','Predio.Publico.Patrimonial','Predio.Publico.Fiscal')
and cd2.ilicode ='Dominio'
union all
select 
cp.numero_predial,
cpt.ilicode tipo_predio,
cd2.ilicode tipo_derecho,
ci2.ilicode interesado_tipo
from cca_predio cp
left join cca_derecho cd on cd.predio =cp.T_Id
left join cca_derechotipo cd2 on cd2.T_Id =cd.tipo 
LEFT JOIN cca_prediotipo cpt ON cpt.T_Id = cp.predio_tipo 
left join cca_interesado ci on ci.T_Id =cd.interesado
left join cca_interesadotipo ci2 on ci2.T_Id =ci.tipo 
left join cca_grupoetnicotipo cge on cge.T_Id =ci.grupo_etnico
where  cpt.ilicode in ('Predio.Publico.Uso_Publico','Predio.Publico.Patrimonial','Predio.Publico.Fiscal')
and cd2.ilicode ='Dominio'
)
select *,'Fail' cond_2_13 
from base
where interesado_tipo <> 'Persona_Juridica';