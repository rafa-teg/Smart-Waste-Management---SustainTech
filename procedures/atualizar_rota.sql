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
        LogErro('AtualizarRota', 'Nenhuma rota encontrada para o caminhao ' || p_id_caminhao);
        RAISE_APPLICATION_ERROR(-20001, 'Nenhuma rota encontrada para este caminh o.');
    WHEN OTHERS THEN
        LogErro('AtualizarRota', SQLERRM);
        RAISE_APPLICATION_ERROR(-20002, SQLERRM);
END AtualizarRota;
