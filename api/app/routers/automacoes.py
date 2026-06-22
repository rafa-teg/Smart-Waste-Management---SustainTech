import oracledb
from fastapi import APIRouter, Depends

from ..db import get_connection
from ..schemas import AcaoResponse

router = APIRouter(prefix="/automacoes", tags=["automacoes"])


@router.post("/agendar-coleta", response_model=AcaoResponse)
def agendar_coleta(connection: oracledb.Connection = Depends(get_connection)) -> AcaoResponse:
    cursor = connection.cursor()
    cursor.callproc("AgendarColetaAutomatica")
    return AcaoResponse(detail="Agendamento automatico de coleta executado.")


@router.post("/notificar-moradores", response_model=AcaoResponse)
def notificar_moradores(connection: oracledb.Connection = Depends(get_connection)) -> AcaoResponse:
    cursor = connection.cursor()
    cursor.callproc("NotificarMoradores")
    return AcaoResponse(detail="Notificacao de moradores executada.")


@router.post("/monitorar-incidentes", response_model=AcaoResponse)
def monitorar_incidentes(connection: oracledb.Connection = Depends(get_connection)) -> AcaoResponse:
    cursor = connection.cursor()
    cursor.callproc("MonitoraEIncidentes")
    return AcaoResponse(detail="Monitoramento de incidentes executado.")
