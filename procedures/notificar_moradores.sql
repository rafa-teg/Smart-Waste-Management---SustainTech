--ATIVIDADE 3 - TERCEIRA AUTOMATIZACAO - Notificacao aos Moradores
CREATE OR REPLACE PROCEDURE NotificarMoradores IS
BEGIN
    FOR agendamento IN (
        SELECT a.id_agendamento, a.data_agendada, r.t_caminhoes_id_caminhao, r.id_rota AS t_rotas_id_rota
        FROM t_agendamentos a
        JOIN t_rotas r ON a.t_rotas_id_rota = r.id_rota
        WHERE a.confirmado = 'SIM' AND NOT EXISTS (
            SELECT 1 FROM t_notificacoes n
            WHERE n.t_rotas_id_rota = r.id_rota
            AND n.t_caminhoes_id_caminhao = r.t_caminhoes_id_caminhao
            AND n.tipo_notificacao = 'Dia de Coleta'
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
                LogErro('NotificarMoradores', SQLERRM);
                ROLLBACK;
        END;
    END LOOP;
END NotificarMoradores;
