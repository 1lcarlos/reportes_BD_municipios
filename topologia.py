import os
import zipfile
import datetime
import psycopg2
import geopandas as gpd
from sqlalchemy import create_engine

# --- Configuración base ---
DB_PARAMS = {
    "host": "localhost",
    "port": 5432,
    "dbname": "ACC_2025",
    "user": "postgres",
    "password": "****",
}

SCHEMAS = ["cun25797", "cun25489", "cun25436"]  # Lista de esquemas a procesar
SQL_FILE = "consultas_sql/sobreposicion_terrenos.sql"
OUTPUT_FOLDER = "shapefiles_generados"
LOG_FILE = "log_topologia/log_proceso.txt"


# --- Función para registrar en el log ---
def log_mensaje(mensaje):
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a", encoding="utf-8") as log_file:
        log_file.write(f"[{timestamp}] {mensaje}\n")


# --- Función de conexión ---
def crear_conexion(params):
    try:
        conn_str = f"postgresql://{params['user']}:{params['password']}@{params['host']}:{params['port']}/{params['dbname']}"
        engine = create_engine(conn_str)
        log_mensaje("Conexión a la base de datos establecida correctamente.")
        return engine
    except Exception as e:
        log_mensaje(f"Error al conectar a la base de datos: {e}")
        raise


# --- Función para ejecutar consulta desde archivo SQL para cada esquema ---
def obtener_sobreposiciones(engine, sql_path, schema):
    try:
        with open(sql_path, "r", encoding="utf-8") as file:
            query = file.read()

        query = f"SET search_path TO {schema}, public; " + query.replace(
            "{{schema}}", schema
        )

        gdf = gpd.read_postgis(query, engine, geom_col="geometria")
        gdf = gdf.set_crs(epsg=9377)
        log_mensaje(
            f"Consulta ejecutada correctamente en el esquema '{schema}'. Registros encontrados: {len(gdf)}."
        )
        return gdf

    except Exception as e:
        log_mensaje(f"Error al ejecutar la consulta en el esquema '{schema}': {e}")
        return None


# --- Función para exportar shapefile por tipo de geometría ---
def exportar_shapefile_por_tipo(gdf, schema, output_folder):
    try:
        timestamp = datetime.datetime.now().strftime("%d%m%y_%H%M%S")
        os.makedirs(output_folder, exist_ok=True)

        # Filtrar polígonos y líneas
        gdf_pol = gdf[gdf.geometry.type.isin(["Polygon", "MultiPolygon"])]
        gdf_lin = gdf[gdf.geometry.type.isin(["LineString", "MultiLineString"])]

        rutas_exportadas = []

        if not gdf_pol.empty:
            base_pol = os.path.join(
                output_folder, f"{schema}_sobreposicionP_{timestamp}"
            )
            gdf_pol.to_file(
                f"{base_pol}.shp", driver="ESRI Shapefile", encoding="utf-8"
            )
            log_mensaje(f"Shapefile de POLÍGONOS exportado: {base_pol}.shp")
            rutas_exportadas.append(base_pol)

        if not gdf_lin.empty:
            base_lin = os.path.join(
                output_folder, f"{schema}_sobreposicionL_{timestamp}"
            )
            gdf_lin.to_file(
                f"{base_lin}.shp", driver="ESRI Shapefile", encoding="utf-8"
            )
            log_mensaje(f"Shapefile de LÍNEAS exportado: {base_lin}.shp")
            rutas_exportadas.append(base_lin)

        return rutas_exportadas

    except Exception as e:
        log_mensaje(f"Error al exportar shapefiles del esquema '{schema}': {e}")
        return []


# --- Función para comprimir shapefiles ---
def comprimir_shapefile(filepath_base):
    try:
        zip_path = f"{filepath_base}.zip"
        with zipfile.ZipFile(zip_path, "w") as zipf:
            for ext in [".shp", ".shx", ".dbf", ".prj", ".cpg"]:
                file = filepath_base + ext
                if os.path.exists(file):
                    zipf.write(file, os.path.basename(file))
                    os.remove(file)
        log_mensaje(f"Shapefile comprimido exitosamente: {zip_path}")
    except Exception as e:
        log_mensaje(f"Error al comprimir shapefile '{filepath_base}': {e}")


# --- Flujo principal ---
def procesar_esquemas():
    engine = crear_conexion(DB_PARAMS)
    for schema in SCHEMAS:
        log_mensaje(f"Iniciando procesamiento del esquema '{schema}'...")
        gdf = obtener_sobreposiciones(engine, SQL_FILE, schema)
        if gdf is not None and not gdf.empty:
            rutas = exportar_shapefile_por_tipo(gdf, schema, OUTPUT_FOLDER)
            for ruta in rutas:
                comprimir_shapefile(ruta)
        else:
            log_mensaje(
                f"No se generó shapefile para el esquema '{schema}' (resultado vacío o error)."
            )


# --- Ejecutar si se corre como script principal ---
procesar_esquemas()
