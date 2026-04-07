

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

ALTER TABLE t_coletas
    ADD CONSTRAINT relation_5_t_caminhoes_fk FOREIGN KEY ( t_caminhoes_id_caminhao )
        REFERENCES t_caminhoes ( id_caminhao );

ALTER TABLE t_coletas
    ADD CONSTRAINT relation_5_t_recipientes_fk FOREIGN KEY ( t_recipientes_id_recipiente )
        REFERENCES t_recipientes ( id_recipiente );

ALTER TABLE t_rota_recipiente
    ADD CONSTRAINT relation_9_t_recipientes_fk FOREIGN KEY ( t_recipientes_id_recipiente )
        REFERENCES t_recipientes ( id_recipiente );

ALTER TABLE t_rota_recipiente
    ADD CONSTRAINT relation_9_t_rotas_fk FOREIGN KEY ( t_rotas_id_rota )
        REFERENCES t_rotas ( id_rota );

ALTER TABLE t_agendamentos
    ADD CONSTRAINT t_agendamentos_t_caminhoes_fk FOREIGN KEY ( t_caminhoes_id_caminhao )
        REFERENCES t_caminhoes ( id_caminhao );

ALTER TABLE t_agendamentos
    ADD CONSTRAINT t_agendamentos_t_rotas_fk FOREIGN KEY ( t_rotas_id_rota )
        REFERENCES t_rotas ( id_rota );

ALTER TABLE t_notificacoes
    ADD CONSTRAINT t_notificacoes_t_caminhoes_fk FOREIGN KEY ( t_caminhoes_id_caminhao )
        REFERENCES t_caminhoes ( id_caminhao );

ALTER TABLE t_notificacoes
    ADD CONSTRAINT t_notificacoes_t_rotas_fk FOREIGN KEY ( t_rotas_id_rota )
        REFERENCES t_rotas ( id_rota );

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE t_recipientes
    ADD CONSTRAINT t_recipientes_t_agendamentos_fk FOREIGN KEY ( t_agendamentos_id_agendamento )
        REFERENCES t_agendamentos ( id_agendamento );

ALTER TABLE t_rotas
    ADD CONSTRAINT t_rotas_t_caminhoes_fk FOREIGN KEY ( t_caminhoes_id_caminhao )
        REFERENCES t_caminhoes ( id_caminhao );
        
-- Removendo a FK antiga para substituir pelo nome novo dentro do limite
ALTER TABLE t_recipientes DROP CONSTRAINT t_recipientes_t_agendamentos_fk;

-- Adicionando a FK novamente com um nome dentro do limite permitido
ALTER TABLE t_recipientes
    ADD CONSTRAINT rec_agend_fk FOREIGN KEY (t_agendamentos_id_agendamento)
        REFERENCES t_agendamentos (id_agendamento);

-- AUTOMATIZA  ES

--DESCS
DESC T_AGENDAMENTOS;
DESC 


--ATIVIDADE 1 - PRIMEIRA AUTOMATIZACAO - Criacao do Procedimento para Atualizar a Localizacao  do Caminhao e Otimizar Rotas
CREATE OR REPLACE PROCEDURE AtualizarRota(
    p_id_caminhao IN t_caminhoes.id_caminhao%TYPE,
    p_nova_localizacao IN VARCHAR2,
    p_status_rota IN t_rotas.status_rota%TYPE)
IS
    v_id_rota t_rotas.id_rota%TYPE;
BEGIN
    -- Encontrar a rota atual do caminhao
    SELECT id_rota INTO v_id_rota FROM t_rotas WHERE t_caminhoes_id_caminhao = p_id_caminhao AND status_rota = 'Em execu�ao';
    
    -- Atualizar a localizacao e status da rota
    UPDATE t_rotas
    SET dt_hora_inicio = SYSTIMESTAMP, -- Atualizando o timestamp para indicar o tempo real da localiza  o
        status_rota = p_status_rota
    WHERE id_rota = v_id_rota;

    -- Verificar se h  necessidade de otimiza  o de rota
    -- Aqui poderia ser integrado um algoritmo de otimiza  o de rotas, atualizando a rota conforme necess rio
    
    -- Registrar a opera  o de atualiza  o
    INSERT INTO t_notificacoes (id_notificacao, tipo_notificacao, mensagem, data_hora_envio, t_rotas_id_rota)
    VALUES (seq_notificacao.NEXTVAL, 'Atualiza  o de Rota', 'Rota atualizada para o caminh o ' || p_id_caminhao, SYSTIMESTAMP, v_id_rota);

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nenhuma rota encontrada para este caminh o.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, SQLERRM);
END AtualizarRota;

--ATIVIDADE 2 - SEGUNDA AUTOMATIZACAO  - AGENDAR COLETA AUTOMaTICA
CREATE OR REPLACE PROCEDURE AgendarColetaAutomatica AS
BEGIN
    FOR r IN (SELECT id_recipiente, capacidade_atual, capacidade_max FROM t_recipientes)
    LOOP
        -- Verificar se a capacidade atual excede 80% da capacidade m xima
        IF r.capacidade_atual >= 0.8 * r.capacidade_max THEN
            -- Verificar se j  existe um agendamento pendente para este recipiente
            DECLARE
                v_count NUMBER;
            BEGIN
                SELECT COUNT(*) INTO v_count FROM t_agendamentos
                WHERE t_recipientes_id_agendamento = r.id_recipiente
                AND confirmado = 'N O'; -- Supondo que 'confirmado' tenha 'SIM' ou 'N O'
                
                IF v_count = 0 THEN
                    -- Inserir um novo agendamento se n o houver agendamentos pendentes
                    INSERT INTO t_agendamentos (id_agendamento, data_agendada, confirmado, t_caminhoes_id_caminhao, t_rotas_id_rota)
                    VALUES (seq_agendamento.NEXTVAL, SYSTIMESTAMP + INTERVAL '1' DAY, 'N O', -- Alocar o pr ximo dia
                            (SELECT id_caminhao FROM t_caminhoes WHERE status = 'Dispon vel' AND ROWNUM = 1), -- Exemplo simples de aloca  o de caminh o
                            (SELECT id_rota FROM t_rotas WHERE t_caminhoes_id_caminhao = id_caminhao AND ROWNUM = 1)); -- Exemplo simples de aloca  o de rota
                    COMMIT;
                END IF;
            END;
        END IF;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        -- Log de erro
        DBMS_OUTPUT.PUT_LINE('Erro durante a automa  o de agendamento: ' || SQLERRM);
        ROLLBACK;
END AgendarColetaAutomatica;


--ATIVIDADE 3 - TERCEIRA AUTOMATIZACAO - Notificacao aos Moradores
CREATE OR REPLACE PROCEDURE NotificarMoradores IS
BEGIN
    FOR agendamento IN (
        SELECT a.id_agendamento, a.data_agendada, r.t_caminhoes_id_caminhao, r.t_rotas_id_rota
        FROM t_agendamentos a
        JOIN t_rotas r ON a.t_rotas_id_rota = r.id_rota
        WHERE a.confirmado = 'SIM' AND NOT EXISTS (
            SELECT 1 FROM t_notificacoes n WHERE n.t_agendamentos_id_agendamento = a.id_agendamento
        )
    )
    LOOP
        -- Criar a mensagem de notifica  o
        DECLARE
            v_mensagem VARCHAR2(255);
        BEGIN
            v_mensagem := 'Lembrete: A coleta de res duos acontecer  em ' || TO_CHAR(agendamento.data_agendada, 'DD/MM/YYYY') ||
                          '. Por favor, certifique-se de separar recicl veis e n o recicl veis conforme instru do.';
                          
            -- Inserir a notifica  o na tabela t_notificacoes
            INSERT INTO t_notificacoes (id_notificacao, tipo_notificacao, mensagem, data_hora_envio, t_caminhoes_id_caminhao, t_rotas_id_rota)
            VALUES (seq_notificacao.NEXTVAL, 'Dia de Coleta', v_mensagem, SYSTIMESTAMP, agendamento.t_caminhoes_id_caminhao, agendamento.t_rotas_id_rota);
            
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Erro ao enviar notifica  o: ' || SQLERRM);
                ROLLBACK;
        END;
    END LOOP;
END NotificarMoradores;


--ATIVIDADE 4 - QUARTA AUTOMATIZACAO -- Monitoramento e Resposta Automatizados para Incidentes Durante a Coleta 

CREATE OR REPLACE PROCEDURE MonitoraEIncidentes IS
BEGIN
    FOR caminhao IN (SELECT id_caminhao, status FROM t_caminhoes WHERE status IN ('Avariado', 'Atrasado'))
    LOOP
        FOR rota IN (SELECT id_rota FROM t_rotas WHERE t_caminhoes_id_caminhao = caminhao.id_caminhao AND status_rota = 'Em execu  o')
        LOOP
            -- Gerar uma mensagem de notifica  o para gest o de frota
            INSERT INTO t_notificacoes (id_notificacao, tipo_notificacao, mensagem, data_hora_envio, t_caminhoes_id_caminhao, t_rotas_id_rota)
            VALUES (seq_notificacao.NEXTVAL, 'Incidente', 'O caminh o com ID ' || caminhao.id_caminhao || 
                    ' est  ' || LOWER(caminhao.status) || ' na rota ' || rota.id_rota || '.', SYSTIMESTAMP, caminhao.id_caminhao, rota.id_rota);

            -- Atualizar o status da rota para refletir o incidente
            UPDATE t_rotas SET status_rota = 'Interrumpida por incidente' WHERE id_rota = rota.id_rota;
        END LOOP;

        -- Notificar moradores se aplic vel (simula  o de uma l gica mais complexa)
        -- Supondo que temos uma forma de identificar os moradores afetados, o que geralmente seria mais complexo e poderia necessitar de uma tabela associativa
        INSERT INTO t_notificacoes (id_notificacao, tipo_notificacao, mensagem, data_hora_envio, t_caminhoes_id_caminhao, t_rotas_id_rota)
        VALUES (seq_notificacao.NEXTVAL, 'Altera  o de Coleta', 'A coleta foi alterada devido a um incidente. Pedimos desculpas pelo inconveniente.', SYSTIMESTAMP, caminhao.id_caminhao, NULL);
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Log de erro
        DBMS_OUTPUT.PUT_LINE('Erro durante o monitoramento de incidentes: ' || SQLERRM);
        ROLLBACK;
END MonitoraEIncidentes;

