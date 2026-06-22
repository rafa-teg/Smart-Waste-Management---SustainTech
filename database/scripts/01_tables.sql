CREATE TABLE t_agendamentos (
    id_agendamento          INTEGER NOT NULL,
    data_agendada           TIMESTAMP WITH LOCAL TIME ZONE,
    confirmado              CHAR(3),
    t_caminhoes_id_caminhao INTEGER NOT NULL,
    t_rotas_id_rota         INTEGER NOT NULL
);

ALTER TABLE t_agendamentos ADD CONSTRAINT t_agendamentos_pk PRIMARY KEY ( id_agendamento );

CREATE TABLE t_caminhoes (
    id_caminhao INTEGER NOT NULL,
    placa       VARCHAR2(10) NOT NULL,
    modelo      VARCHAR2(50),
    capacidade  NUMBER NOT NULL,
    status      VARCHAR2(20) NOT NULL
);

ALTER TABLE t_caminhoes ADD CONSTRAINT t_caminhoes_pk PRIMARY KEY ( id_caminhao );

CREATE TABLE t_coletas (
    t_caminhoes_id_caminhao     INTEGER NOT NULL,
    t_recipientes_id_recipiente INTEGER NOT NULL
);

ALTER TABLE t_coletas ADD CONSTRAINT relation_5_pk PRIMARY KEY ( t_caminhoes_id_caminhao,
                                                                 t_recipientes_id_recipiente );

CREATE TABLE t_notificacoes (
    id_notificacao          INTEGER NOT NULL,
    tipo_notificacao        VARCHAR2(50) NOT NULL,
    mensagem                VARCHAR2(55) NOT NULL,
    data_hora_envio         TIMESTAMP WITH LOCAL TIME ZONE NOT NULL,
    t_caminhoes_id_caminhao INTEGER,
    t_rotas_id_rota         INTEGER NOT NULL
);

ALTER TABLE t_notificacoes ADD CONSTRAINT t_notificacoes_pk PRIMARY KEY ( id_notificacao );

CREATE TABLE t_recipientes (
    id_recipiente                 INTEGER NOT NULL,
    localizacao                   VARCHAR2(100) NOT NULL,
    capacidade_max                NUMBER NOT NULL,
    capacidade_atual              NUMBER NOT NULL,
    t_agendamentos_id_agendamento INTEGER NOT NULL
);

ALTER TABLE t_recipientes ADD CONSTRAINT t_recipientes_pk PRIMARY KEY ( id_recipiente );

CREATE TABLE t_rota_recipiente (
    t_rotas_id_rota             INTEGER NOT NULL,
    t_recipientes_id_recipiente INTEGER NOT NULL
);

ALTER TABLE t_rota_recipiente ADD CONSTRAINT relation_9_pk PRIMARY KEY ( t_rotas_id_rota,
                                                                         t_recipientes_id_recipiente );

CREATE TABLE t_rotas (
    id_rota                 INTEGER NOT NULL,
    dt_hora_inicio          TIMESTAMP WITH LOCAL TIME ZONE,
    dt_hora_fim             TIMESTAMP WITH LOCAL TIME ZONE,
    status_rota             NVARCHAR2(20),
    t_caminhoes_id_caminhao INTEGER NOT NULL
);

ALTER TABLE t_rotas ADD CONSTRAINT t_rotas_pk PRIMARY KEY ( id_rota );
