import oracledb
from fastapi import APIRouter, Depends, Query

from ..db import get_connection
from ..schemas import LogErroOut

router = APIRouter(prefix="/logs-erros", tags=["logs-erros"])


@router.get("", response_model=list[LogErroOut])
def listar_logs_erros(
    limit: int = Query(50, ge=1, le=500),
    connection: oracledb.Connection = Depends(get_connection),
) -> list[LogErroOut]:
    cursor = connection.cursor()
    cursor.execute(
        "SELECT id_log, nome_procedure, mensagem_erro, stack_trace, data_hora "
        "FROM t_log_erros ORDER BY data_hora DESC FETCH FIRST :limit ROWS ONLY",
        {"limit": limit},
    )
    columns = [col[0].lower() for col in cursor.description]
    return [LogErroOut.model_validate(dict(zip(columns, row))) for row in cursor]
