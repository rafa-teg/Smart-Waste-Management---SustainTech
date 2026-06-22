from datetime import datetime

from pydantic import BaseModel, ConfigDict


class AtualizarRotaRequest(BaseModel):
    nova_localizacao: str
    status_rota: str


class AcaoResponse(BaseModel):
    detail: str


class CaminhaoOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_caminhao: int
    placa: str
    modelo: str | None = None
    capacidade: float
    status: str


class RotaOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_rota: int
    dt_hora_inicio: datetime | None = None
    dt_hora_fim: datetime | None = None
    status_rota: str | None = None
    t_caminhoes_id_caminhao: int


class RecipienteOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_recipiente: int
    localizacao: str
    capacidade_max: float
    capacidade_atual: float
    t_agendamentos_id_agendamento: int


class LogErroOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_log: int
    nome_procedure: str
    mensagem_erro: str
    stack_trace: str | None = None
    data_hora: datetime
