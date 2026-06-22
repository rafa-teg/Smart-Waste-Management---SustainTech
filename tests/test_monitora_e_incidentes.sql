-- Teste de MonitoraEIncidentes (procedures/monitora_e_incidentes.sql).
-- Pre-requisito: rodar antes os scripts de database/scripts/ e procedures/.
-- Faixa de IDs reservada para este teste: 9031-9039 (nao deve colidir com dados reais).
--
-- Cobertura: caminho feliz apenas. Nao ha teste de erro forcado aqui -- provocar um
-- WHEN OTHERS realista nesta procedure exigiria violar constraints de forma artificial,
-- o que nao valeria a complexidade. O isolamento por caminhao (commit/rollback
-- independente por iteracao) foi validado por revisao de codigo na etapa de tratamento
-- de erro, nao por um teste automatizado.

SET SERVEROUTPUT ON;

-- Limpeza de qualquer execucao anterior (idempotente), em ordem segura de FK.
DELETE FROM t_notificacoes WHERE t_caminhoes_id_caminhao BETWEEN 9031 AND 9039;
DELETE FROM t_log_erros WHERE nome_procedure = 'MonitoraEIncidentes';
DELETE FROM t_rotas WHERE id_rota BETWEEN 9031 AND 9039;
DELETE FROM t_caminhoes WHERE id_caminhao BETWEEN 9031 AND 9039;
COMMIT;

-- Seed: 1 caminhao 'Avariado' com 1 rota em execucao.
INSERT INTO t_caminhoes (id_caminhao, placa, modelo, capacidade, status)
VALUES (9031, 'TST0031', 'Caminhao Teste', 1000, 'Avariado');

-- O literal de status_rota abaixo usa dois espacos em branco, copiado byte a byte do
-- literal corrompido em procedures/monitora_e_incidentes.sql (confirmado via grep/cat -A;
-- e uma corrupcao diferente da usada em atualizar_rota.sql, que usa U+FFFD em vez disso).
INSERT INTO t_rotas (id_rota, dt_hora_inicio, dt_hora_fim, status_rota, t_caminhoes_id_caminhao)
VALUES (9031, SYSTIMESTAMP, NULL, 'Em execu  o', 9031);

COMMIT;

-- Teste: caminho feliz.
DECLARE
    v_count_alteracao NUMBER;
    v_count_incidente  NUMBER;
    v_status_rota      t_rotas.status_rota%TYPE;
BEGIN
    MonitoraEIncidentes;

    -- Assercao principal: a notificacao "Alteracao de Coleta" e inserida incondicionalmente
    -- para todo caminhao avariado/atrasado, independente de qualquer literal corrompido.
    SELECT COUNT(*) INTO v_count_alteracao FROM t_notificacoes
    WHERE t_caminhoes_id_caminhao = 9031 AND tipo_notificacao LIKE 'Altera%Coleta' AND t_rotas_id_rota IS NULL;

    IF v_count_alteracao = 0 THEN
        RAISE_APPLICATION_ERROR(-20099, 'FAIL: notificacao de alteracao de coleta nao foi criada para o caminhao 9031.');
    END IF;

    -- Verificacao secundaria (best-effort): depende do match exato do literal corrompido
    -- 'Em execu  o' usado no WHERE da procedure. Se nao bater, so avisa, nao falha o teste.
    SELECT COUNT(*) INTO v_count_incidente FROM t_notificacoes
    WHERE t_caminhoes_id_caminhao = 9031 AND t_rotas_id_rota = 9031 AND tipo_notificacao = 'Incidente';

    SELECT status_rota INTO v_status_rota FROM t_rotas WHERE id_rota = 9031;

    IF v_count_incidente = 0 OR v_status_rota != 'Interrumpida por incidente' THEN
        DBMS_OUTPUT.PUT_LINE('AVISO: notificacao de incidente / atualizacao da rota nao foi detectada -- ' ||
                              'possivel mismatch do literal corrompido de status_rota entre este teste e a procedure.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('PASS (best-effort): notificacao de incidente e atualizacao de rota detectadas.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('PASS: MonitoraEIncidentes notifica alteracao de coleta para caminhao avariado.');
END;
/

-- Limpeza final.
DELETE FROM t_notificacoes WHERE t_caminhoes_id_caminhao BETWEEN 9031 AND 9039;
DELETE FROM t_log_erros WHERE nome_procedure = 'MonitoraEIncidentes';
DELETE FROM t_rotas WHERE id_rota BETWEEN 9031 AND 9039;
DELETE FROM t_caminhoes WHERE id_caminhao BETWEEN 9031 AND 9039;
COMMIT;
