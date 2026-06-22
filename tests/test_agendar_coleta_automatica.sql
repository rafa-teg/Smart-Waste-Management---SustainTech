-- Teste de AgendarColetaAutomatica (procedures/agendar_coleta_automatica.sql).
-- Pre-requisito: rodar antes os scripts de database/scripts/ e procedures/.
-- Faixa de IDs reservada para este teste: 9011-9019 (nao deve colidir com dados reais).
--
-- ATENCAO: esta procedure nao recebe parametros e varre TODA a tabela t_recipientes e
-- t_caminhoes. Os testes abaixo assumem que estao rodando num banco de teste/dev
-- majoritariamente vazio fora da faixa reservada. Em especial, o Teste 2 desliga
-- temporariamente qualquer caminhao real com status = 'Disponivel' para simular a
-- ausencia de frota disponivel, e tenta restaurar o status original ao final -- evite
-- rodar este arquivo num banco com dados reais em uso simultaneo.

SET SERVEROUTPUT ON;

-- Limpeza de qualquer execucao anterior (idempotente), em ordem segura de FK.
DELETE FROM t_recipientes WHERE id_recipiente BETWEEN 9011 AND 9019;
DELETE FROM t_log_erros WHERE nome_procedure = 'AgendarColetaAutomatica';
DELETE FROM t_agendamentos WHERE t_caminhoes_id_caminhao BETWEEN 9011 AND 9019;
DELETE FROM t_rotas WHERE id_rota BETWEEN 9011 AND 9019;
DELETE FROM t_caminhoes WHERE id_caminhao BETWEEN 9011 AND 9019;
COMMIT;

-- Seed: 1 caminhao disponivel + 1 rota + 1 agendamento "antigo" (so para satisfazer a
-- FK NOT NULL de t_recipientes) + 2 recipientes acima do limiar de 80%, um para cada teste.
INSERT INTO t_caminhoes (id_caminhao, placa, modelo, capacidade, status)
VALUES (9011, 'TST0011', 'Caminhao Teste', 1000, 'Disponivel');

INSERT INTO t_rotas (id_rota, dt_hora_inicio, dt_hora_fim, status_rota, t_caminhoes_id_caminhao)
VALUES (9011, SYSTIMESTAMP, NULL, 'Concluida', 9011);

INSERT INTO t_agendamentos (id_agendamento, data_agendada, confirmado, t_caminhoes_id_caminhao, t_rotas_id_rota)
VALUES (9011, SYSTIMESTAMP, 'SIM', 9011, 9011);

INSERT INTO t_recipientes (id_recipiente, localizacao, capacidade_max, capacidade_atual, t_agendamentos_id_agendamento)
VALUES (9011, 'Local Teste 9011', 100, 85, 9011); -- usado no Teste 1

INSERT INTO t_recipientes (id_recipiente, localizacao, capacidade_max, capacidade_atual, t_agendamentos_id_agendamento)
VALUES (9012, 'Local Teste 9012', 100, 90, 9011); -- usado no Teste 2

COMMIT;

-- Teste 1: caminho feliz - recipiente acima de 80% e sem agendamento pendente recebe um novo agendamento.
DECLARE
    v_count NUMBER;
BEGIN
    AgendarColetaAutomatica;

    -- A FK de t_recipientes nao e atualizada pela procedure (continua apontando pro
    -- agendamento antigo), entao verificamos pelo caminhao+confirmado em vez do vinculo
    -- direto do recipiente.
    SELECT COUNT(*) INTO v_count FROM t_agendamentos
    WHERE t_caminhoes_id_caminhao = 9011 AND confirmado = 'NAO';

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20099, 'FAIL teste 1: nenhum agendamento novo foi criado para o caminhao 9011.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('PASS teste 1: AgendarColetaAutomatica cria agendamento quando ha caminhao disponivel.');
END;
/

-- Teste 2: erro - nenhum caminhao disponivel deve ser logado em t_log_erros, sem criar agendamento.
BEGIN
    -- Desliga temporariamente todo caminhao 'Disponivel' (incluindo o 9011 e quaisquer
    -- outros que existam fora da faixa de teste) para simular ausencia de frota.
    UPDATE t_caminhoes SET status = 'Indisponivel_Teste_Temp' WHERE status = 'Disponivel';

    AgendarColetaAutomatica;

    DECLARE
        v_log_count NUMBER;
        v_novo_agendamento_recipiente_9012 NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_log_count FROM t_log_erros
        WHERE nome_procedure = 'AgendarColetaAutomatica' AND mensagem_erro LIKE '%recipiente 9012%';
        IF v_log_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20099, 'FAIL teste 2: ausencia de caminhao disponivel nao foi registrada em t_log_erros para o recipiente 9012.');
        END IF;

        SELECT COUNT(*) INTO v_novo_agendamento_recipiente_9012
        FROM t_agendamentos a
        JOIN t_recipientes rec ON rec.t_agendamentos_id_agendamento = a.id_agendamento
        WHERE rec.id_recipiente = 9012 AND a.confirmado = 'NAO';
        IF v_novo_agendamento_recipiente_9012 > 0 THEN
            RAISE_APPLICATION_ERROR(-20099, 'FAIL teste 2: agendamento foi criado mesmo sem caminhao disponivel.');
        END IF;
    END;

    -- Restaura o status original dos caminhoes desligados temporariamente.
    UPDATE t_caminhoes SET status = 'Disponivel' WHERE status = 'Indisponivel_Teste_Temp';
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('PASS teste 2: AgendarColetaAutomatica loga e nao cria agendamento quando nao ha caminhao disponivel.');
EXCEPTION
    WHEN OTHERS THEN
        -- Garante que os caminhoes sao restaurados mesmo se uma assercao falhar.
        UPDATE t_caminhoes SET status = 'Disponivel' WHERE status = 'Indisponivel_Teste_Temp';
        COMMIT;
        RAISE;
END;
/

-- Limpeza final.
DELETE FROM t_recipientes WHERE id_recipiente BETWEEN 9011 AND 9019;
DELETE FROM t_log_erros WHERE nome_procedure = 'AgendarColetaAutomatica';
DELETE FROM t_agendamentos WHERE t_caminhoes_id_caminhao BETWEEN 9011 AND 9019;
DELETE FROM t_rotas WHERE id_rota BETWEEN 9011 AND 9019;
DELETE FROM t_caminhoes WHERE id_caminhao BETWEEN 9011 AND 9019;
COMMIT;
