-- ============================================================================
-- POWER GYM - DDL.sql
-- Script de definicion de datos para Oracle 18c
-- Autor: Samuel Benavides Housset
-- ============================================================================
-- Este script reconstruye toda la estructura de la base de datos.
-- Se ejecuta como propietario del esquema (ej: usuario admin POWERGYM).
-- ============================================================================

-- Limpieza previa (permite re-ejecutar el script sin errores).
-- Se ignoran errores si las tablas/secuencias no existen aun.

BEGIN
    FOR t IN (SELECT table_name FROM user_tables
              WHERE table_name IN ('ASISTENCIA','INSCRIPCION','CLASE','ENTRENADOR',
                                   'PAGO','MEMBRESIA','PLAN','CLIENTE'))
    LOOP
        EXECUTE IMMEDIATE 'DROP TABLE '||t.table_name||' CASCADE CONSTRAINTS';
    END LOOP;

    FOR s IN (SELECT sequence_name FROM user_sequences
              WHERE sequence_name LIKE 'SEQ\_%' ESCAPE '\')
    LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE '||s.sequence_name;
    END LOOP;
END;
/

-- ============================================================================
-- SECUENCIAS (para generar IDs en la aplicacion)
-- Empiezan en 100 para no chocar con los IDs explicitos de DATOS.sql (1-99)
-- ============================================================================

CREATE SEQUENCE seq_cliente      START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_plan         START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_membresia    START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_pago         START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_entrenador   START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_clase        START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_inscripcion  START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_asistencia   START WITH 100 INCREMENT BY 1 NOCACHE;

-- ============================================================================
-- TABLAS
-- ============================================================================

-- 1. CLIENTE -----------------------------------------------------------------
CREATE TABLE cliente (
    id_cliente            NUMBER       PRIMARY KEY,
    cedula                VARCHAR2(15) NOT NULL UNIQUE,
    nombre                VARCHAR2(50) NOT NULL,
    apellido              VARCHAR2(50) NOT NULL,
    fecha_nacimiento      DATE         NOT NULL,
    telefono              VARCHAR2(10) NOT NULL,
    correo                VARCHAR2(100) NOT NULL,
    direccion             VARCHAR2(150),
    contacto_emergencia   VARCHAR2(100),
    telefono_emergencia   VARCHAR2(10),
    fecha_registro        DATE         DEFAULT SYSDATE NOT NULL,
    -- RN3: telefono debe tener exactamente 10 digitos
    CONSTRAINT chk_cliente_telefono CHECK (REGEXP_LIKE(telefono, '^[0-9]{10}$')),
    -- RN4: correo debe tener formato valido
    CONSTRAINT chk_cliente_correo   CHECK (REGEXP_LIKE(correo, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'))
);

-- 2. PLAN --------------------------------------------------------------------
CREATE TABLE plan (
    id_plan        NUMBER         PRIMARY KEY,
    nombre         VARCHAR2(50)   NOT NULL UNIQUE,
    descripcion    VARCHAR2(200),
    duracion_dias  NUMBER(4)      NOT NULL,
    precio         NUMBER(10,2)   NOT NULL,
    CONSTRAINT chk_plan_duracion CHECK (duracion_dias > 0),
    CONSTRAINT chk_plan_precio   CHECK (precio > 0)
);

-- 3. MEMBRESIA ---------------------------------------------------------------
CREATE TABLE membresia (
    id_membresia       NUMBER       PRIMARY KEY,
    id_cliente         NUMBER       NOT NULL,
    id_plan            NUMBER       NOT NULL,
    fecha_inicio       DATE         NOT NULL,
    fecha_vencimiento  DATE         NOT NULL,
    estado             VARCHAR2(15) NOT NULL,
    CONSTRAINT fk_membresia_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fk_membresia_plan    FOREIGN KEY (id_plan)    REFERENCES plan(id_plan),
    -- RN5: vencimiento debe ser posterior al inicio
    CONSTRAINT chk_membresia_fechas CHECK (fecha_vencimiento > fecha_inicio),
    CONSTRAINT chk_membresia_estado CHECK (estado IN ('ACTIVA','VENCIDA','SUSPENDIDA'))
);

-- 4. PAGO --------------------------------------------------------------------
CREATE TABLE pago (
    id_pago        NUMBER         PRIMARY KEY,
    id_membresia   NUMBER         NOT NULL,
    fecha_pago     DATE           DEFAULT SYSDATE NOT NULL,
    monto          NUMBER(10,2)   NOT NULL,
    metodo_pago    VARCHAR2(15)   NOT NULL,
    CONSTRAINT fk_pago_membresia FOREIGN KEY (id_membresia) REFERENCES membresia(id_membresia),
    -- RN6: el monto debe ser mayor a cero
    CONSTRAINT chk_pago_monto  CHECK (monto > 0),
    CONSTRAINT chk_pago_metodo CHECK (metodo_pago IN ('EFECTIVO','TARJETA','TRANSFERENCIA'))
);

-- 5. ENTRENADOR --------------------------------------------------------------
CREATE TABLE entrenador (
    id_entrenador        NUMBER        PRIMARY KEY,
    cedula               VARCHAR2(15)  NOT NULL UNIQUE,
    nombre               VARCHAR2(50)  NOT NULL,
    apellido             VARCHAR2(50)  NOT NULL,
    especialidad         VARCHAR2(50)  NOT NULL,
    telefono             VARCHAR2(10)  NOT NULL,
    fecha_contratacion   DATE          NOT NULL,
    salario              NUMBER(10,2)  NOT NULL,
    CONSTRAINT chk_entrenador_telefono CHECK (REGEXP_LIKE(telefono, '^[0-9]{10}$')),
    CONSTRAINT chk_entrenador_salario  CHECK (salario > 0)
);

-- 6. CLASE -------------------------------------------------------------------
CREATE TABLE clase (
    id_clase       NUMBER       PRIMARY KEY,
    id_entrenador  NUMBER       NOT NULL,
    nombre         VARCHAR2(50) NOT NULL,
    descripcion    VARCHAR2(200),
    dia_semana     VARCHAR2(10) NOT NULL,
    hora_inicio    VARCHAR2(5)  NOT NULL,
    hora_fin       VARCHAR2(5)  NOT NULL,
    cupo_maximo    NUMBER(3)    NOT NULL,
    CONSTRAINT fk_clase_entrenador FOREIGN KEY (id_entrenador) REFERENCES entrenador(id_entrenador),
    CONSTRAINT chk_clase_dia   CHECK (dia_semana IN ('LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO','DOMINGO')),
    CONSTRAINT chk_clase_cupo  CHECK (cupo_maximo > 0),
    CONSTRAINT chk_clase_hora  CHECK (REGEXP_LIKE(hora_inicio, '^[0-2][0-9]:[0-5][0-9]$') AND
                                      REGEXP_LIKE(hora_fin,    '^[0-2][0-9]:[0-5][0-9]$'))
);

-- 7. INSCRIPCION ------------------------------------------------------------
CREATE TABLE inscripcion (
    id_inscripcion     NUMBER       PRIMARY KEY,
    id_cliente         NUMBER       NOT NULL,
    id_clase           NUMBER       NOT NULL,
    fecha_inscripcion  DATE         DEFAULT SYSDATE NOT NULL,
    estado             VARCHAR2(15) NOT NULL,
    CONSTRAINT fk_inscripcion_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fk_inscripcion_clase   FOREIGN KEY (id_clase)   REFERENCES clase(id_clase),
    CONSTRAINT chk_inscripcion_estado CHECK (estado IN ('ACTIVA','CANCELADA')),
    CONSTRAINT uk_inscripcion_unica   UNIQUE (id_cliente, id_clase)
);

-- 8. ASISTENCIA -------------------------------------------------------------
CREATE TABLE asistencia (
    id_asistencia     NUMBER       PRIMARY KEY,
    id_cliente        NUMBER       NOT NULL,
    id_clase          NUMBER,                                  -- NULL = entrada libre
    fecha_asistencia  DATE         DEFAULT SYSDATE NOT NULL,
    hora_entrada      VARCHAR2(5)  NOT NULL,
    CONSTRAINT fk_asistencia_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fk_asistencia_clase   FOREIGN KEY (id_clase)   REFERENCES clase(id_clase) ON DELETE SET NULL,
    CONSTRAINT chk_asistencia_hora   CHECK (REGEXP_LIKE(hora_entrada, '^[0-2][0-9]:[0-5][0-9]$'))
);

-- ============================================================================
-- TRIGGERS DE REGLAS DE NEGOCIO
-- ============================================================================

-- RN1: un cliente no puede tener mas de una membresia en estado ACTIVA
CREATE OR REPLACE TRIGGER trg_unica_membresia_activa
BEFORE INSERT OR UPDATE ON membresia
FOR EACH ROW
WHEN (NEW.estado = 'ACTIVA')
DECLARE
    v_cuenta NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cuenta
    FROM   membresia
    WHERE  id_cliente = :NEW.id_cliente
      AND  estado     = 'ACTIVA'
      AND  id_membresia <> NVL(:NEW.id_membresia, -1);

    IF v_cuenta > 0 THEN
        RAISE_APPLICATION_ERROR(-20001,
            'RN1: el cliente ya tiene una membresia activa.');
    END IF;
END;
/

-- RN2: el numero de inscritos ACTIVOS en una clase no puede superar su cupo
CREATE OR REPLACE TRIGGER trg_cupo_clase
BEFORE INSERT OR UPDATE ON inscripcion
FOR EACH ROW
WHEN (NEW.estado = 'ACTIVA')
DECLARE
    v_inscritos NUMBER;
    v_cupo      NUMBER;
BEGIN
    SELECT cupo_maximo INTO v_cupo
    FROM   clase
    WHERE  id_clase = :NEW.id_clase;

    SELECT COUNT(*) INTO v_inscritos
    FROM   inscripcion
    WHERE  id_clase = :NEW.id_clase
      AND  estado   = 'ACTIVA'
      AND  id_inscripcion <> NVL(:NEW.id_inscripcion, -1);

    IF v_inscritos >= v_cupo THEN
        RAISE_APPLICATION_ERROR(-20002,
            'RN2: la clase ya alcanzo su cupo maximo.');
    END IF;
END;
/

-- RN7: solo se permite inscribir a clientes con membresia ACTIVA vigente
CREATE OR REPLACE TRIGGER trg_inscripcion_membresia_activa
BEFORE INSERT ON inscripcion
FOR EACH ROW
WHEN (NEW.estado = 'ACTIVA')
DECLARE
    v_activa NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_activa
    FROM   membresia
    WHERE  id_cliente        = :NEW.id_cliente
      AND  estado            = 'ACTIVA'
      AND  fecha_vencimiento >= TRUNC(SYSDATE);

    IF v_activa = 0 THEN
        RAISE_APPLICATION_ERROR(-20003,
            'RN7: el cliente no tiene una membresia activa vigente.');
    END IF;
END;
/

-- ============================================================================
-- INDICES (para mejorar el rendimiento de los reportes)
-- ============================================================================

CREATE INDEX idx_membresia_estado     ON membresia(estado);
CREATE INDEX idx_membresia_venc       ON membresia(fecha_vencimiento);
CREATE INDEX idx_pago_fecha           ON pago(fecha_pago);
CREATE INDEX idx_asistencia_fecha     ON asistencia(fecha_asistencia);
CREATE INDEX idx_inscripcion_clase    ON inscripcion(id_clase);

COMMIT;

-- ============================================================================
-- Fin DDL.sql
-- ============================================================================
