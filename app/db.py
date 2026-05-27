"""Helper de conexion a Oracle usando oracledb en modo thin."""

import oracledb

from config import ORACLE_HOST, ORACLE_PORT, ORACLE_SERVICE


def conectar(usuario_bd: str, password_bd: str):
    dsn = oracledb.makedsn(ORACLE_HOST, ORACLE_PORT, service_name=ORACLE_SERVICE)
    return oracledb.connect(user=usuario_bd, password=password_bd, dsn=dsn)
