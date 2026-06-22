CREATE OR REPLACE PROCEDURE LogErro(
    p_nome_procedure IN VARCHAR2,
    p_mensagem_erro  IN VARCHAR2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO t_log_erros (id_log, nome_procedure, mensagem_erro, stack_trace, data_hora)
    VALUES (seq_log_erro.NEXTVAL, p_nome_procedure, SUBSTR(p_mensagem_erro, 1, 500),
            SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000), SYSTIMESTAMP);
    COMMIT;
END LogErro;
