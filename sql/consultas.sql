-- ============================================================================
-- POWER GYM - consultas.sql
-- Conjunto de consultas SQL exigidas por el enunciado del proyecto
-- Autor: Samuel Benavides Housset
-- Motor: Oracle 18c
-- ============================================================================
-- Pre-requisito: ejecutar DDL.sql y DATOS.sql en el esquema POWERGYM.
-- Cada consulta esta numerada y precedida por su clasificacion.
-- ============================================================================

SET LINESIZE 200
SET PAGESIZE 50

-- ============================================================================
-- BLOQUE A. RESTRINGIR REGISTROS CON CONDICIONES (8 consultas)
-- ============================================================================

-- A1. Clientes con membresia ACTIVA.
SELECT id_cliente, nombre, apellido, correo
FROM   cliente
WHERE  id_cliente IN (SELECT id_cliente FROM membresia WHERE estado = 'ACTIVA');

-- A2. Pagos realizados en mayo de 2026 mayores a 100.000.
SELECT id_pago, id_membresia, fecha_pago, monto, metodo_pago
FROM   pago
WHERE  fecha_pago BETWEEN DATE '2026-05-01' AND DATE '2026-05-31'
  AND  monto > 100000;

-- A3. Clases con cupo maximo mayor o igual a 20.
SELECT id_clase, nombre, dia_semana, hora_inicio, cupo_maximo
FROM   clase
WHERE  cupo_maximo >= 20;

-- A4. Clientes nacidos antes de 1995.
SELECT id_cliente, nombre, apellido, fecha_nacimiento
FROM   cliente
WHERE  fecha_nacimiento < DATE '1995-01-01';

-- A5. Membresias que ya vencieron a la fecha actual.
SELECT id_membresia, id_cliente, fecha_inicio, fecha_vencimiento, estado
FROM   membresia
WHERE  fecha_vencimiento < TRUNC(SYSDATE);

-- A6. Pagos en efectivo o transferencia (LIKE/IN combinados).
SELECT id_pago, fecha_pago, monto, metodo_pago
FROM   pago
WHERE  metodo_pago IN ('EFECTIVO','TRANSFERENCIA');

-- A7. Entrenadores con salario entre 1.700.000 y 1.800.000.
SELECT id_entrenador, nombre, apellido, especialidad, salario
FROM   entrenador
WHERE  salario BETWEEN 1700000 AND 1800000;

-- A8. Asistencias registradas en entrada libre (id_clase nulo).
SELECT id_asistencia, id_cliente, fecha_asistencia, hora_entrada
FROM   asistencia
WHERE  id_clase IS NULL;

-- ============================================================================
-- BLOQUE B. RESTRINGIR CON JOIN (6 consultas: inner, cross, left, right, etc.)
-- ============================================================================

-- B1. INNER JOIN: clientes con su membresia activa y el nombre del plan.
SELECT c.id_cliente, c.nombre, c.apellido, p.nombre AS plan, m.fecha_vencimiento
FROM   cliente   c
INNER  JOIN membresia m ON c.id_cliente = m.id_cliente
INNER  JOIN plan      p ON m.id_plan    = p.id_plan
WHERE  m.estado = 'ACTIVA';

-- B2. LEFT JOIN: todos los clientes y, si tiene, su ultima membresia.
SELECT c.id_cliente, c.nombre, c.apellido, m.id_membresia, m.estado
FROM   cliente   c
LEFT   JOIN membresia m ON c.id_cliente = m.id_cliente
ORDER  BY c.id_cliente;

-- B3. RIGHT JOIN: todas las clases y los entrenadores que las dictan.
SELECT e.nombre || ' ' || e.apellido AS entrenador, cl.nombre AS clase, cl.dia_semana
FROM   entrenador e
RIGHT  JOIN clase cl ON e.id_entrenador = cl.id_entrenador
ORDER  BY cl.dia_semana, cl.hora_inicio;

-- B4. CROSS JOIN: producto cartesiano entre planes y metodos de pago disponibles
-- (catalogo de combinaciones posibles para el formulario de la app).
SELECT p.nombre AS plan, p.precio, m.metodo
FROM   plan p
CROSS  JOIN (SELECT 'EFECTIVO' AS metodo FROM dual
             UNION ALL SELECT 'TARJETA'       FROM dual
             UNION ALL SELECT 'TRANSFERENCIA' FROM dual) m
ORDER  BY p.id_plan, m.metodo;

-- B5. INNER JOIN multi-tabla: inscripciones activas con cliente, clase y entrenador.
SELECT c.nombre || ' ' || c.apellido AS cliente,
       cl.nombre AS clase,
       e.nombre  || ' ' || e.apellido AS entrenador,
       i.fecha_inscripcion
FROM   inscripcion i
INNER  JOIN cliente    c  ON i.id_cliente    = c.id_cliente
INNER  JOIN clase      cl ON i.id_clase      = cl.id_clase
INNER  JOIN entrenador e  ON cl.id_entrenador = e.id_entrenador
WHERE  i.estado = 'ACTIVA';

-- B6. LEFT JOIN: asistencias con la clase a la que asistio (si la hubo).
SELECT a.id_asistencia, c.nombre || ' ' || c.apellido AS cliente,
       NVL(cl.nombre, '(entrada libre)') AS clase,
       a.fecha_asistencia, a.hora_entrada
FROM   asistencia a
INNER  JOIN cliente c  ON a.id_cliente = c.id_cliente
LEFT   JOIN clase   cl ON a.id_clase   = cl.id_clase
ORDER  BY a.fecha_asistencia DESC, a.hora_entrada;

-- ============================================================================
-- BLOQUE C. ORDENAR DATOS (3 consultas: simple y por multiples columnas)
-- ============================================================================

-- C1. Ordenamiento simple: clientes ordenados alfabeticamente.
SELECT id_cliente, apellido, nombre
FROM   cliente
ORDER  BY apellido, nombre;

-- C2. Multi-columna: membresias ordenadas por estado y luego por vencimiento.
SELECT id_membresia, id_cliente, estado, fecha_vencimiento
FROM   membresia
ORDER  BY estado ASC, fecha_vencimiento DESC;

-- C3. Multi-columna con expresion: pagos por mes (mas reciente primero) y mayor monto.
SELECT TO_CHAR(fecha_pago,'YYYY-MM') AS mes, id_pago, monto, metodo_pago
FROM   pago
ORDER  BY TO_CHAR(fecha_pago,'YYYY-MM') DESC, monto DESC;

-- ============================================================================
-- BLOQUE D. AGRUPAR Y FUNCIONES DE GRUPO (2 consultas)
-- ============================================================================

-- D1. Ingresos totales por mes y cantidad de pagos (reporte R3).
SELECT TO_CHAR(fecha_pago,'YYYY-MM') AS mes,
       COUNT(*)        AS num_pagos,
       SUM(monto)      AS ingresos,
       ROUND(AVG(monto),2) AS pago_promedio
FROM   pago
GROUP  BY TO_CHAR(fecha_pago,'YYYY-MM')
ORDER  BY mes;

-- D2. Cantidad de inscritos activos por clase y entrenador, solo clases con >=2 inscritos.
SELECT cl.nombre AS clase,
       e.nombre || ' ' || e.apellido AS entrenador,
       COUNT(i.id_inscripcion) AS inscritos
FROM   clase cl
JOIN   entrenador  e ON cl.id_entrenador = e.id_entrenador
LEFT   JOIN inscripcion i ON cl.id_clase = i.id_clase AND i.estado = 'ACTIVA'
GROUP  BY cl.nombre, e.nombre, e.apellido
HAVING COUNT(i.id_inscripcion) >= 2
ORDER  BY inscritos DESC;

-- ============================================================================
-- BLOQUE E. SUBCONSULTAS CORRELACIONADAS + UPDATE/DELETE CON SUBCONSULTAS (6)
-- ============================================================================

-- E1. SUBCONSULTA CORRELACIONADA: clientes cuyo numero de asistencias supera el
--     promedio de asistencias por cliente.
SELECT c.id_cliente, c.nombre, c.apellido,
       (SELECT COUNT(*) FROM asistencia a WHERE a.id_cliente = c.id_cliente) AS asistencias
FROM   cliente c
WHERE  (SELECT COUNT(*) FROM asistencia a WHERE a.id_cliente = c.id_cliente) >
       (SELECT AVG(total)
        FROM  (SELECT COUNT(*) AS total
               FROM   asistencia
               GROUP  BY id_cliente));

-- E2. SUBCONSULTA CORRELACIONADA con EXISTS: clases que tienen al menos un inscrito activo.
SELECT cl.id_clase, cl.nombre, cl.dia_semana
FROM   clase cl
WHERE  EXISTS (SELECT 1
               FROM   inscripcion i
               WHERE  i.id_clase = cl.id_clase
                 AND  i.estado   = 'ACTIVA');

-- E3. SUBCONSULTA CORRELACIONADA con NOT EXISTS: clientes con membresia activa
--     que aun no se han inscrito a ninguna clase.
SELECT c.id_cliente, c.nombre, c.apellido
FROM   cliente c
WHERE  EXISTS (SELECT 1 FROM membresia m
               WHERE  m.id_cliente = c.id_cliente AND m.estado = 'ACTIVA')
  AND  NOT EXISTS (SELECT 1 FROM inscripcion i
                   WHERE  i.id_cliente = c.id_cliente AND i.estado = 'ACTIVA');

-- E4. SUBCONSULTA CORRELACIONADA: membresia mas reciente de cada cliente.
SELECT m.id_membresia, m.id_cliente, m.fecha_inicio, m.estado
FROM   membresia m
WHERE  m.fecha_inicio = (SELECT MAX(m2.fecha_inicio)
                         FROM   membresia m2
                         WHERE  m2.id_cliente = m.id_cliente);

-- E5. UPDATE CON SUBCONSULTA: marcar como VENCIDA toda membresia cuya
--     fecha_vencimiento ya paso y siga en estado ACTIVA.
UPDATE membresia
SET    estado = 'VENCIDA'
WHERE  estado = 'ACTIVA'
  AND  fecha_vencimiento < TRUNC(SYSDATE)
  AND  id_membresia IN (SELECT id_membresia
                        FROM   membresia
                        WHERE  fecha_vencimiento < TRUNC(SYSDATE));

-- E6. DELETE CON SUBCONSULTA: borrar inscripciones CANCELADAS cuyo cliente ya no
--     tiene ninguna membresia activa (limpieza de historico).
DELETE FROM inscripcion
WHERE  estado = 'CANCELADA'
  AND  id_cliente IN (SELECT c.id_cliente
                      FROM   cliente c
                      WHERE  NOT EXISTS (SELECT 1 FROM membresia m
                                         WHERE m.id_cliente = c.id_cliente
                                           AND m.estado     = 'ACTIVA'));

ROLLBACK;  -- las modificaciones de E5/E6 se revierten para no alterar los datos.

-- ============================================================================
-- BLOQUE F. INSERT / UPDATE / DELETE SENCILLOS (3 consultas)
-- ============================================================================

-- F1. INSERT: registrar un nuevo cliente.
INSERT INTO cliente (id_cliente, cedula, nombre, apellido, fecha_nacimiento,
                     telefono, correo, direccion, contacto_emergencia,
                     telefono_emergencia, fecha_registro)
VALUES (seq_cliente.NEXTVAL, '1001234999', 'Nuevo', 'Cliente',
        DATE '1999-06-15', '3001234999', 'nuevo.cliente@correo.com',
        'Calle Nueva 1-2-3', 'Familiar', '3009999999', SYSDATE);

-- F2. UPDATE: subirle el cupo a la clase "Yoga Suave" en 5 puestos.
UPDATE clase
SET    cupo_maximo = cupo_maximo + 5
WHERE  nombre = 'Yoga Suave';

-- F3. DELETE: eliminar fisicamente el cliente recien insertado (no tiene
--     dependencias). Usamos la cedula para ubicarlo.
DELETE FROM cliente
WHERE  cedula = '1001234999';

ROLLBACK;  -- revertir tambien las pruebas del bloque F.

-- ============================================================================
-- Fin consultas.sql
-- ============================================================================
