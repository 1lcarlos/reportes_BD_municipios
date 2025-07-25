import logging
import os
from datetime import datetime
import psycopg2
import pandas as pd
import xlsxwriter

# ----------------------------- CONFIGURACIÓN GLOBAL -----------------------------

# Parámetros de conexión (MODIFICA AQUÍ)
DB_PARAMS = {
    "host": "localhost",
    "port": "5432",
    "dbname": "mi_basededatos",
    "user": "mi_usuario",
    "password": "mi_contraseña"
}

# Lista de esquemas a analizar (MODIFICA AQUÍ)
SCHEMAS = ['esquema1','esquema2']

# Ruta a la carpeta que contiene los archivos .sql (MODIFICA AQUÍ)
SQL_FOLDER = './consultas_sql'

# Obtener timestamp para nombres de archivos únicos
timestamp = datetime.now().strftime("%d%m%Y_%H%M%S")

# Crear archivo de log
log_filename = f"log_{timestamp}.txt"
logging.basicConfig(filename=log_filename, level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# ----------------------------- FUNCIÓN: CONEXIÓN DB -----------------------------
def connect_to_db(params):
    try:
        conn = psycopg2.connect(**params)
        logging.info("Conexión exitosa a la base de datos.")
        print("✅ Conexión exitosa.")
        return conn
    except Exception as e:
        logging.error(f"Error al conectar a la base de datos: {e}")
        print("❌ Error en la conexión:", e)
        raise

# ----------------------------- FUNCIÓN: CARGAR CONSULTAS -----------------------------
def load_sql_queries_from_folder(folder_path):
    queries = {}
    for filename in os.listdir(folder_path):
        if filename.endswith(".sql"):
            with open(os.path.join(folder_path, filename), 'r', encoding='utf-8') as file:
                queries[filename.replace(".sql", "")] = file.read()
    logging.info(f"{len(queries)} consultas SQL cargadas desde {folder_path}.")
    return queries

# ----------------------------- FUNCIÓN: EJECUTAR CONSULTAS POR ESQUEMA -----------------------------
def execute_queries_per_schema(conn, schemas, queries):
    results_by_schema = {}

    for schema in schemas:
        logging.info(f"Procesando esquema: {schema}")
        schema_results = {}
        for query_name, query_template in queries.items():
            try:
                full_query = f"SET search_path TO {schema}; {query_template}"
                df = pd.read_sql(full_query, conn)
                schema_results[query_name] = df
                logging.info(f"Consulta '{query_name}' ejecutada con éxito en esquema '{schema}'.")
            except Exception as e:
                logging.error(f"Fallo la consulta '{query_name}' en esquema '{schema}': {e}")
                schema_results[query_name] = pd.DataFrame()
        results_by_schema[schema] = schema_results

    return results_by_schema

# ----------------------------- FUNCIÓN: EXPORTAR A EXCEL -----------------------------
def export_to_excel(results_by_schema):
    for schema, queries_dict in results_by_schema.items():
        excel_name = f"reporte_{schema}_{timestamp}.xlsx"
        writer = pd.ExcelWriter(excel_name, engine="xlsxwriter")
        summary_data = []

        for sheet_name, df in queries_dict.items():
            # ✅ Corrección: eliminar timezone si existe
            for col in df.select_dtypes(include=["datetimetz"]).columns:
                df[col] = df[col].dt.tz_localize(None)

            df.to_excel(writer, sheet_name=sheet_name[:31], index=False)  # Excel limita nombres de hoja a 31 caracteres
            summary_data.append({
                "Consulta": sheet_name,
                "Registros encontrados": len(df)
            })

        # Hoja resumen
        summary_df = pd.DataFrame(summary_data)
        summary_df.to_excel(writer, sheet_name="Resumen", index=False)

        writer.close()
        logging.info(f"Archivo Excel '{excel_name}' generado para el esquema '{schema}'.")
        print(f"✅ Archivo generado: {excel_name}")

# ----------------------------- EJECUCIÓN PRINCIPAL -----------------------------
def main():
    try:
        logging.info("Iniciando proceso de auditoría")
        conn = connect_to_db(DB_PARAMS)
        queries = load_sql_queries_from_folder(SQL_FOLDER)
        results = execute_queries_per_schema(conn, SCHEMAS, queries)
        export_to_excel(results)
        conn.close()
        logging.info("Proceso finalizado correctamente.")
        print("✅ Proceso completado con éxito.")
    except Exception as e:
        logging.error(f"Proceso interrumpido: {e}")
        print("❌ Proceso interrumpido, revisa el archivo de log.")

if __name__ == "__main__":
    main()
