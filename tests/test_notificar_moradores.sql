-- Teste de NotificarMoradores (procedures/notificar_moradores.sql).
-- Pre-requisito: rodar antes os scripts de database/scripts/ e procedures/.
-- Faixa de IDs reservada para este teste: 9021-9029 (nao deve colidir com dados reais).

SET SERVEROUTPUT ON;

-- Limpeza de qualquer execucao anterior (idempotente), em ordem segura de FK.
DELETE FROM t_notificacoes WHERE t_rotas_id_rota BETWEEN 9021 AND 9029;
DELETE FROM t_agendamentos WHERE id_agendamento BETWEEN 9021 AND 9029;
DELETE FROM t_rotas WHERE id_rota BETWEEN 9021 AND 9029;
DELETE FROM t_caminhoes WHERE id_caminhao BETWEEN 9021 AND 9029;
COMMIT;

-- Seed: 1 caminhao + 1 rota + 1 agendamento confirmado.
INSERT INTO t_caminhoes (id_caminhao, placa, modelo, capacidade, status)
VALUES (9021, 'TST0021', 'Caminhao Teste', 1000, 'Disponivel');

INSERT INTO t_rotas (id_rota, dt_hora_inicio, dt_hora_fim, status_rota, t_caminhoes_id_caminhao)
VALUES (9021, NULL, NULL, 'Concluida', 9021);

INSERT INTO t_agendamentos (id_agendamento, data_agendada, confirmado, t_caminhoes_id_caminhao, t_rotas_id_rota)
VALUES (9021, SYSTIMESTAMP + 1, 'SIM', 9021, 9021);

COMMIT;

-- Teste 1: caminho feliz - agendamento confirmado gera notificacao "Dia de Coleta".
DECLARE
    v_count NUMBER;
BEGIN
    NotificarMoradores;

    SELECT COUNT(*) INTO v_count FROM t_notificacoes
    WHERE t_rotas_id_rota = 9021 AND t_caminhoes_id_caminhao = 9021 AND tipo_notificacao = 'Dia de Coleta';

    IF v_count != 1 THEN
        RAISE_APPLICATION_ERROR(-20099, 'FAIL teste 1: esperava 1 notificacao "Dia de Coleta", encontrou ' || v_count);
    END IF;

    DBMS_OUTPUT.PUT_LINE('PASS teste 1: NotificarMoradores cria notificacao para agendamento confirmado.');
END;
/

-- Teste 2: deduplicacao - chamar de novo nao deve criar uma segunda notificacao para a mesma rota/caminhao.
DECLARE
    v_count NUMBER;
BEGIN
    NotificarMoradores;

    SELECT COUNT(*) INTO v_count FROM t_notificacoes
    WHERE t_rotas_id_rota = 9021 AND t_caminhoes_id_caminhao = 9021 AND tipo_notificacao = 'Dia de Coleta';

    IF v_count != 1 THEN
        RAISE_APPLICATION_ERROR(-20099, 'FAIL teste 2: esperava continuar com 1 notificacao (sem duplicar), encontrou ' || v_count);
    END IF;

    DBMS_OUTPUT.PUT_LINE('PASS teste 2: NotificarMoradores nao duplica notificacao para o mesmo agendamento.');
END;
/

-- Limpeza final.
DELETE FROM t_notificacoes WHERE t_rotas_id_rota BETWEEN 9021 AND 9029;
DELETE FROM t_agendamentos WHERE id_agendamento BETWEEN 9021 AND 9029;
DELETE FROM t_rotas WHERE id_rota BETWEEN 9021 AND 9029;
DELETE FROM t_caminhoes WHERE id_caminhao BETWEEN 9021 AND 9029;
COMMIT;
