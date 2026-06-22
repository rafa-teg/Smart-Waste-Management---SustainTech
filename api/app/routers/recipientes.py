import oracledb
from fastapi import APIRouter, Depends

from ..db import get_connection
from ..schemas import RecipienteOut

router = APIRouter(prefix="/recipientes", tags=["recipientes"])


@router.get("", response_model=list[RecipienteOut])
def listar_recipientes(connection: oracledb.Connection = Depends(get_connection)) -> list[RecipienteOut]:
    cursor = connection.cursor()
    cursor.execute(
        "SELECT id_recipiente, localizacao, capacidade_max, capacidade_atual, t_agendamentos_id_agendamento "
        "FROM t_recipientes ORDER BY id_recipiente"
    )
    columns = [col[0].lower() for col in cursor.description]
    return [RecipienteOut.model_validate(dict(zip(columns, row))) for row in cursor]
