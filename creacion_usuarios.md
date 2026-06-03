# Power Gym — Creación de Usuarios y Roles en SQL*Plus

**Proyecto:** Power Gym
**Motor:** Oracle 18c (compatible 11g/12c/19c/21c)
**Herramienta:** SQL*Plus
**Autor:** Samuel Benavides Housset

---

## 1. Esquema general de seguridad

El sistema define **tres niveles de acceso** mediante **roles** de Oracle. Un rol es un conjunto nombrado de privilegios que se asigna a uno o varios usuarios. Si más adelante se necesita ajustar un permiso, basta con modificar el rol y todos los usuarios que lo tengan asignado heredan el cambio.

| Nivel | Rol | Usuario asociado | Responsabilidad |
|-------|-----|------------------|-----------------|
| 1 | `c##rol_admin_powergym` | `c##powergym` (propietario del esquema) | Crear tablas, secuencias, triggers, vistas, otorgar permisos, hacer respaldos. |
| 2 | `rol_recepcion` | `user_recepcion` | Gestión de clientes, membresías, pagos, inscripciones y asistencias. |
| 3 | `rol_entrenador` | `user_entrenador` | Consulta de inscritos y registro de asistencia a sus clases. |

> El usuario `c##powergym` funciona como **propietario del esquema** y administrador funcional. No se usa el `SYS` ni el `SYSTEM` para operar el sistema diariamente; esos quedan reservados para el DBA de la instancia.

---

## 2. Pre-requisitos

- Tener instancia Oracle 18c levantada y accesible.
- Conocer la contraseña del usuario `SYSTEM` (o de un usuario con privilegio `DBA`).
- En Oracle 12c+ es necesario crear nombres de usuario con prefijo `C##` si se trabaja en el **container root (CDB)**. Para evitarlo, conectarse al **pluggable database (PDB)** correspondiente, p. ej. `XEPDB1`:

  ```
  sqlplus system/<clave>@localhost:1521/XEPDB1
  ```

---

## 3. Paso 1 — Crear el esquema administrador (`c##powergym`)

Este usuario será el **dueño de todas las tablas, triggers y secuencias**. Se conecta a él para ejecutar `DDL.sql` y `DATOS.sql`.

```sql
-- Conectarse como SYSTEM
CONNECT system/<clave_system>@XEPDB1;

-- Limpieza previa (si ya existe)
DROP USER c##powergym CASCADE;

-- Crear usuario administrador del esquema
CREATE USER c##powergym IDENTIFIED BY "Admin_2026!"
    DEFAULT TABLESPACE   users
    TEMPORARY TABLESPACE temp
    QUOTA UNLIMITED ON   users;

-- Crear el rol de administrador del sistema Power Gym
CREATE ROLE c##rol_admin_powergym;

-- Privilegios de sistema para el rol administrador
GRANT CREATE SESSION       TO c##rol_admin_powergym;
GRANT CREATE TABLE         TO c##rol_admin_powergym;
GRANT CREATE SEQUENCE      TO c##rol_admin_powergym;
GRANT CREATE VIEW          TO c##rol_admin_powergym;
GRANT CREATE TRIGGER       TO c##rol_admin_powergym;
GRANT CREATE PROCEDURE     TO c##rol_admin_powergym;
GRANT CREATE SYNONYM       TO c##rol_admin_powergym;
GRANT CREATE PUBLIC SYNONYM TO c##rol_admin_powergym;

-- Asignar el rol al usuario administrador
GRANT c##rol_admin_powergym TO c##powergym;

-- Permitir que c##powergym otorgue privilegios sobre SUS objetos
GRANT GRANT ANY OBJECT PRIVILEGE TO c##powergym;
```

Verificación:

```sql
SELECT username, account_status FROM dba_users WHERE username = 'POWERGYM';
SELECT granted_role             FROM dba_role_privs WHERE grantee = 'POWERGYM';
```

---

## 4. Paso 2 — Construir la base de datos

Conectarse como el nuevo administrador y ejecutar los scripts del proyecto.

```sql
CONNECT c##powergym/Admin_2026!@XEPDB1;

@C:\...\proyect_power_gym\sql\DDL.sql
@C:\...\proyect_power_gym\sql\DATOS.sql
```

Verificar conteo de filas:

```sql
SELECT 'CLIENTE'  AS tabla, COUNT(*) FROM cliente
UNION ALL SELECT 'MEMBRESIA', COUNT(*) FROM membresia
UNION ALL SELECT 'PAGO',      COUNT(*) FROM pago;
```

---

## 5. Paso 3 — Crear el rol de Recepcionista

Permisos: gestión completa de clientes, membresías, pagos, inscripciones y asistencias. **Solo lectura** sobre planes, clases y entrenadores (sin ver salario).

```sql
-- Re-conectarse como SYSTEM para crear el rol
CONNECT system/<clave_system>@XEPDB1;

DROP ROLE rol_recepcion;
CREATE ROLE rol_recepcion;

-- Privilegio de sistema (poder conectarse)
GRANT CREATE SESSION TO rol_recepcion;

-- Permisos sobre objetos del esquema POWERGYM
GRANT SELECT, INSERT, UPDATE, DELETE ON c##powergym.cliente     TO rol_recepcion;
GRANT SELECT, INSERT, UPDATE         ON c##powergym.membresia   TO rol_recepcion;
GRANT SELECT, INSERT                 ON c##powergym.pago        TO rol_recepcion;
GRANT SELECT, INSERT, UPDATE         ON c##powergym.inscripcion TO rol_recepcion;
GRANT SELECT, INSERT                 ON c##powergym.asistencia  TO rol_recepcion;
GRANT SELECT                         ON c##powergym.plan        TO rol_recepcion;
GRANT SELECT                         ON c##powergym.clase       TO rol_recepcion;

-- Vista publica del entrenador (sin salario) — creada en usuarios.sql
GRANT SELECT ON c##powergym.v_entrenador_publico TO rol_recepcion;

-- Secuencias necesarias para insertar
GRANT SELECT ON c##powergym.seq_cliente     TO rol_recepcion;
GRANT SELECT ON c##powergym.seq_membresia   TO rol_recepcion;
GRANT SELECT ON c##powergym.seq_pago        TO rol_recepcion;
GRANT SELECT ON c##powergym.seq_inscripcion TO rol_recepcion;
GRANT SELECT ON c##powergym.seq_asistencia  TO rol_recepcion;
```

**Restricciones explícitas** (lo que el rol NO puede hacer):

| Acción | Tabla | Razón |
|--------|-------|-------|
| INSERT/UPDATE/DELETE | `plan` | El catálogo lo administra el dueño del sistema. |
| INSERT/UPDATE/DELETE | `entrenador` | RR.HH. del gimnasio. |
| SELECT directo | `entrenador.salario` | Información confidencial; accede vía vista. |
| DELETE | `pago`, `membresia`, `asistencia` | Política de no borrado físico (auditoría). |

---

## 6. Paso 4 — Crear el rol de Entrenador

Permisos: consulta de inscritos a sus clases y registro de asistencia. Sin acceso a pagos, membresías ni datos personales sensibles.

```sql
DROP ROLE rol_entrenador;
CREATE ROLE rol_entrenador;

GRANT CREATE SESSION TO rol_entrenador;

-- Solo lectura sobre datos básicos del cliente
GRANT SELECT ON c##powergym.cliente     TO rol_entrenador;

-- Consultar el cronograma y los inscritos
GRANT SELECT ON c##powergym.clase       TO rol_entrenador;
GRANT SELECT ON c##powergym.inscripcion TO rol_entrenador;

-- Registrar asistencia (no editar ni borrar)
GRANT SELECT, INSERT ON c##powergym.asistencia TO rol_entrenador;

-- Información publica de entrenadores (sin salario)
GRANT SELECT ON c##powergym.v_entrenador_publico TO rol_entrenador;

-- Secuencia para registrar asistencias
GRANT SELECT ON c##powergym.seq_asistencia TO rol_entrenador;
```

**Restricciones explícitas:**

| Acción | Tabla | Razón |
|--------|-------|-------|
| INSERT/UPDATE/DELETE | `cliente`, `membresia`, `pago`, `plan` | Funciones administrativas, no operativas. |
| UPDATE/DELETE | `asistencia` | Inmutabilidad del registro de asistencia (RN). |
| SELECT directo | `entrenador.salario` | Confidencial. |

---

## 7. Paso 5 — Crear los usuarios y asignarles los roles

```sql
-- USUARIO RECEPCION ----------------------------------------------------------
DROP USER user_recepcion CASCADE;

CREATE USER user_recepcion IDENTIFIED BY "Recep_2026!"
    DEFAULT TABLESPACE   users
    TEMPORARY TABLESPACE temp
    QUOTA 0 ON           users;        -- no necesita crear objetos propios

GRANT rol_recepcion TO user_recepcion;
ALTER USER user_recepcion DEFAULT ROLE rol_recepcion;

-- USUARIO ENTRENADOR ---------------------------------------------------------
DROP USER user_entrenador CASCADE;

CREATE USER user_entrenador IDENTIFIED BY "Entren_2026!"
    DEFAULT TABLESPACE   users
    TEMPORARY TABLESPACE temp
    QUOTA 0 ON           users;

GRANT rol_entrenador TO user_entrenador;
ALTER USER user_entrenador DEFAULT ROLE rol_entrenador;
```

**Política de contraseñas (opcional, recomendada):**

```sql
-- Forzar cambio en el primer login
ALTER USER user_recepcion  PASSWORD EXPIRE;
ALTER USER user_entrenador PASSWORD EXPIRE;

-- Aplicar perfil con caducidad de 60 dias
CREATE PROFILE perfil_powergym LIMIT
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LIFE_TIME    60
    PASSWORD_LOCK_TIME    1;

ALTER USER user_recepcion  PROFILE perfil_powergym;
ALTER USER user_entrenador PROFILE perfil_powergym;
```

---

## 8. Paso 6 — Verificación en SQL*Plus

### 8.1. Listar los roles creados

```sql
SELECT role FROM dba_roles
WHERE  role IN ('ROL_ADMIN_POWERGYM','ROL_RECEPCION','ROL_ENTRENADOR');
```

### 8.2. Ver privilegios de cada rol

```sql
SELECT grantee, table_name, privilege
FROM   dba_tab_privs
WHERE  grantee IN ('ROL_RECEPCION','ROL_ENTRENADOR')
ORDER  BY grantee, table_name, privilege;
```

### 8.3. Ver qué rol tiene asignado cada usuario

```sql
SELECT grantee, granted_role, default_role
FROM   dba_role_privs
WHERE  grantee IN ('USER_RECEPCION','USER_ENTRENADOR');
```

---

## 9. Paso 7 — Pruebas de aceptación

### 9.1. Probar el usuario recepción

```sql
CONNECT user_recepcion/Recep_2026!@XEPDB1;

-- DEBE FUNCIONAR
SELECT id_cliente, nombre, apellido FROM cliente WHERE ROWNUM <= 5;

INSERT INTO cliente (id_cliente, cedula, nombre, apellido,
                     fecha_nacimiento, telefono, correo, fecha_registro)
VALUES (seq_cliente.NEXTVAL, '9999999999', 'Prueba', 'Recep',
        DATE '2000-01-01', '3000000000', 'prueba@correo.com', SYSDATE);

-- DEBE FALLAR (no tiene permiso DELETE sobre pago)
DELETE FROM pago WHERE ROWNUM = 1;
-- ORA-01031: privilegios insuficientes

-- DEBE FALLAR (no puede ver el salario)
SELECT salario FROM entrenador;
-- ORA-00942: la tabla o vista no existe

-- DEBE FUNCIONAR (puede ver el nombre por la vista)
SELECT * FROM v_entrenador_publico;

ROLLBACK;
```

### 9.2. Probar el usuario entrenador

```sql
CONNECT user_entrenador/Entren_2026!@XEPDB1;

-- DEBE FUNCIONAR
SELECT cl.nombre, COUNT(*) AS inscritos
FROM   clase cl JOIN inscripcion i ON cl.id_clase = i.id_clase
WHERE  i.estado = 'ACTIVA'
GROUP  BY cl.nombre;

INSERT INTO asistencia (id_asistencia, id_cliente, id_clase,
                        fecha_asistencia, hora_entrada)
VALUES (seq_asistencia.NEXTVAL, 1, 1, SYSDATE, '06:00');

-- DEBE FALLAR (sin permiso UPDATE)
UPDATE cliente SET telefono = '3009999999' WHERE id_cliente = 1;
-- ORA-01031: privilegios insuficientes

-- DEBE FALLAR (sin permiso INSERT en pago)
INSERT INTO pago VALUES (999, 1, SYSDATE, 50000, 'EFECTIVO');
-- ORA-01031: privilegios insuficientes

ROLLBACK;
```

---

## 10. Tabla resumen de privilegios

| Tabla / Objeto | `c##powergym` (admin) | `user_recepcion` | `user_entrenador` |
|----------------|:--:|:--:|:--:|
| `cliente`      | ALL | S/I/U/D | S |
| `plan`         | ALL | S       | — |
| `membresia`    | ALL | S/I/U   | — |
| `pago`         | ALL | S/I     | — |
| `entrenador`   | ALL | —       | — |
| `v_entrenador_publico` | ALL | S | S |
| `clase`        | ALL | S       | S |
| `inscripcion`  | ALL | S/I/U   | S |
| `asistencia`   | ALL | S/I     | S/I |
| Secuencias `seq_*` | ALL | S (varias) | S (`seq_asistencia`) |

> S = SELECT, I = INSERT, U = UPDATE, D = DELETE, ALL = control total.

---

## 11. Eliminación / limpieza del entorno

Para revertir todo lo creado por este documento:

```sql
CONNECT system/<clave_system>@XEPDB1;

DROP USER user_recepcion  CASCADE;
DROP USER user_entrenador CASCADE;
DROP USER c##powergym        CASCADE;

DROP ROLE rol_recepcion;
DROP ROLE rol_entrenador;
DROP ROLE c##rol_admin_powergym;

DROP PROFILE perfil_powergym CASCADE;
```

---

## 12. Cumplimiento del enunciado

El componente 3 del enunciado exige:

> *"El sistema debe identificar y asignar privilegios a 2 tipos de usuarios diferentes (Crear usuario del sistema), cada usuario tendrá un perfil específico y realizará operaciones sobre la base de datos de acuerdo a la definición de su perfil."*

| Requisito | Cumplimiento |
|-----------|--------------|
| 2 tipos de usuarios | `user_recepcion` y `user_entrenador` |
| Perfiles diferenciados | Roles `rol_recepcion` y `rol_entrenador` con permisos distintos |
| Operaciones acordes a su perfil | Recepción gestiona clientes/membresías/pagos; entrenador solo consulta y registra asistencias |
| Creación de usuarios | Documentada paso a paso en SQL*Plus |
| Restricciones | Tabla del numeral 10 + pruebas del numeral 9 |
