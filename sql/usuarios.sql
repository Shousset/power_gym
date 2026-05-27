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
    EXECUTE IMMEDIATE 'DROP USER user_recepcion CASCADE';
EXCEPTION WHEN e_no_user THEN NULL;
END;
/

DECLARE
    e_no_user EXCEPTION;
    PRAGMA EXCEPTION_INIT (e_no_user, -1918);
BEGIN
    EXECUTE IMMEDIATE 'DROP USER user_entrenador CASCADE';
EXCEPTION WHEN e_no_user THEN NULL;
END;
/

-- ============================================================================
-- USUARIO 1: user_recepcion (RECEPCIONISTA)
-- ============================================================================
-- Puede: gestionar clientes, membresias, pagos, inscripciones y asistencias.
-- NO puede: tocar entrenadores ni planes, y no puede ver datos salariales.
-- ============================================================================

CREATE USER user_recepcion IDENTIFIED BY "Recep_2026!";
GRANT CREATE SESSION TO user_recepcion;

-- Cliente: control total
GRANT SELECT, INSERT, UPDATE, DELETE ON powergym.cliente     TO user_recepcion;

-- Plan: solo lectura
GRANT SELECT                         ON powergym.plan        TO user_recepcion;

-- Membresia: control total
GRANT SELECT, INSERT, UPDATE         ON powergym.membresia   TO user_recepcion;

-- Pago: insertar y consultar
GRANT SELECT, INSERT                 ON powergym.pago        TO user_recepcion;

-- Inscripcion: control total
GRANT SELECT, INSERT, UPDATE         ON powergym.inscripcion TO user_recepcion;

-- Asistencia: registrar y consultar
GRANT SELECT, INSERT                 ON powergym.asistencia  TO user_recepcion;

-- Clase: solo lectura (necesita ver el cronograma)
GRANT SELECT                         ON powergym.clase       TO user_recepcion;

-- Entrenador: lectura limitada (solo para mostrar nombre en cronograma)
-- Se hace via VIEW para ocultar el salario.
CREATE OR REPLACE VIEW powergym.v_entrenador_publico AS
    SELECT id_entrenador, nombre, apellido, especialidad
    FROM   powergym.entrenador;

GRANT SELECT ON powergym.v_entrenador_publico TO user_recepcion;

-- Secuencias para insertar
GRANT SELECT ON powergym.seq_cliente     TO user_recepcion;
GRANT SELECT ON powergym.seq_membresia   TO user_recepcion;
GRANT SELECT ON powergym.seq_pago        TO user_recepcion;
GRANT SELECT ON powergym.seq_inscripcion TO user_recepcion;
GRANT SELECT ON powergym.seq_asistencia  TO user_recepcion;

-- ============================================================================
-- USUARIO 2: user_entrenador (ENTRENADOR)
-- ============================================================================
-- Puede: consultar sus clases, ver inscritos, registrar asistencia a clase.
-- NO puede: tocar membresias, pagos ni modificar clientes.
-- ============================================================================

CREATE USER user_entrenador IDENTIFIED BY "Entren_2026!";
GRANT CREATE SESSION TO user_entrenador;

-- Cliente: solo lectura (datos basicos)
GRANT SELECT ON powergym.cliente     TO user_entrenador;

-- Clase: solo lectura
GRANT SELECT ON powergym.clase       TO user_entrenador;

-- Inscripcion: solo lectura (ver inscritos a sus clases)
GRANT SELECT ON powergym.inscripcion TO user_entrenador;

-- Asistencia: insertar y consultar
GRANT SELECT, INSERT ON powergym.asistencia TO user_entrenador;

-- Entrenador: lectura por la vista (no ve salario)
GRANT SELECT ON powergym.v_entrenador_publico TO user_entrenador;

-- Secuencia para registrar asistencias
GRANT SELECT ON powergym.seq_asistencia TO user_entrenador;

-- ============================================================================
-- SINONIMOS publicos para que las consultas en la app no requieran prefijo
-- ============================================================================

CREATE OR REPLACE PUBLIC SYNONYM cliente             FOR powergym.cliente;
CREATE OR REPLACE PUBLIC SYNONYM plan                FOR powergym.plan;
CREATE OR REPLACE PUBLIC SYNONYM membresia           FOR powergym.membresia;
CREATE OR REPLACE PUBLIC SYNONYM pago                FOR powergym.pago;
CREATE OR REPLACE PUBLIC SYNONYM clase               FOR powergym.clase;
CREATE OR REPLACE PUBLIC SYNONYM inscripcion         FOR powergym.inscripcion;
CREATE OR REPLACE PUBLIC SYNONYM asistencia          FOR powergym.asistencia;
CREATE OR REPLACE PUBLIC SYNONYM v_entrenador_publico FOR powergym.v_entrenador_publico;

CREATE OR REPLACE PUBLIC SYNONYM seq_cliente     FOR powergym.seq_cliente;
CREATE OR REPLACE PUBLIC SYNONYM seq_membresia   FOR powergym.seq_membresia;
CREATE OR REPLACE PUBLIC SYNONYM seq_pago        FOR powergym.seq_pago;
CREATE OR REPLACE PUBLIC SYNONYM seq_inscripcion FOR powergym.seq_inscripcion;
CREATE OR REPLACE PUBLIC SYNONYM seq_asistencia  FOR powergym.seq_asistencia;

-- ============================================================================
-- Verificacion
-- ============================================================================
SELECT username, account_status FROM dba_users
WHERE username IN ('USER_RECEPCION','USER_ENTRENADOR');

-- ============================================================================
-- Fin usuarios.sql
-- ============================================================================
