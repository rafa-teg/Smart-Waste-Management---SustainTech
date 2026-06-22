--ATIVIDADE 2 - SEGUNDA AUTOMATIZACAO  - AGENDAR COLETA AUTOMaTICA
CREATE OR REPLACE PROCEDURE AgendarColetaAutomatica AS
BEGIN
    FOR r IN (SELECT id_recipiente, capacidade_atual, capacidade_max FROM t_recipientes)
    LOOP
        -- Verificar se a capacidade atual excede 80% da capacidade m xima
        IF r.capacidade_atual >= 0.8 * r.capacidade_max THEN
            -- Verificar se j  existe um agendamento pendente para este recipiente
            DECLARE
                v_count        NUMBER;
                v_id_caminhao  t_caminhoes.id_caminhao%TYPE;
            BEGIN
                SELECT COUNT(*) INTO v_count
                FROM t_agendamentos a
                JOIN t_recipientes rec ON rec.t_agendamentos_id_agendamento = a.id_agendamento
                WHERE rec.id_recipiente = r.id_recipiente
                AND a.confirmado = 'NAO'; -- Supondo que 'confirmado' tenha 'SIM' ou 'NAO'

                IF v_count = 0 THEN
                    -- Inserir um novo agendamento se nao houver agendamentos pendentes
                    SELECT id_caminhao INTO v_id_caminhao
                    FROM t_caminhoes WHERE status = 'Disponivel' AND ROWNUM = 1;

                    INSERT INTO t_agendamentos (id_agendamento, data_agendada, confirmado, t_caminhoes_id_caminhao, t_rotas_id_rota)
                    VALUES (seq_agendamento.NEXTVAL, SYSTIMESTAMP + INTERVAL '1' DAY, 'NAO', -- Alocar o proximo dia
                            v_id_caminhao, -- Exemplo simples de alocacao de caminhao
                            (SELECT id_rota FROM t_rotas WHERE t_caminhoes_id_caminhao = v_id_caminhao AND ROWNUM = 1)); -- Exemplo simples de alocacao de rota
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
