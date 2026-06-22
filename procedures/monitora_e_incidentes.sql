--ATIVIDADE 4 - QUARTA AUTOMATIZACAO -- Monitoramento e Resposta Automatizados para Incidentes Durante a Coleta

CREATE OR REPLACE PROCEDURE MonitoraEIncidentes IS
BEGIN
    FOR caminhao IN (SELECT id_caminhao, status FROM t_caminhoes WHERE status IN ('Avariado', 'Atrasado'))
    LOOP
        BEGIN
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

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                LogErro('MonitoraEIncidentes', 'Caminhao ' || caminhao.id_caminhao || ': ' || SQLERRM);
                ROLLBACK;
        END;
    END LOOP;
END MonitoraEIncidentes;
