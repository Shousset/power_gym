
-- PLAN
INSERT INTO plan VALUES (1, 'Mensual',    'Acceso completo por 30 dias',    30,   80000.00);
INSERT INTO plan VALUES (2, 'Trimestral', 'Acceso completo por 90 dias',    90,  220000.00);
INSERT INTO plan VALUES (3, 'Semestral',  'Acceso completo por 180 dias', 180,  410000.00);
INSERT INTO plan VALUES (4, 'Anual',      'Acceso completo por 365 dias', 365,  780000.00);

-- CLIENTE
INSERT INTO cliente VALUES (1,  '1001234001', 'Juan',    'Perez',     DATE '1995-03-12', '3001234001', 'juan.perez@correo.com',    'Calle 10 #5-20',  'Maria Perez',   '3009990001', DATE '2026-01-10');
INSERT INTO cliente VALUES (2,  '1001234002', 'Maria',   'Gomez',     DATE '1990-07-25', '3001234002', 'maria.gomez@correo.com',   'Carrera 7 #12-3', 'Luis Gomez',    '3009990002', DATE '2026-01-15');
INSERT INTO cliente VALUES (3,  '1001234003', 'Carlos',  'Ramirez',   DATE '1988-11-04', '3001234003', 'carlos.r@correo.com',      'Avenida 5 #45-7', 'Ana Ramirez',   '3009990003', DATE '2026-02-01');
INSERT INTO cliente VALUES (4,  '1001234004', 'Laura',   'Martinez',  DATE '2000-02-18', '3001234004', 'laura.m@correo.com',       'Calle 22 #8-15',  'Pedro Martinez','3009990004', DATE '2026-02-12');
INSERT INTO cliente VALUES (5,  '1001234005', 'Andres',  'Lopez',     DATE '1992-09-30', '3001234005', 'andres.l@correo.com',      'Carrera 15 #4-9', 'Sofia Lopez',   '3009990005', DATE '2026-02-20');
INSERT INTO cliente VALUES (6,  '1001234006', 'Diana',   'Castro',    DATE '1998-05-14', '3001234006', 'diana.castro@correo.com',  'Calle 30 #11-2',  'Jorge Castro',  '3009990006', DATE '2026-03-01');
INSERT INTO cliente VALUES (7,  '1001234007', 'Felipe',  'Hernandez', DATE '1985-12-22', '3001234007', 'felipe.h@correo.com',      'Carrera 50 #20-5','Clara Hernandez','3009990007',DATE '2026-03-10');
INSERT INTO cliente VALUES (8,  '1001234008', 'Sandra',  'Vargas',    DATE '1997-08-08', '3001234008', 'sandra.v@correo.com',      'Calle 60 #3-44',  'Raul Vargas',   '3009990008', DATE '2026-04-05');
INSERT INTO cliente VALUES (9,  '1001234009', 'Ricardo', 'Mendoza',   DATE '1993-01-19', '3001234009', 'ricardo.m@correo.com',     'Carrera 8 #28-1', 'Elena Mendoza', '3009990009', DATE '2026-04-18');
INSERT INTO cliente VALUES (10, '1001234010', 'Paula',   'Jimenez',   DATE '2001-10-03', '3001234010', 'paula.j@correo.com',       'Calle 18 #6-10',  'Tomas Jimenez', '3009990010', DATE '2026-05-02');

-- ENTRENADOR
INSERT INTO entrenador VALUES (1, '8001100001', 'Sebastian','Rojas',  'Crossfit',  '3101100001', DATE '2024-01-15', 1800000.00);
INSERT INTO entrenador VALUES (2, '8001100002', 'Valentina','Diaz',   'Yoga',      '3101100002', DATE '2024-03-20', 1700000.00);
INSERT INTO entrenador VALUES (3, '8001100003', 'Mateo',    'Suarez', 'Spinning',  '3101100003', DATE '2024-06-10', 1750000.00);
INSERT INTO entrenador VALUES (4, '8001100004', 'Camila',   'Ortiz',  'Zumba',     '3101100004', DATE '2025-02-01', 1650000.00);

-- CLASE
INSERT INTO clase VALUES (1, 1, 'Crossfit AM',  'Crossfit alta intensidad',          'LUNES',     '06:00', '07:00', 15);
INSERT INTO clase VALUES (2, 1, 'Crossfit PM',  'Crossfit nivel intermedio',         'MIERCOLES', '18:00', '19:00', 15);
INSERT INTO clase VALUES (3, 2, 'Yoga Suave',   'Yoga relajante para principiantes', 'MARTES',    '09:00', '10:00', 20);
INSERT INTO clase VALUES (4, 2, 'Yoga Power',   'Yoga dinamico y exigente',          'JUEVES',    '19:00', '20:00', 20);
INSERT INTO clase VALUES (5, 3, 'Spinning AM',  'Spinning con musica energetica',    'LUNES',     '07:00', '08:00', 12);
INSERT INTO clase VALUES (6, 3, 'Spinning PM',  'Spinning de resistencia',           'VIERNES',   '18:30', '19:30', 12);
INSERT INTO clase VALUES (7, 4, 'Zumba Fit',    'Baile y cardio',                    'SABADO',    '10:00', '11:00', 25);
INSERT INTO clase VALUES (8, 4, 'Zumba Latino', 'Ritmos latinos',                    'MIERCOLES', '19:30', '20:30', 25);

-- MEMBRESIA
-- (mezcla de activas, vencidas y suspendidas)
-- IMPORTANTE: las fechas son relativas a SYSDATE para que las membresias
-- 'ACTIVA' sigan VIGENTES cualquier dia que se ejecute el script. Esto es
-- obligatorio porque el trigger RN7 (trg_inscripcion_membresia_activa) exige
-- fecha_vencimiento >= TRUNC(SYSDATE) para poder insertar las inscripciones.
-- La diferencia (venc - inicio) coincide con la duracion_dias de cada plan.
INSERT INTO membresia VALUES (1,  1, 1,  TRUNC(SYSDATE),  TRUNC(SYSDATE),  'ACTIVA');
INSERT INTO membresia VALUES (2,  2, 2,  TRUNC(SYSDATE),  TRUNC(SYSDATE),  'ACTIVA');
INSERT INTO membresia VALUES (3,  3, 3,  TRUNC(SYSDATE),  TRUNC(SYSDATE), 'ACTIVA');
INSERT INTO membresia VALUES (4,  4, 1,  TRUNC(SYSDATE),   TRUNC(SYSDATE),  'ACTIVA');
INSERT INTO membresia VALUES (5,  5, 4,  TRUNC(SYSDATE), TRUNC(SYSDATE), 'ACTIVA');
INSERT INTO membresia VALUES (6,  6, 1,  TRUNC(SYSDATE),  TRUNC(SYSDATE),  'VENCIDA');
INSERT INTO membresia VALUES (7,  7, 2,  TRUNC(SYSDATE), TRUNC(SYSDATE),  'VENCIDA');
INSERT INTO membresia VALUES (8,  8, 1,  TRUNC(SYSDATE),   TRUNC(SYSDATE),  'ACTIVA');
INSERT INTO membresia VALUES (9,  9, 3,  TRUNC(SYSDATE), TRUNC(SYSDATE),  'SUSPENDIDA');
INSERT INTO membresia VALUES (10, 10, 1, TRUNC(SYSDATE),   TRUNC(SYSDATE),  'ACTIVA');

-- PAGO
INSERT INTO pago VALUES (1,  1,  DATE '2026-05-01',  80000.00, 'EFECTIVO');
INSERT INTO pago VALUES (2,  2,  DATE '2026-04-15', 220000.00, 'TARJETA');
INSERT INTO pago VALUES (3,  3,  DATE '2026-02-01', 410000.00, 'TRANSFERENCIA');
INSERT INTO pago VALUES (4,  4,  DATE '2026-05-10',  80000.00, 'EFECTIVO');
INSERT INTO pago VALUES (5,  5,  DATE '2026-01-20', 780000.00, 'TARJETA');
INSERT INTO pago VALUES (6,  6,  DATE '2026-03-01',  80000.00, 'EFECTIVO');
INSERT INTO pago VALUES (7,  7,  DATE '2025-12-01', 220000.00, 'TRANSFERENCIA');
INSERT INTO pago VALUES (8,  8,  DATE '2026-05-05',  80000.00, 'EFECTIVO');
INSERT INTO pago VALUES (9,  9,  DATE '2026-01-10', 410000.00, 'TARJETA');
INSERT INTO pago VALUES (10, 10, DATE '2026-05-15',  80000.00, 'TARJETA');
INSERT INTO pago VALUES (11, 2,  DATE '2026-05-20',  50000.00, 'EFECTIVO');  -- pago adicional

-- INSCRIPCION
-- (solo clientes con membresia ACTIVA)
INSERT INTO inscripcion VALUES (1,  1, 1, DATE '2026-05-02', 'ACTIVA');
INSERT INTO inscripcion VALUES (2,  1, 5, DATE '2026-05-02', 'ACTIVA');
INSERT INTO inscripcion VALUES (3,  2, 3, DATE '2026-04-16', 'ACTIVA');
INSERT INTO inscripcion VALUES (4,  2, 7, DATE '2026-04-16', 'ACTIVA');
INSERT INTO inscripcion VALUES (5,  3, 4, DATE '2026-02-05', 'ACTIVA');
INSERT INTO inscripcion VALUES (6,  3, 8, DATE '2026-02-05', 'ACTIVA');
INSERT INTO inscripcion VALUES (7,  4, 1, DATE '2026-05-11', 'ACTIVA');
INSERT INTO inscripcion VALUES (8,  4, 7, DATE '2026-05-11', 'ACTIVA');
INSERT INTO inscripcion VALUES (9,  5, 2, DATE '2026-01-25', 'ACTIVA');
INSERT INTO inscripcion VALUES (10, 5, 6, DATE '2026-01-25', 'ACTIVA');
INSERT INTO inscripcion VALUES (11, 8, 7, DATE '2026-05-08', 'ACTIVA');
INSERT INTO inscripcion VALUES (12, 8, 3, DATE '2026-05-08', 'CANCELADA');
INSERT INTO inscripcion VALUES (13, 10, 1, DATE '2026-05-16', 'ACTIVA');
INSERT INTO inscripcion VALUES (14, 10, 8, DATE '2026-05-16', 'ACTIVA');
INSERT INTO inscripcion VALUES (15, 2, 1, DATE '2026-04-20', 'ACTIVA');

-- ASISTENCIA
INSERT INTO asistencia VALUES (1,  1,  1,    DATE '2026-05-05', '05:55');
INSERT INTO asistencia VALUES (2,  1,  NULL, DATE '2026-05-07', '17:30');
INSERT INTO asistencia VALUES (3,  2,  3,    DATE '2026-05-12', '08:50');
INSERT INTO asistencia VALUES (4,  2,  7,    DATE '2026-05-16', '09:55');
INSERT INTO asistencia VALUES (5,  3,  4,    DATE '2026-05-08', '18:55');
INSERT INTO asistencia VALUES (6,  3,  NULL, DATE '2026-05-13', '07:00');
INSERT INTO asistencia VALUES (7,  4,  1,    DATE '2026-05-12', '05:58');
INSERT INTO asistencia VALUES (8,  4,  7,    DATE '2026-05-17', '09:48');
INSERT INTO asistencia VALUES (9,  5,  2,    DATE '2026-05-11', '17:55');
INSERT INTO asistencia VALUES (10, 5,  6,    DATE '2026-05-15', '18:25');
INSERT INTO asistencia VALUES (11, 5,  NULL, DATE '2026-05-18', '19:00');
INSERT INTO asistencia VALUES (12, 8,  7,    DATE '2026-05-10', '09:50');
INSERT INTO asistencia VALUES (13, 8,  NULL, DATE '2026-05-14', '16:20');
INSERT INTO asistencia VALUES (14, 10, 1,    DATE '2026-05-19', '06:01');
INSERT INTO asistencia VALUES (15, 10, 8,    DATE '2026-05-20', '19:25');
INSERT INTO asistencia VALUES (16, 1,  5,    DATE '2026-05-12', '06:55');
INSERT INTO asistencia VALUES (17, 1,  NULL, DATE '2026-05-14', '18:10');
INSERT INTO asistencia VALUES (18, 2,  NULL, DATE '2026-05-21', '17:00');
INSERT INTO asistencia VALUES (19, 3,  NULL, DATE '2026-05-22', '10:00');
INSERT INTO asistencia VALUES (20, 4,  NULL, DATE '2026-05-22', '07:30');

COMMIT;

-- Verificacion rapida (los conteos deben coincidir con lo insertado)
SELECT 'CLIENTE'     AS tabla, COUNT(*) AS filas FROM cliente
UNION ALL SELECT 'PLAN',         COUNT(*) FROM plan
UNION ALL SELECT 'MEMBRESIA',    COUNT(*) FROM membresia
UNION ALL SELECT 'PAGO',         COUNT(*) FROM pago
UNION ALL SELECT 'ENTRENADOR',   COUNT(*) FROM entrenador
UNION ALL SELECT 'CLASE',        COUNT(*) FROM clase
UNION ALL SELECT 'INSCRIPCION',  COUNT(*) FROM inscripcion
UNION ALL SELECT 'ASISTENCIA',   COUNT(*) FROM asistencia;
