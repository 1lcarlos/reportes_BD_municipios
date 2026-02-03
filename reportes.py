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
    "port": 5433,
    "dbname": "ladm_col",
    "user": "postgres",
    "password": "****",
}

# Lista de esquemas a analizar (MODIFICA AQUÍ)
SCHEMAS = ["lev_manta_entrega_20260114"]

# Ruta a la carpeta que contiene los archivos .sql (MODIFICA AQUÍ)
SQL_FOLDER = "./consultas_sql"

# Configuración de formato de salida (MODIFICA AQUÍ)
# Opciones: "excel", "csv", "both"
OUTPUT_FORMAT = "excel"

# Configuración de consultas a ejecutar (MODIFICA AQUÍ)
# Opciones: "all" para ejecutar todas las consultas, o lista con nombres específicos
# Ejemplo: ["consulta1", "consulta2"] o "all"
# IMPORTANTE: No incluir la extensión .sql en los nombres
QUERIES_TO_RUN = "all"

# Obtener timestamp para nombres de archivos únicos
timestamp = datetime.now().strftime("%d%m%Y_%H%M%S")

# Crear archivo de log
log_filename = f"log_{timestamp}.txt"
logging.basicConfig(
    filename=log_filename,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)


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
            with open(
                os.path.join(folder_path, filename), "r", encoding="utf-8"
            ) as file:
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
                full_query = f"SET search_path TO public, {schema}; {query_template}"
                df = pd.read_sql(full_query, conn)
                schema_results[query_name] = df
                logging.info(
                    f"Consulta '{query_name}' ejecutada con éxito en esquema '{schema}'."
                )
            except Exception as e:
                logging.error(
                    f"Fallo la consulta '{query_name}' en esquema '{schema}': {e}"
                )
                schema_results[query_name] = pd.DataFrame()
        results_by_schema[schema] = schema_results

    return results_by_schema


# ----------------------------- FUNCIÓN: FILTRAR CONSULTAS -----------------------------
def filter_queries(queries_dict):
    """Filtra las consultas según la configuración QUERIES_TO_RUN"""
    if QUERIES_TO_RUN == "all":
        return queries_dict
    elif isinstance(QUERIES_TO_RUN, list):
        return {k: v for k, v in queries_dict.items() if k in QUERIES_TO_RUN}
    else:
        logging.warning(
            f"Configuración QUERIES_TO_RUN inválida: {QUERIES_TO_RUN}. Usando todas las consultas."
        )
        return queries_dict


# ----------------------------- FUNCIÓN: EXPORTAR A CSV -----------------------------
def export_to_csv(results_by_schema):
    """Exporta cada consulta de cada esquema a un archivo CSV individual"""
    for schema, queries_dict in results_by_schema.items():
        filtered_queries = filter_queries(queries_dict)

        for query_name, df in filtered_queries.items():
            if df.empty:
                logging.warning(
                    f"Consulta '{query_name}' en esquema '{schema}' está vacía. No se generará CSV."
                )
                continue

            # Eliminar timezone si existe
            for col in df.select_dtypes(include=["datetimetz"]).columns:
                df[col] = df[col].dt.tz_localize(None)

            csv_name = f"reporte_{schema}_{query_name}_{timestamp}.csv"
            df.to_csv(csv_name, index=False, sep=";", encoding="utf-8")

            logging.info(
                f"Archivo CSV '{csv_name}' generado para consulta '{query_name}' en esquema '{schema}'."
            )
            print(f"✅ Archivo CSV generado: {csv_name}")


# ----------------------------- FUNCIÓN: EXPORTAR A EXCEL -----------------------------
def export_to_excel(results_by_schema):
    """Exporta todas las consultas de cada esquema a un archivo Excel con múltiples hojas"""
    for schema, queries_dict in results_by_schema.items():
        filtered_queries = filter_queries(queries_dict)

        excel_name = f"reporte_{schema}_{timestamp}.xlsx"
        writer = pd.ExcelWriter(excel_name, engine="xlsxwriter")
        summary_data = []

        for sheet_name, df in filtered_queries.items():
            # ✅ Corrección: eliminar timezone si existe
            for col in df.select_dtypes(include=["datetimetz"]).columns:
                df[col] = df[col].dt.tz_localize(None)

            df.to_excel(
                writer, sheet_name=sheet_name[:31], index=False
            )  # Excel limita nombres de hoja a 31 caracteres
            summary_data.append(
                {"Consulta": sheet_name, "Registros encontrados": len(df)}
            )

        # Hoja resumen
        summary_df = pd.DataFrame(summary_data)
        summary_df.to_excel(writer, sheet_name="Resumen", index=False)

        writer.close()
        logging.info(
            f"Archivo Excel '{excel_name}' generado para el esquema '{schema}'."
        )
        print(f"✅ Archivo Excel generado: {excel_name}")


# ----------------------------- FUNCIÓN: EXPORTAR RESULTADOS -----------------------------
def export_results(results_by_schema):
    """Coordina la exportación según la configuración OUTPUT_FORMAT"""
    if OUTPUT_FORMAT == "excel":
        logging.info("Exportando solo a formato Excel...")
        export_to_excel(results_by_schema)
    elif OUTPUT_FORMAT == "csv":
        logging.info("Exportando solo a formato CSV...")
        export_to_csv(results_by_schema)
    elif OUTPUT_FORMAT == "both":
        logging.info("Exportando a ambos formatos (Excel y CSV)...")
        export_to_excel(results_by_schema)
        export_to_csv(results_by_schema)
    else:
        logging.error(
            f"Formato de salida no válido: '{OUTPUT_FORMAT}'. Use 'excel', 'csv' o 'both'."
        )
        print(
            f"❌ Error: Formato '{OUTPUT_FORMAT}' no válido. Use 'excel', 'csv' o 'both'."
        )


# ----------------------------- EJECUCIÓN PRINCIPAL -----------------------------
def main():
    try:
        logging.info("Iniciando proceso de auditoría")
        print(f"⚙️  Configuración:")
        print(f"   - Formato de salida: {OUTPUT_FORMAT}")
        print(f"   - Consultas a ejecutar: {QUERIES_TO_RUN}")

        conn = connect_to_db(DB_PARAMS)
        queries = load_sql_queries_from_folder(SQL_FOLDER)
        results = execute_queries_per_schema(conn, SCHEMAS, queries)
        export_results(results)
        conn.close()
        logging.info("Proceso finalizado correctamente.")
        print("✅ Proceso completado con éxito.")
    except Exception as e:
        logging.error(f"Proceso interrumpido: {e}")
        print("❌ Proceso interrumpido, revisa el archivo de log.")


if __name__ == "__main__":
    main()
