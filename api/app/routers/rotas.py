import oracledb
from fastapi import APIRouter, Depends

from ..db import get_connection
from ..schemas import RotaOut

router = APIRouter(prefix="/rotas", tags=["rotas"])


@router.get("", response_model=list[RotaOut])
def listar_rotas(connection: oracledb.Connection = Depends(get_connection)) -> list[RotaOut]:
    cursor = connection.cursor()
    cursor.execute(
        "SELECT id_rota, dt_hora_inicio, dt_hora_fim, status_rota, t_caminhoes_id_caminhao "
        "FROM t_rotas ORDER BY id_rota"
    )
    columns = [col[0].lower() for col in cursor.description]
    return [RotaOut.model_validate(dict(zip(columns, row))) for row in cursor]
