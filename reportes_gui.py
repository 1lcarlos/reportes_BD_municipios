"""
Interfaz gráfica para la generación de reportes de validación de bases de datos catastrales.
Desarrollado por el equipo de Cartografía, Tecnología e Innovación de la ACC.
"""

import json
import logging
import os
import queue
import threading
import tkinter as tk
from datetime import datetime
from pathlib import Path
from tkinter import filedialog, messagebox, ttk

import re

import pandas as pd
import psycopg2
from sqlalchemy import create_engine, text
import xlsxwriter


def validate_identifier(name):
    """Valida que un nombre de esquema/tabla solo contenga caracteres seguros."""
    if not re.match(r'^[a-zA-Z_][a-zA-Z0-9_]*$', name):
        raise ValueError(f"Nombre de identificador no válido: '{name}'")
    return name

# ----------------------------- CONFIGURACIÓN -----------------------------

CONFIG_FILE = "reportes_config.json"
DEFAULT_CONFIG = {
    "db_host": "localhost",
    "db_port": "5432",
    "db_name": "",
    "db_user": "postgres",
    "db_password": "",
    "sql_folder": "./consultas_sql",
    "output_folder": "./",
    "log_folder": "./",
    "output_format": "excel",
    "schemas": "",
}


# ----------------------------- FUNCIONES DE CONFIGURACIÓN -----------------------------


def load_config():
    """Carga la configuración desde el archivo JSON"""
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                return {**DEFAULT_CONFIG, **json.load(f)}
        except Exception:
            return DEFAULT_CONFIG.copy()
    return DEFAULT_CONFIG.copy()


def save_config(config):
    """Guarda la configuración en el archivo JSON"""
    with open(CONFIG_FILE, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=4, ensure_ascii=False)


# ----------------------------- FUNCIONES DE BASE DE DATOS -----------------------------


def create_connection_string(params):
    """Crea la cadena de conexión para SQLAlchemy"""
    host = params.get("host", "localhost")
    port = params.get("port", 5432)
    dbname = params.get("dbname", "")
    user = params.get("user", "postgres")
    password = params.get("password", "")
    return f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{dbname}"


def test_connection(params, log_callback=None):
    """Prueba la conexión a la base de datos"""
    try:
        conn_string = create_connection_string(params)
        engine = create_engine(conn_string)
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        engine.dispose()
        return True, "Conexión exitosa"
    except Exception as e:
        return False, str(e)


def get_schemas_from_db(params):
    """Obtiene la lista de esquemas disponibles en la base de datos"""
    try:
        conn_string = create_connection_string(params)
        engine = create_engine(conn_string)
        with engine.connect() as conn:
            result = conn.execute(text("""
                SELECT schema_name
                FROM information_schema.schemata
                WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
                ORDER BY schema_name
            """))
            schemas = [row[0] for row in result.fetchall()]
        engine.dispose()
        return schemas
    except Exception:
        return []


# ----------------------------- FUNCIONES DE CONSULTAS SQL -----------------------------


def load_sql_queries_from_folder(folder_path, include_subfolders=True):
    """
    Carga las consultas SQL desde una carpeta.
    Retorna un diccionario con la estructura: {categoria: {nombre_consulta: contenido}}
    """
    queries = {}
    folder = Path(folder_path)

    if not folder.exists():
        return queries

    # Cargar archivos .sql del directorio raíz
    root_queries = {}
    for sql_file in folder.glob("*.sql"):
        with open(sql_file, "r", encoding="utf-8") as f:
            root_queries[sql_file.stem] = f.read()
    if root_queries:
        queries["raiz"] = root_queries

    # Cargar archivos .sql de subdirectorios
    if include_subfolders:
        for subdir in folder.iterdir():
            if subdir.is_dir() and not subdir.name.startswith(".") and subdir.name != "esconder":
                subdir_queries = {}
                for sql_file in subdir.glob("*.sql"):
                    with open(sql_file, "r", encoding="utf-8") as f:
                        subdir_queries[sql_file.stem] = f.read()
                if subdir_queries:
                    queries[subdir.name] = subdir_queries

    return queries


def get_query_tree_structure(folder_path):
    """
    Obtiene la estructura de árbol de las consultas para mostrar en la GUI.
    Retorna una lista de tuplas: (categoria, nombre_consulta, ruta_completa)
    """
    structure = []
    folder = Path(folder_path)

    if not folder.exists():
        return structure

    # Archivos en raíz
    for sql_file in sorted(folder.glob("*.sql")):
        structure.append(("raiz", sql_file.stem, str(sql_file)))

    # Archivos en subdirectorios
    for subdir in sorted(folder.iterdir()):
        if subdir.is_dir() and not subdir.name.startswith(".") and subdir.name != "esconder":
            for sql_file in sorted(subdir.glob("*.sql")):
                structure.append((subdir.name, sql_file.stem, str(sql_file)))

    return structure


# ----------------------------- CLASE PRINCIPAL DE LA APLICACIÓN -----------------------------


class ReportesApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Reportes de Validación - Base de Datos Catastrales")
        self.root.geometry("1000x750")
        self.root.minsize(900, 700)

        # Variables
        self.config = load_config()
        self.selected_queries = {}
        self.log_queue = queue.Queue()
        self.is_running = False

        # Configurar estilo
        self.setup_styles()

        # Crear interfaz
        self.create_widgets()

        # Cargar configuración guardada
        self.load_saved_config()

        # Iniciar verificación del log queue
        self.check_log_queue()

    def setup_styles(self):
        """Configura los estilos de la aplicación"""
        style = ttk.Style()
        style.configure("Header.TLabel", font=("Segoe UI", 10, "bold"))
        style.configure("Status.TLabel", font=("Segoe UI", 9))

    def create_widgets(self):
        """Crea todos los widgets de la interfaz"""
        # Frame principal con scroll
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)

        # Crear notebook (pestañas)
        self.notebook = ttk.Notebook(main_frame)
        self.notebook.pack(fill=tk.BOTH, expand=True)

        # Pestaña 1: Configuración
        self.tab_config = ttk.Frame(self.notebook, padding="10")
        self.notebook.add(self.tab_config, text="Configuración")

        # Pestaña 2: Selección de Reglas
        self.tab_rules = ttk.Frame(self.notebook, padding="10")
        self.notebook.add(self.tab_rules, text="Selección de Reglas")

        # Pestaña 3: Ejecución y Log
        self.tab_execution = ttk.Frame(self.notebook, padding="10")
        self.notebook.add(self.tab_execution, text="Ejecución")

        # Crear contenido de cada pestaña
        self.create_config_tab()
        self.create_rules_tab()
        self.create_execution_tab()

    def create_config_tab(self):
        """Crea el contenido de la pestaña de configuración"""
        # Frame de conexión a BD
        db_frame = ttk.LabelFrame(self.tab_config, text="Conexión a Base de Datos", padding="10")
        db_frame.pack(fill=tk.X, pady=(0, 10))

        # Grid para campos de BD
        ttk.Label(db_frame, text="Host:").grid(row=0, column=0, sticky=tk.W, pady=2)
        self.db_host = ttk.Entry(db_frame, width=30)
        self.db_host.grid(row=0, column=1, sticky=tk.W, padx=(5, 20), pady=2)

        ttk.Label(db_frame, text="Puerto:").grid(row=0, column=2, sticky=tk.W, pady=2)
        self.db_port = ttk.Entry(db_frame, width=10)
        self.db_port.grid(row=0, column=3, sticky=tk.W, padx=5, pady=2)

        ttk.Label(db_frame, text="Base de datos:").grid(row=1, column=0, sticky=tk.W, pady=2)
        self.db_name = ttk.Entry(db_frame, width=30)
        self.db_name.grid(row=1, column=1, sticky=tk.W, padx=(5, 20), pady=2)

        ttk.Label(db_frame, text="Usuario:").grid(row=2, column=0, sticky=tk.W, pady=2)
        self.db_user = ttk.Entry(db_frame, width=30)
        self.db_user.grid(row=2, column=1, sticky=tk.W, padx=(5, 20), pady=2)

        ttk.Label(db_frame, text="Contraseña:").grid(row=2, column=2, sticky=tk.W, pady=2)
        self.db_password = ttk.Entry(db_frame, width=20, show="*")
        self.db_password.grid(row=2, column=3, sticky=tk.W, padx=5, pady=2)

        # Botón de prueba de conexión
        self.btn_test_conn = ttk.Button(db_frame, text="Probar Conexión", command=self.test_connection)
        self.btn_test_conn.grid(row=3, column=0, columnspan=2, pady=10, sticky=tk.W)

        self.conn_status = ttk.Label(db_frame, text="", style="Status.TLabel")
        self.conn_status.grid(row=3, column=2, columnspan=2, pady=10, sticky=tk.W)

        # Frame de rutas
        paths_frame = ttk.LabelFrame(self.tab_config, text="Rutas", padding="10")
        paths_frame.pack(fill=tk.X, pady=(0, 10))

        # Carpeta de consultas SQL
        ttk.Label(paths_frame, text="Carpeta de reglas SQL:").grid(row=0, column=0, sticky=tk.W, pady=2)
        self.sql_folder = ttk.Entry(paths_frame, width=60)
        self.sql_folder.grid(row=0, column=1, sticky=tk.W, padx=5, pady=2)
        ttk.Button(paths_frame, text="Examinar...", command=lambda: self.browse_folder(self.sql_folder)).grid(
            row=0, column=2, padx=5, pady=2
        )

        # Carpeta de salida de reportes
        ttk.Label(paths_frame, text="Carpeta de salida (reportes):").grid(row=1, column=0, sticky=tk.W, pady=2)
        self.output_folder = ttk.Entry(paths_frame, width=60)
        self.output_folder.grid(row=1, column=1, sticky=tk.W, padx=5, pady=2)
        ttk.Button(paths_frame, text="Examinar...", command=lambda: self.browse_folder(self.output_folder)).grid(
            row=1, column=2, padx=5, pady=2
        )

        # Carpeta de logs
        ttk.Label(paths_frame, text="Carpeta de logs:").grid(row=2, column=0, sticky=tk.W, pady=2)
        self.log_folder = ttk.Entry(paths_frame, width=60)
        self.log_folder.grid(row=2, column=1, sticky=tk.W, padx=5, pady=2)
        ttk.Button(paths_frame, text="Examinar...", command=lambda: self.browse_folder(self.log_folder)).grid(
            row=2, column=2, padx=5, pady=2
        )

        # Frame de esquemas
        schemas_frame = ttk.LabelFrame(self.tab_config, text="Esquemas a Analizar", padding="10")
        schemas_frame.pack(fill=tk.X, pady=(0, 10))

        ttk.Label(schemas_frame, text="Esquemas (separados por coma):").grid(row=0, column=0, sticky=tk.W, pady=2)
        self.schemas = ttk.Entry(schemas_frame, width=60)
        self.schemas.grid(row=0, column=1, sticky=tk.W, padx=5, pady=2)
        ttk.Button(schemas_frame, text="Cargar desde BD", command=self.load_schemas_from_db).grid(
            row=0, column=2, padx=5, pady=2
        )

        # Frame de opciones
        options_frame = ttk.LabelFrame(self.tab_config, text="Opciones de Salida", padding="10")
        options_frame.pack(fill=tk.X, pady=(0, 10))

        ttk.Label(options_frame, text="Formato de salida:").grid(row=0, column=0, sticky=tk.W, pady=2)
        self.output_format = ttk.Combobox(options_frame, values=["excel", "csv", "both"], state="readonly", width=15)
        self.output_format.grid(row=0, column=1, sticky=tk.W, padx=5, pady=2)
        self.output_format.set("excel")

        # Botones de configuración
        btn_frame = ttk.Frame(self.tab_config)
        btn_frame.pack(fill=tk.X, pady=10)

        ttk.Button(btn_frame, text="Guardar Configuración", command=self.save_current_config).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Cargar Configuración", command=self.load_config_from_file).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Restaurar Valores por Defecto", command=self.reset_config).pack(side=tk.LEFT, padx=5)

    def create_rules_tab(self):
        """Crea el contenido de la pestaña de selección de reglas"""
        # Frame de controles
        controls_frame = ttk.Frame(self.tab_rules)
        controls_frame.pack(fill=tk.X, pady=(0, 10))

        ttk.Button(controls_frame, text="Cargar Reglas", command=self.load_rules).pack(side=tk.LEFT, padx=5)
        ttk.Button(controls_frame, text="Seleccionar Todas", command=self.select_all_rules).pack(side=tk.LEFT, padx=5)
        ttk.Button(controls_frame, text="Deseleccionar Todas", command=self.deselect_all_rules).pack(side=tk.LEFT, padx=5)

        self.rules_count_label = ttk.Label(controls_frame, text="Reglas cargadas: 0 | Seleccionadas: 0")
        self.rules_count_label.pack(side=tk.RIGHT, padx=5)

        # Frame del árbol de reglas
        tree_frame = ttk.Frame(self.tab_rules)
        tree_frame.pack(fill=tk.BOTH, expand=True)

        # Scrollbars
        y_scroll = ttk.Scrollbar(tree_frame, orient=tk.VERTICAL)
        y_scroll.pack(side=tk.RIGHT, fill=tk.Y)

        x_scroll = ttk.Scrollbar(tree_frame, orient=tk.HORIZONTAL)
        x_scroll.pack(side=tk.BOTTOM, fill=tk.X)

        # Treeview para las reglas
        self.rules_tree = ttk.Treeview(
            tree_frame,
            columns=("selected", "category", "name"),
            show="tree headings",
            yscrollcommand=y_scroll.set,
            xscrollcommand=x_scroll.set,
        )

        self.rules_tree.heading("#0", text="")
        self.rules_tree.heading("selected", text="Sel.")
        self.rules_tree.heading("category", text="Categoría")
        self.rules_tree.heading("name", text="Nombre de la Regla")

        self.rules_tree.column("#0", width=30)
        self.rules_tree.column("selected", width=50, anchor=tk.CENTER)
        self.rules_tree.column("category", width=150)
        self.rules_tree.column("name", width=400)

        self.rules_tree.pack(fill=tk.BOTH, expand=True)

        y_scroll.config(command=self.rules_tree.yview)
        x_scroll.config(command=self.rules_tree.xview)

        # Evento de clic para toggle de selección
        self.rules_tree.bind("<Button-1>", self.on_rule_click)
        self.rules_tree.bind("<space>", self.on_rule_space)

    def create_execution_tab(self):
        """Crea el contenido de la pestaña de ejecución"""
        # Frame de controles
        controls_frame = ttk.Frame(self.tab_execution)
        controls_frame.pack(fill=tk.X, pady=(0, 10))

        self.btn_execute = ttk.Button(controls_frame, text="Ejecutar Validación", command=self.execute_validation)
        self.btn_execute.pack(side=tk.LEFT, padx=5)

        self.btn_stop = ttk.Button(controls_frame, text="Detener", command=self.stop_execution, state=tk.DISABLED)
        self.btn_stop.pack(side=tk.LEFT, padx=5)

        ttk.Button(controls_frame, text="Limpiar Log", command=self.clear_log).pack(side=tk.LEFT, padx=5)

        # Barra de progreso
        progress_frame = ttk.Frame(self.tab_execution)
        progress_frame.pack(fill=tk.X, pady=(0, 10))

        self.progress_label = ttk.Label(progress_frame, text="Listo para ejecutar")
        self.progress_label.pack(anchor=tk.W)

        self.progress_bar = ttk.Progressbar(progress_frame, mode="determinate", length=400)
        self.progress_bar.pack(fill=tk.X, pady=5)

        self.progress_detail = ttk.Label(progress_frame, text="")
        self.progress_detail.pack(anchor=tk.W)

        # Área de log
        log_frame = ttk.LabelFrame(self.tab_execution, text="Log de Ejecución", padding="5")
        log_frame.pack(fill=tk.BOTH, expand=True)

        # Scrollbar para el log
        log_scroll = ttk.Scrollbar(log_frame)
        log_scroll.pack(side=tk.RIGHT, fill=tk.Y)

        self.log_text = tk.Text(log_frame, wrap=tk.WORD, yscrollcommand=log_scroll.set, font=("Consolas", 9))
        self.log_text.pack(fill=tk.BOTH, expand=True)
        log_scroll.config(command=self.log_text.yview)

        # Tags para colores en el log
        self.log_text.tag_configure("info", foreground="black")
        self.log_text.tag_configure("success", foreground="green")
        self.log_text.tag_configure("warning", foreground="orange")
        self.log_text.tag_configure("error", foreground="red")

    # ----------------------------- MÉTODOS DE CONFIGURACIÓN -----------------------------

    def browse_folder(self, entry_widget):
        """Abre el diálogo para seleccionar una carpeta"""
        folder = filedialog.askdirectory()
        if folder:
            entry_widget.delete(0, tk.END)
            entry_widget.insert(0, folder)

    def load_saved_config(self):
        """Carga la configuración guardada en los campos"""
        self.db_host.insert(0, self.config.get("db_host", ""))
        self.db_port.insert(0, self.config.get("db_port", ""))
        self.db_name.insert(0, self.config.get("db_name", ""))
        self.db_user.insert(0, self.config.get("db_user", ""))
        self.db_password.insert(0, self.config.get("db_password", ""))
        self.sql_folder.insert(0, self.config.get("sql_folder", ""))
        self.output_folder.insert(0, self.config.get("output_folder", ""))
        self.log_folder.insert(0, self.config.get("log_folder", ""))
        self.schemas.insert(0, self.config.get("schemas", ""))
        self.output_format.set(self.config.get("output_format", "excel"))

    def get_current_config(self):
        """Obtiene la configuración actual de los campos"""
        return {
            "db_host": self.db_host.get(),
            "db_port": self.db_port.get(),
            "db_name": self.db_name.get(),
            "db_user": self.db_user.get(),
            "db_password": self.db_password.get(),
            "sql_folder": self.sql_folder.get(),
            "output_folder": self.output_folder.get(),
            "log_folder": self.log_folder.get(),
            "schemas": self.schemas.get(),
            "output_format": self.output_format.get(),
        }

    def save_current_config(self):
        """Guarda la configuración actual"""
        config = self.get_current_config()
        save_config(config)
        messagebox.showinfo("Configuración", "Configuración guardada exitosamente.")

    def load_config_from_file(self):
        """Carga configuración desde archivo"""
        self.config = load_config()
        # Limpiar campos
        for entry in [
            self.db_host,
            self.db_port,
            self.db_name,
            self.db_user,
            self.db_password,
            self.sql_folder,
            self.output_folder,
            self.log_folder,
            self.schemas,
        ]:
            entry.delete(0, tk.END)
        self.load_saved_config()
        messagebox.showinfo("Configuración", "Configuración cargada exitosamente.")

    def reset_config(self):
        """Restaura los valores por defecto"""
        self.config = DEFAULT_CONFIG.copy()
        for entry in [
            self.db_host,
            self.db_port,
            self.db_name,
            self.db_user,
            self.db_password,
            self.sql_folder,
            self.output_folder,
            self.log_folder,
            self.schemas,
        ]:
            entry.delete(0, tk.END)
        self.load_saved_config()

    # ----------------------------- MÉTODOS DE CONEXIÓN -----------------------------

    def get_db_params(self):
        """Obtiene los parámetros de conexión a la BD"""
        return {
            "host": self.db_host.get(),
            "port": int(self.db_port.get()) if self.db_port.get() else 5432,
            "dbname": self.db_name.get(),
            "user": self.db_user.get(),
            "password": self.db_password.get(),
        }

    def test_connection(self):
        """Prueba la conexión a la base de datos"""
        try:
            params = self.get_db_params()
            success, message = test_connection(params)
            if success:
                self.conn_status.config(text="✓ Conexión exitosa", foreground="green")
            else:
                self.conn_status.config(text=f"✗ Error: {message[:50]}...", foreground="red")
        except Exception as e:
            self.conn_status.config(text=f"✗ Error: {str(e)[:50]}...", foreground="red")

    def load_schemas_from_db(self):
        """Carga los esquemas disponibles desde la BD"""
        try:
            params = self.get_db_params()
            schemas = get_schemas_from_db(params)
            if schemas:
                # Crear ventana de selección
                self.show_schema_selector(schemas)
            else:
                messagebox.showwarning("Esquemas", "No se encontraron esquemas o no se pudo conectar.")
        except Exception as e:
            messagebox.showerror("Error", f"Error al cargar esquemas: {e}")

    def show_schema_selector(self, schemas):
        """Muestra una ventana para seleccionar esquemas"""
        selector = tk.Toplevel(self.root)
        selector.title("Seleccionar Esquemas")
        selector.geometry("400x500")
        selector.transient(self.root)
        selector.grab_set()

        ttk.Label(selector, text="Seleccione los esquemas a analizar:").pack(pady=10)

        # Frame con scrollbar
        frame = ttk.Frame(selector)
        frame.pack(fill=tk.BOTH, expand=True, padx=10)

        scrollbar = ttk.Scrollbar(frame)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        listbox = tk.Listbox(frame, selectmode=tk.MULTIPLE, yscrollcommand=scrollbar.set)
        listbox.pack(fill=tk.BOTH, expand=True)
        scrollbar.config(command=listbox.yview)

        for schema in schemas:
            listbox.insert(tk.END, schema)

        def on_accept():
            selected = [listbox.get(i) for i in listbox.curselection()]
            self.schemas.delete(0, tk.END)
            self.schemas.insert(0, ", ".join(selected))
            selector.destroy()

        ttk.Button(selector, text="Aceptar", command=on_accept).pack(pady=10)

    # ----------------------------- MÉTODOS DE REGLAS -----------------------------

    def load_rules(self):
        """Carga las reglas desde la carpeta especificada"""
        folder = self.sql_folder.get()
        if not folder or not os.path.exists(folder):
            messagebox.showwarning("Advertencia", "Por favor, especifique una carpeta de reglas válida.")
            return

        # Limpiar árbol
        for item in self.rules_tree.get_children():
            self.rules_tree.delete(item)
        self.selected_queries.clear()

        # Cargar estructura
        structure = get_query_tree_structure(folder)

        # Agrupar por categoría
        categories = {}
        for category, name, path in structure:
            if category not in categories:
                categories[category] = []
            categories[category].append((name, path))

        # Insertar en el árbol
        for category in sorted(categories.keys()):
            for name, path in sorted(categories[category]):
                item_id = self.rules_tree.insert("", tk.END, values=("☐", category, name))
                self.selected_queries[item_id] = {"selected": False, "category": category, "name": name, "path": path}

        self.update_rules_count()

    def on_rule_click(self, event):
        """Maneja el clic en una regla para toggle de selección"""
        region = self.rules_tree.identify("region", event.x, event.y)
        if region == "cell":
            column = self.rules_tree.identify_column(event.x)
            item = self.rules_tree.identify_row(event.y)
            if item and column == "#1":  # Columna de selección
                self.toggle_rule_selection(item)

    def on_rule_space(self, event):
        """Maneja la tecla espacio para toggle de selección"""
        selected = self.rules_tree.selection()
        for item in selected:
            self.toggle_rule_selection(item)

    def toggle_rule_selection(self, item):
        """Alterna la selección de una regla"""
        if item in self.selected_queries:
            current = self.selected_queries[item]["selected"]
            self.selected_queries[item]["selected"] = not current
            new_check = "☑" if not current else "☐"
            values = self.rules_tree.item(item, "values")
            self.rules_tree.item(item, values=(new_check, values[1], values[2]))
            self.update_rules_count()

    def select_all_rules(self):
        """Selecciona todas las reglas"""
        for item in self.selected_queries:
            self.selected_queries[item]["selected"] = True
            values = self.rules_tree.item(item, "values")
            self.rules_tree.item(item, values=("☑", values[1], values[2]))
        self.update_rules_count()

    def deselect_all_rules(self):
        """Deselecciona todas las reglas"""
        for item in self.selected_queries:
            self.selected_queries[item]["selected"] = False
            values = self.rules_tree.item(item, "values")
            self.rules_tree.item(item, values=("☐", values[1], values[2]))
        self.update_rules_count()

    def update_rules_count(self):
        """Actualiza el contador de reglas"""
        total = len(self.selected_queries)
        selected = sum(1 for q in self.selected_queries.values() if q["selected"])
        self.rules_count_label.config(text=f"Reglas cargadas: {total} | Seleccionadas: {selected}")

    def get_selected_queries(self):
        """Obtiene las consultas seleccionadas"""
        queries = {}
        for item, data in self.selected_queries.items():
            if data["selected"]:
                with open(data["path"], "r", encoding="utf-8") as f:
                    queries[data["name"]] = f.read()
        return queries

    # ----------------------------- MÉTODOS DE EJECUCIÓN -----------------------------

    def log_message(self, message, level="info"):
        """Añade un mensaje a la cola del log"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        self.log_queue.put((f"[{timestamp}] {message}", level))

    def check_log_queue(self):
        """Verifica la cola del log y actualiza la interfaz"""
        try:
            while True:
                message, level = self.log_queue.get_nowait()
                self.log_text.insert(tk.END, message + "\n", level)
                self.log_text.see(tk.END)
        except queue.Empty:
            pass
        self.root.after(100, self.check_log_queue)

    def clear_log(self):
        """Limpia el área de log"""
        self.log_text.delete(1.0, tk.END)

    def update_progress(self, current, total, message=""):
        """Actualiza la barra de progreso"""
        self.progress_bar["value"] = (current / total) * 100 if total > 0 else 0
        self.progress_detail.config(text=message)
        self.root.update_idletasks()

    def execute_validation(self):
        """Inicia la ejecución de la validación"""
        # Validaciones
        if not self.schemas.get().strip():
            messagebox.showwarning("Advertencia", "Por favor, especifique al menos un esquema.")
            return

        selected_queries = self.get_selected_queries()
        if not selected_queries:
            messagebox.showwarning("Advertencia", "Por favor, seleccione al menos una regla.")
            return

        # Cambiar estado de botones
        self.is_running = True
        self.btn_execute.config(state=tk.DISABLED)
        self.btn_stop.config(state=tk.NORMAL)

        # Ejecutar en hilo separado
        thread = threading.Thread(target=self.run_validation_thread, args=(selected_queries,))
        thread.daemon = True
        thread.start()

    def stop_execution(self):
        """Detiene la ejecución"""
        self.is_running = False
        self.log_message("Deteniendo ejecución...", "warning")

    def run_validation_thread(self, queries):
        """Ejecuta la validación en un hilo separado"""
        try:
            timestamp = datetime.now().strftime("%d%m%Y_%H%M%S")
            config = self.get_current_config()

            # Configurar logging a archivo
            log_folder = config["log_folder"] or "."
            log_file = os.path.join(log_folder, f"log_{timestamp}.txt")

            file_handler = logging.FileHandler(log_file, encoding="utf-8")
            file_handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))

            logger = logging.getLogger(f"reportes_{timestamp}")
            logger.setLevel(logging.INFO)
            logger.addHandler(file_handler)

            self.log_message(f"Iniciando validación - Log: {log_file}", "info")
            logger.info("Iniciando proceso de validación")

            # Conectar a BD
            self.log_message("Conectando a la base de datos...", "info")
            self.root.after(0, lambda: self.progress_label.config(text="Conectando a la base de datos..."))

            params = self.get_db_params()
            conn_string = create_connection_string(params)
            engine = create_engine(conn_string)

            # Verificar conexión
            with engine.connect() as test_conn:
                test_conn.execute(text("SELECT 1"))

            self.log_message("Conexión exitosa", "success")
            logger.info("Conexión exitosa a la base de datos")

            # Obtener esquemas
            schemas = [s.strip() for s in config["schemas"].split(",") if s.strip()]

            # Calcular total de operaciones
            total_ops = len(schemas) * len(queries)
            current_op = 0

            # Ejecutar consultas por esquema
            results_by_schema = {}

            for schema in schemas:
                if not self.is_running:
                    break

                self.log_message(f"Procesando esquema: {schema}", "info")
                logger.info(f"Procesando esquema: {schema}")
                schema_results = {}

                for query_name, query_template in queries.items():
                    if not self.is_running:
                        break

                    current_op += 1
                    progress_msg = f"Esquema: {schema} | Regla: {query_name} ({current_op}/{total_ops})"
                    self.root.after(0, lambda m=progress_msg: self.progress_label.config(text=m))
                    self.root.after(0, lambda c=current_op, t=total_ops: self.update_progress(c, t, ""))

                    try:
                        # Usar conexión con search_path configurado
                        with engine.connect() as conn:
                            # Establecer search_path (nombre sanitizado)
                            safe_schema = validate_identifier(schema)
                            conn.execute(text(f"SET search_path TO {safe_schema}, public"))
                            conn.commit()
                            # Ejecutar la consulta usando la conexión raw de DBAPI
                            df = pd.read_sql(query_template, conn.connection)
                        schema_results[query_name] = df
                        self.log_message(f"  ✓ {query_name}: {len(df)} registros", "success")
                        logger.info(f"Consulta '{query_name}' ejecutada: {len(df)} registros")
                    except Exception as e:
                        self.log_message(f"  ✗ {query_name}: Error - {str(e)[:100]}", "error")
                        logger.error(f"Error en consulta '{query_name}': {e}")
                        schema_results[query_name] = pd.DataFrame()

                results_by_schema[schema] = schema_results

            engine.dispose()

            if self.is_running:
                # Exportar resultados
                self.log_message("Exportando resultados...", "info")
                output_folder = config["output_folder"] or "."
                output_format = config["output_format"]

                self.export_results(results_by_schema, output_folder, output_format, timestamp, logger)

                self.log_message("Proceso completado exitosamente", "success")
                logger.info("Proceso finalizado correctamente")
            else:
                self.log_message("Proceso detenido por el usuario", "warning")
                logger.warning("Proceso detenido por el usuario")

        except Exception as e:
            self.log_message(f"Error durante la ejecución: {e}", "error")
            logger.error(f"Error durante la ejecución: {e}")
        finally:
            self.is_running = False
            self.root.after(0, lambda: self.btn_execute.config(state=tk.NORMAL))
            self.root.after(0, lambda: self.btn_stop.config(state=tk.DISABLED))
            self.root.after(0, lambda: self.progress_label.config(text="Finalizado"))

    def export_results(self, results_by_schema, output_folder, output_format, timestamp, logger):
        """Exporta los resultados según el formato especificado"""
        if output_format in ["excel", "both"]:
            self.export_to_excel(results_by_schema, output_folder, timestamp, logger)

        if output_format in ["csv", "both"]:
            self.export_to_csv(results_by_schema, output_folder, timestamp, logger)

    def export_to_excel(self, results_by_schema, output_folder, timestamp, logger):
        """Exporta a formato Excel"""
        for schema, queries_dict in results_by_schema.items():
            excel_name = os.path.join(output_folder, f"reporte_{schema}_{timestamp}.xlsx")
            writer = pd.ExcelWriter(excel_name, engine="xlsxwriter")
            summary_data = []

            for sheet_name, df in queries_dict.items():
                # Eliminar timezone si existe
                for col in df.select_dtypes(include=["datetimetz"]).columns:
                    df[col] = df[col].dt.tz_localize(None)

                # Truncar nombre de hoja a 31 caracteres (límite de Excel)
                safe_sheet_name = sheet_name[:31]
                df.to_excel(writer, sheet_name=safe_sheet_name, index=False)
                summary_data.append({"Consulta": sheet_name, "Registros encontrados": len(df)})

            # Hoja resumen
            summary_df = pd.DataFrame(summary_data)
            summary_df.to_excel(writer, sheet_name="Resumen", index=False)

            writer.close()
            self.log_message(f"Archivo Excel generado: {excel_name}", "success")
            logger.info(f"Archivo Excel generado: {excel_name}")

    def export_to_csv(self, results_by_schema, output_folder, timestamp, logger):
        """Exporta a formato CSV"""
        for schema, queries_dict in results_by_schema.items():
            for query_name, df in queries_dict.items():
                if df.empty:
                    continue

                # Eliminar timezone si existe
                for col in df.select_dtypes(include=["datetimetz"]).columns:
                    df[col] = df[col].dt.tz_localize(None)

                csv_name = os.path.join(output_folder, f"reporte_{schema}_{query_name}_{timestamp}.csv")
                df.to_csv(csv_name, index=False, sep=";", encoding="utf-8")

                self.log_message(f"Archivo CSV generado: {csv_name}", "success")
                logger.info(f"Archivo CSV generado: {csv_name}")


# ----------------------------- PUNTO DE ENTRADA -----------------------------


def main():
    root = tk.Tk()
    app = ReportesApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
