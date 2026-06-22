import oracledb
from fastapi import Request
from fastapi.responses import JSONResponse

# Mapeia o codigo de erro ORA-XXXXX (exc.args[0].code, numerico) para o status HTTP equivalente.
_STATUS_BY_ORA_CODE = {
    20001: 404,  # AtualizarRota: nenhuma rota em execucao para o caminhao informado
    1: 409,  # unique constraint violated
    2291: 409,  # integrity constraint violated (FK)
    1017: 503,  # invalid username/password
    12154: 503,  # TNS: could not resolve the connect identifier
    12541: 503,  # TNS: no listener
}


def oracle_error_handler(request: Request, exc: oracledb.DatabaseError) -> JSONResponse:
    error_obj = exc.args[0] if exc.args else None
    code = getattr(error_obj, "code", None)
    full_code = getattr(error_obj, "full_code", "") or ""
    message = getattr(error_obj, "message", str(exc))

    if full_code.startswith("DPY-"):
        # Erro client-side do driver (conexao recusada, pool indisponivel, etc.) -- o
        # atributo .code numerico vem zerado nesses casos, o identificador real e o
        # full_code. Sempre um problema de infraestrutura, nao de logica de negocio.
        status_code = 503
    else:
        status_code = _STATUS_BY_ORA_CODE.get(code, 500)

    return JSONResponse(status_code=status_code, content={"detail": message})
