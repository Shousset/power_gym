# Power Gym — Modelo Relacional (Lógico, 3FN)

**Proyecto:** Power Gym
**Entrega:** Modelo lógico de la base de datos en Tercera Forma Normal
**Autor:** Samuel Benavides Housset

---

## 1. Esquema relacional

> Notación: **PK** = Clave primaria, **FK** = Clave foránea, **UK** = Restricción de unicidad, **NN** = NOT NULL.

### 1.1. CLIENTE
```
CLIENTE (
    id_cliente            INT          PK,
    cedula                VARCHAR(15)  UK NN,
    nombre                VARCHAR(50)  NN,
    apellido              VARCHAR(50)  NN,
    fecha_nacimiento      DATE         NN,
    telefono              VARCHAR(10)  NN,
    correo                VARCHAR(100) NN,
    direccion             VARCHAR(150),
    contacto_emergencia   VARCHAR(100),
    telefono_emergencia   VARCHAR(10),
    fecha_registro        DATE         NN
)
```

### 1.2. PLAN
```
PLAN (
    id_plan        INT           PK,
    nombre         VARCHAR(50)   NN,
    descripcion    VARCHAR(200),
    duracion_dias  INT           NN,
    precio         DECIMAL(10,2) NN
)
```

### 1.3. MEMBRESIA
```
MEMBRESIA (
    id_membresia       INT          PK,
    id_cliente         INT          FK -> CLIENTE(id_cliente)  NN,
    id_plan            INT          FK -> PLAN(id_plan)        NN,
    fecha_inicio       DATE         NN,
    fecha_vencimiento  DATE         NN,
    estado             VARCHAR(15)  NN  -- ACTIVA / VENCIDA / SUSPENDIDA
)
```

### 1.4. PAGO
```
PAGO (
    id_pago        INT           PK,
    id_membresia   INT           FK -> MEMBRESIA(id_membresia)  NN,
    fecha_pago     DATE          NN,
    monto          DECIMAL(10,2) NN,
    metodo_pago    VARCHAR(15)   NN  -- EFECTIVO / TARJETA / TRANSFERENCIA
)
```

### 1.5. ENTRENADOR
```
ENTRENADOR (
    id_entrenador        INT           PK,
    cedula               VARCHAR(15)   UK NN,
    nombre               VARCHAR(50)   NN,
    apellido             VARCHAR(50)   NN,
    especialidad         VARCHAR(50)   NN,
    telefono             VARCHAR(10)   NN,
    fecha_contratacion   DATE          NN,
    salario              DECIMAL(10,2) NN
)
```

### 1.6. CLASE
```
CLASE (
    id_clase        INT          PK,
    id_entrenador   INT          FK -> ENTRENADOR(id_entrenador)  NN,
    nombre          VARCHAR(50)  NN,
    descripcion     VARCHAR(200),
    dia_semana      VARCHAR(10)  NN,  -- LUNES, MARTES, ..., DOMINGO
    hora_inicio     VARCHAR(5)   NN,  -- HH:MM
    hora_fin        VARCHAR(5)   NN,
    cupo_maximo     INT          NN
)
```

### 1.7. INSCRIPCION
```
INSCRIPCION (
    id_inscripcion      INT          PK,
    id_cliente          INT          FK -> CLIENTE(id_cliente)  NN,
    id_clase            INT          FK -> CLASE(id_clase)      NN,
    fecha_inscripcion   DATE         NN,
    estado              VARCHAR(15)  NN,  -- ACTIVA / CANCELADA
    UNIQUE(id_cliente, id_clase)
)
```

### 1.8. ASISTENCIA
```
ASISTENCIA (
    id_asistencia      INT         PK,
    id_cliente         INT         FK -> CLIENTE(id_cliente)  NN,
    id_clase           INT         FK -> CLASE(id_clase)      NULL,
    fecha_asistencia   DATE        NN,
    hora_entrada       VARCHAR(5)  NN
)
```

---

## 2. Diagrama de relaciones (claves foráneas)

```
CLIENTE (id_cliente) ──┬──< MEMBRESIA (id_cliente)
                       ├──< INSCRIPCION (id_cliente)
                       └──< ASISTENCIA (id_cliente)

PLAN (id_plan) ────────────< MEMBRESIA (id_plan)

MEMBRESIA (id_membresia) ──< PAGO (id_membresia)

ENTRENADOR (id_entrenador)─< CLASE (id_entrenador)

CLASE (id_clase) ──────┬──< INSCRIPCION (id_clase)
                       └──< ASISTENCIA (id_clase)  [opcional]
```

---

## 3. Verificación de las formas normales

### 3.1. Primera Forma Normal (1FN)
> *Todos los atributos deben ser atómicos (no compuestos ni multivaluados).*

| Tabla | Cumplimiento | Observación |
|-------|--------------|-------------|
| CLIENTE | ✓ | `direccion` se trata como cadena atómica; no se subdivide en calle/ciudad/etc. en este alcance. |
| PLAN | ✓ | Todos los atributos son atómicos. |
| MEMBRESIA | ✓ | Atributos atómicos. |
| PAGO | ✓ | Atributos atómicos. |
| ENTRENADOR | ✓ | Atributos atómicos. |
| CLASE | ✓ | `dia_semana` es valor único; cada clase es una sesión semanal específica. |
| INSCRIPCION | ✓ | Atributos atómicos. |
| ASISTENCIA | ✓ | Atributos atómicos. |

### 3.2. Segunda Forma Normal (2FN)
> *Estar en 1FN y que cada atributo no clave dependa de la clave primaria completa.*

Todas las tablas usan **claves primarias simples** (identificadores sustitutos), por lo que la 2FN se cumple automáticamente: no existen dependencias parciales porque no hay claves compuestas.

### 3.3. Tercera Forma Normal (3FN)
> *Estar en 2FN y que ningún atributo no clave dependa transitivamente de la clave primaria.*

Análisis de dependencias transitivas:

| Tabla | Atributos | ¿Hay dependencia transitiva? |
|-------|-----------|------------------------------|
| CLIENTE | Todos los atributos describen directamente al cliente identificado por `id_cliente`. | No |
| PLAN | `precio` y `duracion_dias` dependen del plan, no de otro atributo. | No |
| MEMBRESIA | `fecha_inicio`, `fecha_vencimiento`, `estado` dependen de la membresía. El **precio NO se almacena aquí** (se obtiene vía JOIN con PLAN), evitando dependencia transitiva `id_membresia → id_plan → precio`. | No |
| PAGO | `monto`, `fecha_pago`, `metodo_pago` dependen del pago. | No |
| ENTRENADOR | Atributos describen directamente al entrenador. | No |
| CLASE | `dia_semana`, `hora_inicio`, `hora_fin`, `cupo_maximo` dependen de la clase. El nombre del entrenador NO se duplica aquí (se accede por FK). | No |
| INSCRIPCION | `fecha_inscripcion` y `estado` dependen de la inscripción. | No |
| ASISTENCIA | `fecha_asistencia` y `hora_entrada` dependen de la asistencia. | No |

**Conclusión:** todas las tablas cumplen la **Tercera Forma Normal**.

---

## 4. Restricciones de integridad

### 4.1. Integridad de entidad
- Toda tabla tiene una PK definida (`id_*` numérico).

### 4.2. Integridad referencial
| FK | Tabla | Referencia | Acción ON DELETE |
|----|-------|------------|-------------------|
| `id_cliente` | MEMBRESIA | CLIENTE | RESTRICT |
| `id_plan` | MEMBRESIA | PLAN | RESTRICT |
| `id_membresia` | PAGO | MEMBRESIA | RESTRICT |
| `id_entrenador` | CLASE | ENTRENADOR | RESTRICT |
| `id_cliente` | INSCRIPCION | CLIENTE | RESTRICT |
| `id_clase` | INSCRIPCION | CLASE | RESTRICT |
| `id_cliente` | ASISTENCIA | CLIENTE | RESTRICT |
| `id_clase` | ASISTENCIA | CLASE | SET NULL |

### 4.3. Integridad de dominio (CHECKs)
| Tabla | Restricción |
|-------|-------------|
| CLIENTE | `telefono` debe tener exactamente 10 dígitos (RN3). |
| CLIENTE | `correo` debe contener `@` y un dominio válido (RN4). |
| MEMBRESIA | `fecha_vencimiento > fecha_inicio` (RN5). |
| MEMBRESIA | `estado IN ('ACTIVA', 'VENCIDA', 'SUSPENDIDA')`. |
| PAGO | `monto > 0` (RN6). |
| PAGO | `metodo_pago IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA')`. |
| CLASE | `cupo_maximo > 0`. |
| CLASE | `dia_semana IN ('LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO','DOMINGO')`. |
| INSCRIPCION | `estado IN ('ACTIVA', 'CANCELADA')`. |
| INSCRIPCION | UNIQUE (`id_cliente`, `id_clase`) — no se permite duplicar inscripción de un cliente en la misma clase. |

### 4.4. Reglas de negocio que requieren Trigger
- **RN1** — un cliente solo puede tener una MEMBRESIA con `estado = 'ACTIVA'`. Trigger BEFORE INSERT/UPDATE en MEMBRESIA.
- **RN2** — `COUNT(INSCRIPCION activas por clase) ≤ CLASE.cupo_maximo`. Trigger BEFORE INSERT en INSCRIPCION.
- **RN7** — al insertar en INSCRIPCION, validar que el cliente tenga MEMBRESIA activa vigente.

---

## 5. Resumen de tablas

| # | Tabla | PK | FKs | # atributos |
|---|-------|----|----|-------------|
| 1 | CLIENTE | id_cliente | — | 11 |
| 2 | PLAN | id_plan | — | 5 |
| 3 | MEMBRESIA | id_membresia | id_cliente, id_plan | 6 |
| 4 | PAGO | id_pago | id_membresia | 5 |
| 5 | ENTRENADOR | id_entrenador | — | 8 |
| 6 | CLASE | id_clase | id_entrenador | 8 |
| 7 | INSCRIPCION | id_inscripcion | id_cliente, id_clase | 5 |
| 8 | ASISTENCIA | id_asistencia | id_cliente, id_clase | 5 |

**Total: 8 tablas** — cumple el mínimo de 6 exigido por el enunciado.

---

## 6. Próximo paso

- Traducción del modelo lógico al **modelo físico en Oracle 18c**: tipos de datos Oracle (`NUMBER`, `VARCHAR2`, `DATE`), secuencias para IDs, sintaxis exacta de CHECK/FK, y construcción del script `DDL.sql`.
