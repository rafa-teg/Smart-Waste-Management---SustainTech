from collections.abc import Generator
from contextlib import asynccontextmanager

import oracledb
from fastapi import FastAPI

from .config import settings

pool: oracledb.ConnectionPool | None = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global pool
    pool = oracledb.create_pool(
        user=settings.oracle_user,
        password=settings.oracle_password,
        dsn=settings.oracle_dsn,
        min=1,
        max=5,
        increment=1,
    )
    yield
    pool.close()


def get_connection() -> Generator[oracledb.Connection, None, None]:
    connection = pool.acquire()
    try:
        yield connection
    finally:
        connection.close()
