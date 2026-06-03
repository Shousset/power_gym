-- 1. Clientes con membresia ACTIVA.
SELECT id_cliente, nombre, apellido, correo
FROM   cliente
WHERE  id_cliente IN (SELECT id_cliente FROM membresia WHERE estado = 'ACTIVA');

-- 2. Pagos realizados en mayo de 2026 mayores a 100.000.
SELECT id_pago, id_membresia, fecha_pago, monto, metodo_pago
FROM   pago
WHERE  fecha_pago BETWEEN DATE '2026-05-01' AND DATE '2026-05-31' AND  monto > 100000;

-- 3. Clases con cupo maximo mayor o igual a 20.
SELECT id_clase, nombre, dia_semana, hora_inicio, cupo_maximo
FROM   clase
WHERE  cupo_maximo >= 20;

-- 4. Clientes nacidos antes de 1995.
SELECT id_cliente, nombre, apellido, fecha_nacimiento
FROM   cliente
WHERE  fecha_nacimiento < DATE '1995-01-01';

-- 5. Membresias que ya vencieron a la fecha actual.
SELECT id_membresia, id_cliente, fecha_inicio, fecha_vencimiento, estado
FROM   membresia
WHERE  fecha_vencimiento < TRUNC(SYSDATE);

-- 6. Pagos en efectivo o transferencia (LIKE/IN combinados).
SELECT id_pago, fecha_pago, monto, metodo_pago
FROM   pago
WHERE  metodo_pago IN ('EFECTIVO','TRANSFERENCIA');

-- 7. Entrenadores con salario entre 1.700.000 y 1.800.000.
SELECT id_entrenador, nombre, apellido, especialidad, salario
FROM   entrenador
WHERE  salario BETWEEN 1700000 AND 1800000;

-- 8. Asistencias registradas en entrada libre (id_clase nulo).
SELECT id_asistencia, id_cliente, fecha_asistencia, hora_entrada
FROM   asistencia
WHERE  id_clase IS NULL;

-- 9. INNER JOIN: clientes con su membresia activa y el nombre del plan.
SELECT c.id_cliente, c.nombre, c.apellido, p.nombre AS plan, m.fecha_vencimiento
FROM   cliente   c
INNER  JOIN membresia m ON c.id_cliente = m.id_cliente
INNER  JOIN plan      p ON m.id_plan    = p.id_plan
WHERE  m.estado = 'ACTIVA';

-- 10. LEFT JOIN: todos los clientes y, si tiene, su ultima membresia.
SELECT c.id_cliente, c.nombre, c.apellido, m.id_membresia, m.estado
FROM   cliente   c
LEFT   JOIN membresia m ON c.id_cliente = m.id_cliente
ORDER  BY c.id_cliente;

-- 11. RIGHT JOIN: todas las clases y los entrenadores que las dictan.
SELECT e.nombre || ' ' || e.apellido AS entrenador, cl.nombre AS clase, cl.dia_semana
FROM   entrenador e
RIGHT  JOIN clase cl ON e.id_entrenador = cl.id_entrenador
ORDER  BY cl.dia_semana, cl.hora_inicio;

--12. CROSS JOIN: producto cartesiano entre planes y metodos de pago disponibles
-- (catalogo de combinaciones posibles para el formulario de la app).
SELECT p.nombre AS plan, p.precio, m.metodo
FROM   plan p
CROSS  JOIN (SELECT 'EFECTIVO' AS metodo FROM dual UNION ALL SELECT 'TARJETA'       FROM dual UNION ALL SELECT 'TRANSFERENCIA' FROM dual) m
ORDER  BY p.id_plan, m.metodo;

-- 13. INNER JOIN multi-tabla: inscripciones activas con cliente, clase y entrenador.
SELECT c.nombre || ' ' || c.apellido AS cliente, cl.nombre AS clase, e.nombre  || ' ' || e.apellido AS entrenador, i.fecha_inscripcion
FROM   inscripcion i
INNER  JOIN cliente    c  ON i.id_cliente    = c.id_cliente
INNER  JOIN clase      cl ON i.id_clase      = cl.id_clase
INNER  JOIN entrenador e  ON cl.id_entrenador = e.id_entrenador
WHERE  i.estado = 'ACTIVA';

-- 14. LEFT JOIN: asistencias con la clase a la que asistio (si la hubo).
SELECT a.id_asistencia, c.nombre || ' ' || c.apellido AS cliente, NVL(cl.nombre, '(entrada libre)') AS clase, a.fecha_asistencia, a.hora_entrada
FROM   asistencia a
INNER  JOIN cliente c  ON a.id_cliente = c.id_cliente
LEFT   JOIN clase   cl ON a.id_clase   = cl.id_clase
ORDER  BY a.fecha_asistencia DESC, a.hora_entrada;