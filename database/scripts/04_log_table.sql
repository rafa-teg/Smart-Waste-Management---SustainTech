CREATE TABLE t_log_erros (
    id_log         INTEGER NOT NULL,
    nome_procedure VARCHAR2(30) NOT NULL,
    mensagem_erro  VARCHAR2(500) NOT NULL,
    stack_trace    VARCHAR2(2000),
    data_hora      TIMESTAMP WITH LOCAL TIME ZONE NOT NULL
);

ALTER TABLE t_log_erros ADD CONSTRAINT t_log_erros_pk PRIMARY KEY ( id_log );

CREATE SEQUENCE seq_log_erro;
