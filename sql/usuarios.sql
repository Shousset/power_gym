-- ============================================================================
-- POWER GYM - usuarios.sql
-- Creacion de los dos perfiles de usuario con sus privilegios
-- Autor: Samuel Benavides Housset
-- ============================================================================
-- Este script debe ejecutarse como SYSTEM o un usuario con privilegios DBA,
-- y APUNTANDO al esquema POWERGYM (o el que tenga las tablas).
-- ============================================================================
-- Reemplazar POWERGYM por el nombre real del esquema propietario si difiere.
-- ============================================================================

-- Limpieza previa
DECLARE
    e_no_user EXCEPTION;
    PRAGMA EXCEPTION_INIT (e_no_user, -1918);
BEGIN
    EXECUTE IMMEDIATE 'DROP USER c##user_recepcion CASCADE';
EXCEPTION WHEN e_no_user THEN NULL;
END;
/

DECLARE
    e_no_user EXCEPTION;
    PRAGMA EXCEPTION_INIT (e_no_user, -1918);
BEGIN
    EXECUTE IMMEDIATE 'DROP USER c##user_entrenador CASCADE';
EXCEPTION WHEN e_no_user THEN NULL;
END;
/

-- ============================================================================
-- USUARIO 1: c##user_recepcion (RECEPCIONISTA)
-- ============================================================================
-- Puede: gestionar clientes, membresias, pagos, inscripciones y asistencias.
-- NO puede: tocar entrenadores ni planes, y no puede ver datos salariales.
-- ============================================================================

CREATE USER c##user_recepcion IDENTIFIED BY "recepcion";
GRANT CREATE SESSION TO c##user_recepcion;

-- Cliente: control total
GRANT SELECT, INSERT, UPDATE, DELETE ON c##powergym.cliente     TO c##user_recepcion;

-- Plan: solo lectura
GRANT SELECT                         ON c##powergym.plan        TO c##user_recepcion;

-- Membresia: control total
GRANT SELECT, INSERT, UPDATE         ON c##powergym.membresia   TO c##user_recepcion;

-- Pago: insertar y consultar
GRANT SELECT, INSERT                 ON c##powergym.pago        TO c##user_recepcion;

-- Inscripcion: control total
GRANT SELECT, INSERT, UPDATE         ON c##powergym.inscripcion TO c##user_recepcion;

-- Asistencia: registrar y consultar
GRANT SELECT, INSERT                 ON c##powergym.asistencia  TO c##user_recepcion;

-- Clase: solo lectura (necesita ver el cronograma)
GRANT SELECT                         ON c##powergym.clase       TO c##user_recepcion;

-- Entrenador: lectura limitada (solo para mostrar nombre en cronograma)
-- Se hace via VIEW para ocultar el salario.
CREATE OR REPLACE VIEW c##powergym.v_entrenador_publico AS
    SELECT id_entrenador, nombre, apellido, especialidad
    FROM   c##powergym.entrenador;

GRANT SELECT ON c##powergym.v_entrenador_publico TO c##user_recepcion;

-- Secuencias para insertar
GRANT SELECT ON c##powergym.seq_cliente     TO c##user_recepcion;
GRANT SELECT ON c##powergym.seq_membresia   TO c##user_recepcion;
GRANT SELECT ON c##powergym.seq_pago        TO c##user_recepcion;
GRANT SELECT ON c##powergym.seq_inscripcion TO c##user_recepcion;
GRANT SELECT ON c##powergym.seq_asistencia  TO c##user_recepcion;

-- USUARIO 2: c##user_entrenador (ENTRENADOR)

CREATE USER c##user_entrenador IDENTIFIED BY "entrenador";
GRANT CREATE SESSION TO c##user_entrenador;

-- Cliente: solo lectura (datos basicos)
GRANT SELECT ON c##powergym.cliente     TO c##user_entrenador;

-- Clase: solo lectura
GRANT SELECT ON c##powergym.clase       TO c##user_entrenador;

-- Inscripcion: solo lectura (ver inscritos a sus clases)
GRANT SELECT ON c##powergym.inscripcion TO c##user_entrenador;

-- Asistencia: insertar y consultar
GRANT SELECT, INSERT ON c##powergym.asistencia TO c##user_entrenador;

-- Entrenador: lectura por la vista (no ve salario)
GRANT SELECT ON c##powergym.v_entrenador_publico TO c##user_entrenador;

-- Secuencia para registrar asistencias
GRANT SELECT ON c##powergym.seq_asistencia TO c##user_entrenador;

CREATE OR REPLACE PUBLIC SYNONYM cliente             FOR c##powergym.cliente;
CREATE OR REPLACE PUBLIC SYNONYM plan                FOR c##powergym.plan;
CREATE OR REPLACE PUBLIC SYNONYM membresia           FOR c##powergym.membresia;
CREATE OR REPLACE PUBLIC SYNONYM pago                FOR c##powergym.pago;
CREATE OR REPLACE PUBLIC SYNONYM clase               FOR c##powergym.clase;
CREATE OR REPLACE PUBLIC SYNONYM inscripcion         FOR c##powergym.inscripcion;
CREATE OR REPLACE PUBLIC SYNONYM asistencia          FOR c##powergym.asistencia;
CREATE OR REPLACE PUBLIC SYNONYM v_entrenador_publico FOR c##powergym.v_entrenador_publico;

CREATE OR REPLACE PUBLIC SYNONYM seq_cliente     FOR c##powergym.seq_cliente;
CREATE OR REPLACE PUBLIC SYNONYM seq_membresia   FOR c##powergym.seq_membresia;
CREATE OR REPLACE PUBLIC SYNONYM seq_pago        FOR c##powergym.seq_pago;
CREATE OR REPLACE PUBLIC SYNONYM seq_inscripcion FOR c##powergym.seq_inscripcion;
CREATE OR REPLACE PUBLIC SYNONYM seq_asistencia  FOR c##powergym.seq_asistencia;

