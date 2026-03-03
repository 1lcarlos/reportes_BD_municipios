# Reportes de Validación - Base de Datos Catastrales

Herramienta para la validación de bases de datos catastrales mediante la ejecución de reglas SQL predefinidas. Genera reportes en formato Excel o CSV con los registros que no cumplen las reglas establecidas.

**Desarrollo interno del equipo de Cartografía, Tecnología e Innovación de la ACC.**

---

## Tabla de Contenidos

1. [Requisitos del Sistema](#requisitos-del-sistema)
2. [Instalación](#instalación)
3. [Inicio Rápido](#inicio-rápido)
4. [Guía de Uso](#guía-de-uso)
   - [Pestaña Configuración](#pestaña-configuración)
   - [Pestaña Selección de Reglas](#pestaña-selección-de-reglas)
   - [Pestaña Ejecución](#pestaña-ejecución)
5. [Estructura de Carpetas](#estructura-de-carpetas)
6. [Archivos Generados](#archivos-generados)
7. [Solución de Problemas](#solución-de-problemas)

---

## Requisitos del Sistema

- **Sistema Operativo:** Windows 10 o superior
- **Python:** Versión 3.8 o superior
- **Base de Datos:** PostgreSQL con esquemas LADM_COL
- **Conexión:** Acceso de red a la base de datos

---

## Instalación

### Paso 1: Verificar Python

Abra una terminal (CMD o PowerShell) y ejecute:

```
python --version
```

Si no tiene Python instalado, descárguelo desde [python.org](https://www.python.org/downloads/).

### Paso 2: Instalar dependencias

Navegue a la carpeta del proyecto y ejecute:

```
cd ruta\a\Reportes_Base_Datos_Municipios
pip install -r requirements.txt
```

Esto instalará las siguientes librerías:
- `pandas` - Procesamiento de datos
- `psycopg2-binary` - Conexión a PostgreSQL
- `sqlalchemy` - Motor de conexión a base de datos
- `xlsxwriter` - Generación de archivos Excel

---

## Inicio Rápido

1. Abra una terminal en la carpeta del proyecto
2. Ejecute el comando:

```
python reportes_gui.py
```

3. Se abrirá la interfaz gráfica de la aplicación

---

## Guía de Uso

La aplicación tiene tres pestañas principales: **Configuración**, **Selección de Reglas** y **Ejecución**.

### Pestaña Configuración

Esta pestaña permite configurar todos los parámetros necesarios para la validación.

#### Conexión a Base de Datos

| Campo | Descripción | Ejemplo |
|-------|-------------|---------|
| Host | Dirección del servidor PostgreSQL | `localhost` o `192.168.1.100` |
| Puerto | Puerto de conexión | `5432` (por defecto) |
| Base de datos | Nombre de la base de datos | `ladm_col` |
| Usuario | Usuario de PostgreSQL | `postgres` |
| Contraseña | Contraseña del usuario | `****` |

**Botón "Probar Conexión":** Permite verificar que los datos de conexión son correctos antes de ejecutar la validación.

#### Rutas

| Campo | Descripción |
|-------|-------------|
| Carpeta de reglas SQL | Carpeta que contiene los archivos `.sql` con las reglas de validación |
| Carpeta de salida (reportes) | Carpeta donde se guardarán los reportes generados (Excel/CSV) |
| Carpeta de logs | Carpeta donde se guardarán los archivos de log |

Use el botón **"Examinar..."** para seleccionar las carpetas mediante el explorador de archivos.

#### Esquemas a Analizar

Ingrese los nombres de los esquemas de la base de datos que desea validar, separados por coma.

**Ejemplo:** `esquema_municipio_1, esquema_municipio_2, esquema_municipio_3`

**Botón "Cargar desde BD":** Muestra una lista de todos los esquemas disponibles en la base de datos para seleccionarlos.

#### Opciones de Salida

| Formato | Descripción |
|---------|-------------|
| `excel` | Genera un archivo Excel por esquema con múltiples hojas (una por regla) |
| `csv` | Genera un archivo CSV por cada regla y esquema |
| `both` | Genera ambos formatos |

#### Botones de Configuración

- **Guardar Configuración:** Guarda la configuración actual para uso futuro
- **Cargar Configuración:** Carga la última configuración guardada
- **Restaurar Valores por Defecto:** Restablece todos los campos a sus valores iniciales

---

### Pestaña Selección de Reglas

Esta pestaña permite seleccionar qué reglas de validación ejecutar.

#### Cargar Reglas

1. Asegúrese de haber configurado la **Carpeta de reglas SQL** en la pestaña de Configuración
2. Haga clic en el botón **"Cargar Reglas"**
3. Se mostrarán todas las reglas disponibles organizadas por categoría

#### Seleccionar Reglas

- **Clic en la columna "Sel.":** Alterna la selección de una regla individual
- **Tecla Espacio:** Alterna la selección de las reglas seleccionadas
- **Botón "Seleccionar Todas":** Selecciona todas las reglas disponibles
- **Botón "Deseleccionar Todas":** Deselecciona todas las reglas

El contador en la esquina superior derecha muestra: `Reglas cargadas: X | Seleccionadas: Y`

---

### Pestaña Ejecución

Esta pestaña permite ejecutar la validación y ver el progreso en tiempo real.

#### Ejecutar Validación

1. Haga clic en el botón **"Ejecutar Validación"**
2. La barra de progreso mostrará el avance
3. El área de log mostrará mensajes en tiempo real:
   - **Verde:** Operaciones exitosas
   - **Negro:** Información general
   - **Naranja:** Advertencias
   - **Rojo:** Errores

#### Controles

| Botón | Función |
|-------|---------|
| Ejecutar Validación | Inicia el proceso de validación |
| Detener | Detiene la ejecución en curso |
| Limpiar Log | Borra los mensajes del área de log |

---

## Estructura de Carpetas

```
Reportes_Base_Datos_Municipios/
│
├── reportes_gui.py          # Aplicación principal (interfaz gráfica)
├── reportes.py               # Script original (línea de comandos)
├── requirements.txt          # Dependencias de Python
├── reportes_config.json      # Configuración guardada (se genera automáticamente)
│
├── consultas_sql/            # Carpeta de reglas de validación
│   ├── regla_01_xxx.sql
│   ├── regla_02_xxx.sql
│   ├── ...
│   ├── administrativas/      # Subcarpeta de reglas
│   │   └── *.sql
│   ├── fisicas/
│   │   └── *.sql
│   ├── juridicas/
│   │   └── *.sql
│   └── economicas/
│       └── *.sql
│
└── [reportes generados]      # Archivos de salida
```

### Organización de Reglas SQL

Las reglas pueden organizarse de dos formas:

1. **En la raíz de `consultas_sql/`:** Todas las reglas en una sola carpeta
2. **En subcarpetas:** Organizadas por categoría (administrativas, físicas, jurídicas, etc.)

La aplicación carga automáticamente las reglas de ambas ubicaciones.

---

## Archivos Generados

### Reportes Excel

**Nombre del archivo:** `reporte_[esquema]_[timestamp].xlsx`

**Estructura:**
- Una hoja por cada regla ejecutada
- Hoja "Resumen" con el conteo de registros por regla

**Ejemplo:** `reporte_lev_municipio_abc_03022026_143025.xlsx`

### Reportes CSV

**Nombre del archivo:** `reporte_[esquema]_[regla]_[timestamp].csv`

- Un archivo por cada regla
- Separador: punto y coma (;)
- Codificación: UTF-8

**Ejemplo:** `reporte_lev_municipio_abc_regla_01_numero_predial_03022026_143025.csv`

### Archivos de Log

**Nombre del archivo:** `log_[timestamp].txt`

Contiene el registro detallado de la ejecución:
- Hora de inicio y fin
- Consultas ejecutadas
- Errores encontrados
- Cantidad de registros por consulta

---

## Solución de Problemas

### Error de conexión a la base de datos

| Problema | Solución |
|----------|----------|
| "Connection refused" | Verifique que PostgreSQL está en ejecución y el puerto es correcto |
| "Authentication failed" | Verifique usuario y contraseña |
| "Database does not exist" | Verifique el nombre de la base de datos |

### No se cargan las reglas

- Verifique que la ruta de la carpeta de reglas es correcta
- Asegúrese de que los archivos tienen extensión `.sql`
- Verifique que tiene permisos de lectura en la carpeta

### El reporte Excel no se genera

- Verifique que tiene permisos de escritura en la carpeta de salida
- Cierre cualquier archivo Excel con el mismo nombre que esté abierto
- Verifique que hay espacio disponible en disco

### Error "module not found"

Reinstale las dependencias:
```
pip install -r requirements.txt
```

### Error "UndefinedColumn" o "no existe la columna"

Este error indica que una consulta SQL hace referencia a una columna que no existe en el esquema de la base de datos. Posibles causas:

- La consulta fue diseñada para una versión diferente del modelo LADM_COL
- El esquema tiene una estructura personalizada
- El nombre de la columna cambió en el modelo

**Solución:** Revise y ajuste el archivo `.sql` correspondiente en la carpeta de reglas para que coincida con la estructura del esquema que está validando.

---

## Notas Adicionales

- La configuración se guarda automáticamente en `reportes_config.json`
- Los nombres de hojas Excel se truncan a 31 caracteres (límite de Excel)
- Las consultas vacías (sin resultados) indican que no hay errores para esa regla
- El proceso puede detenerse en cualquier momento con el botón "Detener"

---

## Estructura de las Reglas SQL

Cada archivo `.sql` en la carpeta de reglas debe contener una consulta SELECT que retorne los registros que **no cumplen** con la regla de validación.

### Formato recomendado

```sql
-- =========================================================
-- REGLA XX: Nombre descriptivo de la regla
-- =========================================================
-- Descripción:
-- Explicación detallada de qué valida esta regla
-- =========================================================

SELECT
    p.t_id,
    p.numero_predial,
    -- otros campos relevantes
    'Error: Descripción del error encontrado' AS mensaje_error
FROM tabla_principal p
-- JOINs necesarios
WHERE
    -- Condiciones que identifican registros con errores
```

### Recomendaciones

- Incluir siempre un campo identificador (`t_id`, `numero_predial`)
- Agregar un campo `mensaje_error` descriptivo
- Documentar la regla con comentarios al inicio del archivo
- Probar la consulta directamente en PostgreSQL antes de agregarla

---

**Versión:** 2.0
**Última actualización:** Febrero 2026
