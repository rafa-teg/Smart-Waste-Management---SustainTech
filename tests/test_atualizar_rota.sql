-- Teste de AtualizarRota (procedures/atualizar_rota.sql).
-- Pre-requisito: rodar antes os scripts de database/scripts/ e procedures/.
-- Faixa de IDs reservada para este teste: 9001-9009 (nao deve colidir com dados reais).

SET SERVEROUTPUT ON;

-- Limpeza de qualquer execucao anterior (idempotente), em ordem segura de FK.
DELETE FROM t_notificacoes WHERE t_caminhoes_id_caminhao BETWEEN 9001 AND 9009;
DELETE FROM t_log_erros WHERE nome_procedure = 'AtualizarRota';
DELETE FROM t_rotas WHERE id_rota BETWEEN 9001 AND 9009;
DELETE FROM t_caminhoes WHERE id_caminhao BETWEEN 9001 AND 9009;
COMMIT;

-- Seed: 1 caminhao com 1 rota "Em execucao".
INSERT INTO t_caminhoes (id_caminhao, placa, modelo, capacidade, status)
VALUES (9001, 'TST0001', 'Caminhao Teste', 1000, 'Disponivel');

-- O literal abaixo usa o mesmo caractere de substituicao (U+FFFD) que esta
-- gravado em procedures/atualizar_rota.sql (confirmado via inspecao de bytes
-- com grep/cat -A) -- nao e o mesmo literal corrompido usado em
-- monitora_e_incidentes.sql, que usa dois espacos em branco em vez disso.
INSERT INTO t_rotas (id_rota, dt_hora_inicio, dt_hora_fim, status_rota, t_caminhoes_id_caminhao)
VALUES (9001, SYSTIMESTAMP, NULL, 'Em execu�ao', 9001);

COMMIT;

-- Teste 1: caminho feliz - atualiza o status da rota e gera notificacao.
DECLARE
    v_status_rota t_rotas.status_rota%TYPE;
    v_count       NUMBER;
BEGIN
    AtualizarRota(9001, 'Localizacao Teste', 'Concluida');

    SELECT status_rota INTO v_status_rota FROM t_rotas WHERE id_rota = 9001;
    IF v_status_rota != 'Concluida' THEN
        RAISE_APPLICATION_ERROR(-20099, 'FAIL teste 1: status_rota nao foi atualizado para Concluida.');
    END IF;

    SELECT COUNT(*) INTO v_count FROM t_notificacoes
    WHERE t_rotas_id_rota = 9001 AND tipo_notificacao LIKE 'Atualiza%';
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20099, 'FAIL teste 1: notificacao de atualizacao de rota nao foi criada.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('PASS teste 1: AtualizarRota atualiza status e gera notificacao.');
END;
/

-- Teste 2: erro - caminhao sem rota "Em execucao" deve lancar ORA-20001 e logar em t_log_erros.
DECLARE
    v_count   NUMBER;
    v_sqlcode NUMBER;
BEGIN
    BEGIN
        AtualizarRota(9001, 'Localizacao Teste', 'Concluida'); -- rota 9001 ja esta 'Concluida', nao 'Em execucao'
        RAISE_APPLICATION_ERROR(-20099, 'FAIL teste 2: AtualizarRota deveria ter lancado erro (nenhuma rota em execucao).');
    EXCEPTION
        WHEN OTHERS THEN
            v_sqlcode := SQLCODE;
            IF v_sqlcode != -20001 THEN
                RAISE_APPLICATION_ERROR(-20099, 'FAIL teste 2: esperava ORA-20001, recebeu ' || v_sqlcode);
            END IF;
    END;

    SELECT COUNT(*) INTO v_count FROM t_log_erros WHERE nome_procedure = 'AtualizarRota';
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20099, 'FAIL teste 2: erro nao foi registrado em t_log_erros.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('PASS teste 2: AtualizarRota lanca ORA-20001 e loga o erro quando nao ha rota em execucao.');
END;
/

-- Limpeza final.
DELETE FROM t_notificacoes WHERE t_caminhoes_id_caminhao BETWEEN 9001 AND 9009;
DELETE FROM t_log_erros WHERE nome_procedure = 'AtualizarRota';
DELETE FROM t_rotas WHERE id_rota BETWEEN 9001 AND 9009;
DELETE FROM t_caminhoes WHERE id_caminhao BETWEEN 9001 AND 9009;
COMMIT;
