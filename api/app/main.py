import oracledb
from fastapi import FastAPI

from .db import lifespan
from .errors import oracle_error_handler
from .routers import automacoes, caminhoes, logs_erros, recipientes, rotas

app = FastAPI(title="Smart Waste Management API", lifespan=lifespan)

app.add_exception_handler(oracledb.DatabaseError, oracle_error_handler)

app.include_router(automacoes.router)
app.include_router(caminhoes.router)
app.include_router(rotas.router)
app.include_router(recipientes.router)
app.include_router(logs_erros.router)
