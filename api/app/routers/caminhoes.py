import oracledb
from fastapi import APIRouter, Depends

from ..db import get_connection
from ..schemas import AcaoResponse, AtualizarRotaRequest, CaminhaoOut

router = APIRouter(prefix="/caminhoes", tags=["caminhoes"])


@router.get("", response_model=list[CaminhaoOut])
def listar_caminhoes(connection: oracledb.Connection = Depends(get_connection)) -> list[CaminhaoOut]:
    cursor = connection.cursor()
    cursor.execute(
        "SELECT id_caminhao, placa, modelo, capacidade, status FROM t_caminhoes ORDER BY id_caminhao"
    )
    columns = [col[0].lower() for col in cursor.description]
    return [CaminhaoOut.model_validate(dict(zip(columns, row))) for row in cursor]


@router.post("/{id_caminhao}/atualizar-rota", response_model=AcaoResponse)
def atualizar_rota(
    id_caminhao: int,
    payload: AtualizarRotaRequest,
    connection: oracledb.Connection = Depends(get_connection),
) -> AcaoResponse:
    cursor = connection.cursor()
    cursor.callproc("AtualizarRota", [id_caminhao, payload.nova_localizacao, payload.status_rota])
    return AcaoResponse(detail=f"Rota do caminhao {id_caminhao} atualizada para '{payload.status_rota}'.")
