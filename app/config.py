"""Configuracion de conexion a Oracle para Power Gym."""

ORACLE_HOST = "localhost"
ORACLE_PORT = 1521
ORACLE_SERVICE = "XEPDB1"

PERFILES = {
    "RECEPCIONISTA": {
        "usuario_bd": "user_recepcion",
        "password_bd": "Recep_2026!",
    },
    "ENTRENADOR": {
        "usuario_bd": "user_entrenador",
        "password_bd": "Entren_2026!",
    },
}
