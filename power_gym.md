# Power Gym — Documento de Requerimientos

**Proyecto:** Sistema de gestión para gimnasio
**Asignatura:** Bases de Datos
**Motor de BD:** Oracle 18c
**Autor:** Samuel Benavides Housset

---

## 1. Universo de Discurso

### a) Descripción de los procesos y el entorno

**Power Gym** es un gimnasio ubicado en la ciudad que ofrece servicios de acondicionamiento físico mediante membresías mensuales, trimestrales y anuales. El gimnasio cuenta con una sala de máquinas de uso libre y un cronograma semanal de **clases grupales** (spinning, crossfit, yoga, funcional, zumba) impartidas por entrenadores certificados.

**Procesos principales del negocio:**

1. **Registro de clientes:** cuando una persona desea inscribirse, la recepción captura sus datos personales (cédula, nombre, fecha de nacimiento, teléfono, correo, dirección, contacto de emergencia) y le asigna un código de cliente.

2. **Venta de membresías:** el cliente elige un **plan** (mensual, trimestral, semestral, anual) con un costo y duración fijos. Se le crea una **membresía** con fecha de inicio, fecha de vencimiento y estado (activa, vencida, suspendida). Un cliente solo puede tener **una membresía activa** a la vez.

3. **Registro de pagos:** cada membresía genera al menos un pago. Los pagos se hacen en efectivo, tarjeta o transferencia. La membresía solo se activa cuando el pago está confirmado.

4. **Programación de clases grupales:** el administrador define las clases del cronograma (nombre, descripción, cupo máximo, día de la semana, hora, entrenador a cargo). Las clases son recurrentes semanalmente.

5. **Inscripción a clases:** los clientes con membresía activa se inscriben previamente a las clases. No pueden inscribirse si la clase ya alcanzó su cupo máximo.

6. **Control de asistencia:** cada vez que un cliente entra al gimnasio o asiste a una clase, el entrenador o recepcionista registra la asistencia con fecha y hora.

7. **Gestión de entrenadores:** el gimnasio mantiene un registro de sus entrenadores (cédula, nombre, especialidad, teléfono, fecha de contratación, salario).

**Entorno:** el sistema funcionará en la recepción del gimnasio (atención al cliente, ventas, pagos) y en las salas de clases (registro de asistencia). Es un sistema interno, no abierto al público.

---

### b) Requerimientos del sistema de información

#### Usuarios y acciones sobre el sistema

El sistema reconocerá **dos tipos de usuarios** con privilegios diferenciados:

**Usuario 1 — Recepcionista (`user_recepcion`)**
- Registrar, consultar y actualizar datos de clientes.
- Vender y renovar membresías.
- Registrar pagos.
- Inscribir clientes a clases grupales.
- Registrar asistencia de clientes al gimnasio.
- Consultar el cronograma de clases.
- **No puede:** crear/eliminar planes, modificar entrenadores, eliminar clientes ni acceder a información salarial.

**Usuario 2 — Entrenador (`user_entrenador`)**
- Consultar el listado de inscritos a sus clases.
- Registrar la asistencia de los clientes a sus clases.
- Consultar la información básica de los clientes inscritos en sus clases.
- **No puede:** modificar membresías, registrar pagos, modificar datos personales de clientes ni ver información de otros entrenadores.

#### Informes a presentar a los usuarios

- Listado de clientes con membresía activa.
- Listado de clientes con membresía por vencer en los próximos 7 días.
- Reporte de ingresos por mes.
- Listado de inscritos por clase y por entrenador.
- Reporte de asistencia diaria al gimnasio.
- Clases más concurridas del mes.
- Clientes con mayor número de visitas (top 10).

#### Restricciones de uso

- Cada usuario debe autenticarse con su perfil antes de acceder al sistema.
- Solo el administrador (DBA) puede crear nuevos usuarios y otorgar privilegios.
- Los registros de pagos, asistencias e inscripciones no se eliminan físicamente — se manejan con estados o histórico.
- No se permite registrar dos clientes con la misma cédula.
- No se permite inscribir a un cliente sin membresía activa a una clase.
- La hora de registro de asistencia la asigna automáticamente el sistema (no editable por el usuario).

---

### c) Reglas de negocio (Restricciones)

| # | Regla | Tipo | Implementación |
|---|-------|------|----------------|
| RN1 | Un cliente no puede tener más de una membresía activa al mismo tiempo. | Restricción de datos | CHECK / Trigger sobre `MEMBRESIAS` |
| RN2 | El número de inscritos a una clase no puede superar el cupo máximo definido. | Restricción de datos | Trigger sobre `INSCRIPCIONES` |
| RN3 | El teléfono del cliente debe tener exactamente 10 dígitos numéricos. | Formato de datos | CHECK con expresión regular sobre `CLIENTES.telefono` |
| RN4 | El correo electrónico debe cumplir un formato válido (contener `@` y dominio). | Formato de datos | CHECK con expresión regular sobre `CLIENTES.correo` |
| RN5 | La fecha de vencimiento de una membresía debe ser posterior a la fecha de inicio. | Restricción de datos | CHECK sobre `MEMBRESIAS` |
| RN6 | El monto de un pago debe ser mayor a cero. | Restricción de datos | CHECK sobre `PAGOS.monto` |
| RN7 | Solo se puede inscribir a una clase a clientes con membresía en estado `ACTIVA`. | Restricción de datos | Trigger sobre `INSCRIPCIONES` |

> **Cumplimiento del enunciado:** se incluyen más de tres reglas, dos relacionadas con restricciones de datos de una tabla (RN1, RN2, RN5, RN6) y al menos una sobre formato de datos (RN3, RN4).

---

### d) Conjunto de reportes

| ID | Reporte | Descripción | Tablas involucradas |
|----|---------|-------------|---------------------|
| R1 | **Clientes activos** | Listado de clientes con membresía vigente, ordenado por fecha de vencimiento. | CLIENTES, MEMBRESIAS, PLANES |
| R2 | **Membresías por vencer** | Clientes cuya membresía vence en los próximos 7 días. | CLIENTES, MEMBRESIAS |
| R3 | **Ingresos mensuales** | Total recaudado en pagos agrupado por mes, con conteo de transacciones. | PAGOS, MEMBRESIAS |
| R4 | **Clases más concurridas** | Top de clases con mayor número de inscritos en el mes. | CLASES, INSCRIPCIONES, ENTRENADORES |
| R5 | **Asistencia diaria** | Conteo de visitas al gimnasio por día. | ASISTENCIAS, CLIENTES |
| R6 | **Inscritos por entrenador** | Listado de clientes inscritos a clases de cada entrenador. | ENTRENADORES, CLASES, INSCRIPCIONES, CLIENTES |
| R7 | **Top clientes asiduos** | 10 clientes con mayor número de asistencias en el mes. | CLIENTES, ASISTENCIAS |

---

## 2. Estructura tentativa de tablas

> Esta sección es preliminar y se detallará en los modelos conceptual, lógico y físico en próximas entregas.

1. **CLIENTES** — datos personales de quienes se inscriben al gimnasio.
2. **PLANES** — catálogo de planes de membresía (mensual, trimestral, etc.) con precio y duración.
3. **MEMBRESIAS** — membresías compradas por los clientes (vínculo cliente–plan con fechas y estado).
4. **PAGOS** — pagos asociados a cada membresía.
5. **ENTRENADORES** — datos de los entrenadores del gimnasio.
6. **CLASES** — clases grupales del cronograma semanal.
7. **INSCRIPCIONES** — inscripciones de clientes a clases.
8. **ASISTENCIAS** — registro de cada entrada de cliente al gimnasio o a una clase.

Total: **8 tablas** (cumple el mínimo de 6 exigido por el enunciado).

---

## 3. Próximas entregas

- [ ] Modelo conceptual (Entidad–Relación)
- [ ] Modelo lógico en tercera forma normal (3FN)
- [ ] Modelo físico para Oracle 18c
- [ ] Script `DDL.sql` (estructura completa)
- [ ] Script `DATOS.sql` (datos de prueba)
- [ ] Creación de usuarios y asignación de privilegios
- [ ] Consultas SQL exigidas (condiciones, joins, agrupaciones, subconsultas)
- [ ] Implementación de las reglas de negocio (CHECK / Triggers)
