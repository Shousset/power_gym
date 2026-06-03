"""Power Gym - Aplicacion Tkinter minima para interactuar con la BD Oracle.

Ejecucion:
    cd app
    python main.py

Pre-requisitos:
    1. Oracle 18c (o XE) corriendo en localhost:1521.
    2. Haber ejecutado sql/DDL.sql, sql/DATOS.sql, sql/usuarios.sql.
    3. pip install -r ../requirements.txt
"""

import tkinter as tk
from tkinter import ttk, messagebox
import oracledb

from config import PERFILES
from db import conectar


class PowerGymApp:
    def __init__(self):
        self.conn = None
        self.perfil = None

        self.root = tk.Tk()
        self.root.title("Power Gym")
        self.root.geometry("950x600")
        # Cualquier excepcion no controlada dentro de un callback de Tk se
        # mostrara en un dialogo en lugar de propagarse y tumbar el mainloop.
        self.root.report_callback_exception = self._reportar_error_callback
        self._mostrar_login()
        self.root.mainloop()

    def _reportar_error_callback(self, exc, val, tb):
        messagebox.showerror("Error inesperado", f"{exc.__name__}: {val}")

    # ------------------------------------------------------------------ Login
    def _mostrar_login(self):
        for w in self.root.winfo_children():
            w.destroy()

        contenedor = ttk.Frame(self.root, padding=40)
        contenedor.place(relx=0.5, rely=0.5, anchor="center")

        ttk.Label(contenedor, text="POWER GYM", font=("Arial", 26, "bold")).grid(
            row=0, column=0, columnspan=2, pady=(0, 10)
        )
        ttk.Label(contenedor, text="Sistema de gestion", font=("Arial", 10, "italic")).grid(
            row=1, column=0, columnspan=2, pady=(0, 25)
        )

        ttk.Label(contenedor, text="Perfil:").grid(row=2, column=0, sticky="w", pady=6)
        self.perfil_var = tk.StringVar(value="RECEPCIONISTA")
        ttk.Combobox(
            contenedor,
            textvariable=self.perfil_var,
            values=list(PERFILES.keys()),
            state="readonly",
            width=25,
        ).grid(row=2, column=1, pady=6)

        ttk.Label(contenedor, text="Password:").grid(row=3, column=0, sticky="w", pady=6)
        self.pwd_var = tk.StringVar(value="")
        ttk.Entry(contenedor, textvariable=self.pwd_var, show="*", width=27).grid(
            row=3, column=1, pady=6
        )

        ttk.Button(contenedor, text="Ingresar", command=self._intentar_login, width=20).grid(
            row=4, column=0, columnspan=2, pady=25
        )

        ttk.Label(
            contenedor,
            text="(Si dejas el password vacio se usara el de config.py)",
            font=("Arial", 8),
            foreground="gray",
        ).grid(row=5, column=0, columnspan=2)

    def _intentar_login(self):
        perfil = self.perfil_var.get()
        creds = PERFILES[perfil]
        password = self.pwd_var.get() or creds["password_bd"]
        try:
            self.conn = conectar(creds["usuario_bd"], password)
            self.perfil = perfil
            self._mostrar_principal()
        except Exception as e:
            messagebox.showerror("Error de login", f"No se pudo conectar a Oracle:\n\n{e}")

    # -------------------------------------------------------------- Principal
    def _mostrar_principal(self):
        for w in self.root.winfo_children():
            w.destroy()

        topbar = ttk.Frame(self.root, padding=10)
        topbar.pack(fill="x")
        ttk.Label(
            topbar,
            text=f"Perfil conectado:  {self.perfil}",
            font=("Arial", 11, "bold"),
        ).pack(side="left")
        ttk.Button(topbar, text="Cerrar sesion", command=self._logout).pack(side="right")

        notebook = ttk.Notebook(self.root)
        notebook.pack(fill="both", expand=True, padx=10, pady=10)

        if self.perfil == "RECEPCIONISTA":
            self._tab_clientes(notebook)
            self._tab_membresias(notebook)
            self._tab_pagos(notebook)
        else:
            self._tab_clases(notebook)
            self._tab_inscritos(notebook)

    def _logout(self):
        if self.conn:
            try:
                self.conn.close()
            except oracledb.Error:
                pass
        self.conn = None
        self.perfil = None
        self._mostrar_login()

    # ----------------------------------------------- Tab Clientes (Recepcion)
    def _tab_clientes(self, notebook):
        frame = ttk.Frame(notebook, padding=10)
        notebook.add(frame, text="Clientes")

        botones = ttk.Frame(frame)
        botones.pack(fill="x", pady=(0, 10))
        ttk.Button(botones, text="Refrescar", command=lambda: self._cargar_clientes(tree)).pack(side="left", padx=2)
        ttk.Button(botones, text="Nuevo",     command=lambda: self._form_cliente(tree)).pack(side="left", padx=2)
        ttk.Button(botones, text="Editar",    command=lambda: self._form_cliente(tree, editar=True)).pack(side="left", padx=2)
        ttk.Button(botones, text="Eliminar",  command=lambda: self._eliminar_cliente(tree)).pack(side="left", padx=2)

        columnas = ("id", "cedula", "nombre", "apellido", "telefono", "correo")
        anchos = (50, 110, 130, 130, 110, 220)
        tree = ttk.Treeview(frame, columns=columnas, show="headings", height=18)
        for col, ancho in zip(columnas, anchos):
            tree.heading(col, text=col.capitalize())
            tree.column(col, width=ancho, anchor="w")
        tree.pack(fill="both", expand=True)

        self._cargar_clientes(tree)

    def _cargar_clientes(self, tree):
        for row in tree.get_children():
            tree.delete(row)
        cur = self.conn.cursor()
        cur.execute(
            """
            SELECT id_cliente, cedula, nombre, apellido, telefono, correo
            FROM   cliente
            ORDER BY id_cliente
            """
        )
        for fila in cur.fetchall():
            tree.insert("", "end", values=fila)
        cur.close()

    def _form_cliente(self, tree, editar=False):
        valores = None
        if editar:
            sel = tree.selection()
            if not sel:
                messagebox.showwarning("Aviso", "Selecciona un cliente para editar.")
                return
            valores = tree.item(sel[0])["values"]

        win = tk.Toplevel(self.root)
        win.title("Editar cliente" if editar else "Nuevo cliente")
        win.geometry("420x440")
        win.transient(self.root)
        win.grab_set()

        campos = [
            ("Cedula",                       "cedula"),
            ("Nombre",                       "nombre"),
            ("Apellido",                     "apellido"),
            ("Fecha nacimiento (YYYY-MM-DD)","fecha_nacimiento"),
            ("Telefono (10 digitos)",        "telefono"),
            ("Correo",                       "correo"),
            ("Direccion",                    "direccion"),
            ("Contacto emergencia",          "contacto_emergencia"),
            ("Telefono emergencia",          "telefono_emergencia"),
        ]
        entries = {}
        for i, (etiqueta, key) in enumerate(campos):
            ttk.Label(win, text=etiqueta).grid(row=i, column=0, sticky="w", padx=10, pady=3)
            e = ttk.Entry(win, width=30)
            e.grid(row=i, column=1, padx=10, pady=3)
            entries[key] = e

        if editar:
            cur = self.conn.cursor()
            cur.execute(
                """
                SELECT cedula, nombre, apellido, TO_CHAR(fecha_nacimiento,'YYYY-MM-DD'),
                       telefono, correo, direccion, contacto_emergencia, telefono_emergencia
                FROM   cliente WHERE id_cliente = :id
                """,
                id=valores[0],
            )
            datos = cur.fetchone()
            cur.close()
            for (_, key), val in zip(campos, datos):
                entries[key].insert(0, val or "")

        def guardar():
            try:
                vals = {k: (e.get().strip() or None) for k, e in entries.items()}
                cur = self.conn.cursor()
                if editar:
                    cur.execute(
                        """
                        UPDATE cliente
                        SET    cedula = :cedula,
                               nombre = :nombre,
                               apellido = :apellido,
                               fecha_nacimiento = TO_DATE(:fecha_nacimiento,'YYYY-MM-DD'),
                               telefono = :telefono,
                               correo = :correo,
                               direccion = :direccion,
                               contacto_emergencia = :contacto_emergencia,
                               telefono_emergencia = :telefono_emergencia
                        WHERE  id_cliente = :id
                        """,
                        id=valores[0],
                        **vals,
                    )
                else:
                    cur.execute(
                        """
                        INSERT INTO cliente (
                            id_cliente, cedula, nombre, apellido, fecha_nacimiento,
                            telefono, correo, direccion, contacto_emergencia,
                            telefono_emergencia, fecha_registro
                        ) VALUES (
                            seq_cliente.NEXTVAL, :cedula, :nombre, :apellido,
                            TO_DATE(:fecha_nacimiento,'YYYY-MM-DD'),
                            :telefono, :correo, :direccion,
                            :contacto_emergencia, :telefono_emergencia, SYSDATE
                        )
                        """,
                        **vals,
                    )
                self.conn.commit()
                cur.close()
                win.destroy()
                self._cargar_clientes(tree)
                messagebox.showinfo("OK", "Cliente guardado correctamente.")
            except oracledb.Error as e:
                messagebox.showerror("Error", str(e))

        ttk.Button(win, text="Guardar", command=guardar, width=20).grid(
            row=len(campos), column=0, columnspan=2, pady=15
        )

    def _eliminar_cliente(self, tree):
        sel = tree.selection()
        if not sel:
            messagebox.showwarning("Aviso", "Selecciona un cliente.")
            return
        valores = tree.item(sel[0])["values"]
        if not messagebox.askyesno(
            "Confirmar", f"Eliminar al cliente {valores[2]} {valores[3]}?"
        ):
            return
        try:
            cur = self.conn.cursor()
            cur.execute("DELETE FROM cliente WHERE id_cliente = :id", id=valores[0])
            self.conn.commit()
            cur.close()
            self._cargar_clientes(tree)
        except oracledb.Error as e:
            messagebox.showerror("Error", str(e))

    # --------------------------------------------------------- Tab Membresias
    def _tab_membresias(self, notebook):
        frame = ttk.Frame(notebook, padding=10)
        notebook.add(frame, text="Membresias activas")

        columnas = ("cliente", "plan", "inicio", "vencimiento", "estado")
        tree = ttk.Treeview(frame, columns=columnas, show="headings", height=18)
        for col, ancho in zip(columnas, (220, 130, 110, 130, 100)):
            tree.heading(col, text=col.capitalize())
            tree.column(col, width=ancho, anchor="w")
        tree.pack(fill="both", expand=True)

        cur = self.conn.cursor()
        cur.execute(
            """
            SELECT c.nombre || ' ' || c.apellido,
                   p.nombre,
                   TO_CHAR(m.fecha_inicio, 'YYYY-MM-DD'),
                   TO_CHAR(m.fecha_vencimiento, 'YYYY-MM-DD'),
                   m.estado
            FROM   membresia m
            INNER JOIN cliente c ON m.id_cliente = c.id_cliente
            INNER JOIN plan    p ON m.id_plan    = p.id_plan
            WHERE  m.estado = 'ACTIVA'
            ORDER BY m.fecha_vencimiento
            """
        )
        for fila in cur.fetchall():
            tree.insert("", "end", values=fila)
        cur.close()

    # -------------------------------------------------------------- Tab Pagos
    def _tab_pagos(self, notebook):
        frame = ttk.Frame(notebook, padding=10)
        notebook.add(frame, text="Pagos del mes")

        columnas = ("fecha", "cliente", "monto", "metodo")
        tree = ttk.Treeview(frame, columns=columnas, show="headings", height=18)
        for col, ancho in zip(columnas, (110, 240, 110, 130)):
            tree.heading(col, text=col.capitalize())
            tree.column(col, width=ancho, anchor="w")
        tree.pack(fill="both", expand=True)

        cur = self.conn.cursor()
        cur.execute(
            """
            SELECT TO_CHAR(pg.fecha_pago, 'YYYY-MM-DD'),
                   c.nombre || ' ' || c.apellido,
                   pg.monto,
                   pg.metodo_pago
            FROM   pago pg
            INNER JOIN membresia m ON pg.id_membresia = m.id_membresia
            INNER JOIN cliente   c ON m.id_cliente    = c.id_cliente
            WHERE  pg.fecha_pago >= TRUNC(SYSDATE, 'MM')
            ORDER BY pg.fecha_pago DESC
            """
        )
        for fila in cur.fetchall():
            tree.insert("", "end", values=fila)
        cur.close()

    # ----------------------------------------------- Tab Clases (Entrenador)
    def _tab_clases(self, notebook):
        frame = ttk.Frame(notebook, padding=10)
        notebook.add(frame, text="Cronograma de clases")

        columnas = ("id", "nombre", "dia", "inicio", "fin", "cupo")
        tree = ttk.Treeview(frame, columns=columnas, show="headings", height=18)
        for col, ancho in zip(columnas, (50, 180, 110, 80, 80, 60)):
            tree.heading(col, text=col.capitalize())
            tree.column(col, width=ancho, anchor="w")
        tree.pack(fill="both", expand=True)

        cur = self.conn.cursor()
        cur.execute(
            """
            SELECT id_clase, nombre, dia_semana, hora_inicio, hora_fin, cupo_maximo
            FROM   clase
            ORDER BY DECODE(dia_semana,
                            'LUNES',1,'MARTES',2,'MIERCOLES',3,'JUEVES',4,
                            'VIERNES',5,'SABADO',6,'DOMINGO',7),
                     hora_inicio
            """
        )
        for fila in cur.fetchall():
            tree.insert("", "end", values=fila)
        cur.close()

    # ----------------------------------------------- Tab Inscritos por clase
    def _tab_inscritos(self, notebook):
        frame = ttk.Frame(notebook, padding=10)
        notebook.add(frame, text="Inscritos por clase")

        seleccion = ttk.Frame(frame)
        seleccion.pack(fill="x", pady=(0, 10))

        ttk.Label(seleccion, text="Clase:").pack(side="left", padx=(0, 5))

        cur = self.conn.cursor()
        cur.execute("SELECT id_clase, nombre || ' (' || dia_semana || ')' FROM clase ORDER BY id_clase")
        clases = cur.fetchall()
        cur.close()
        mapa = {f"{nombre} [id={cid}]": cid for cid, nombre in clases}

        clase_var = tk.StringVar()
        combo = ttk.Combobox(
            seleccion,
            textvariable=clase_var,
            values=list(mapa.keys()),
            state="readonly",
            width=40,
        )
        combo.pack(side="left")

        columnas = ("cedula", "cliente", "estado", "inscripcion")
        tree = ttk.Treeview(frame, columns=columnas, show="headings", height=15)
        for col, ancho in zip(columnas, (120, 240, 110, 130)):
            tree.heading(col, text=col.capitalize())
            tree.column(col, width=ancho, anchor="w")
        tree.pack(fill="both", expand=True)

        def cargar():
            for row in tree.get_children():
                tree.delete(row)
            seleccion_val = clase_var.get()
            if not seleccion_val:
                return
            id_clase = mapa[seleccion_val]
            cur = self.conn.cursor()
            cur.execute(
                """
                SELECT c.cedula,
                       c.nombre || ' ' || c.apellido,
                       i.estado,
                       TO_CHAR(i.fecha_inscripcion, 'YYYY-MM-DD')
                FROM   inscripcion i
                INNER JOIN cliente c ON i.id_cliente = c.id_cliente
                WHERE  i.id_clase = :id
                ORDER BY i.estado, c.apellido
                """,
                id=id_clase,
            )
            for fila in cur.fetchall():
                tree.insert("", "end", values=fila)
            cur.close()

        ttk.Button(seleccion, text="Cargar inscritos", command=cargar).pack(side="left", padx=10)

        def registrar_asistencia():
            sel = tree.selection()
            if not sel or not clase_var.get():
                messagebox.showwarning("Aviso", "Selecciona una clase y un inscrito.")
                return
            cedula = tree.item(sel[0])["values"][0]
            id_clase = mapa[clase_var.get()]
            try:
                cur = self.conn.cursor()
                cur.execute(
                    """
                    INSERT INTO asistencia (id_asistencia, id_cliente, id_clase, fecha_asistencia, hora_entrada)
                    SELECT seq_asistencia.NEXTVAL, c.id_cliente, :id_clase, SYSDATE,
                           TO_CHAR(SYSDATE, 'HH24:MI')
                    FROM   cliente c WHERE c.cedula = :cedula
                    """,
                    id_clase=id_clase,
                    cedula=cedula,
                )
                self.conn.commit()
                cur.close()
                messagebox.showinfo("OK", "Asistencia registrada.")
            except oracledb.Error as e:
                messagebox.showerror("Error", str(e))

        ttk.Button(seleccion, text="Registrar asistencia del seleccionado", command=registrar_asistencia).pack(side="left", padx=10)


if __name__ == "__main__":
    PowerGymApp()
