ALTER TABLE t_coletas
    ADD CONSTRAINT relation_5_t_caminhoes_fk FOREIGN KEY ( t_caminhoes_id_caminhao )
        REFERENCES t_caminhoes ( id_caminhao );

ALTER TABLE t_coletas
    ADD CONSTRAINT relation_5_t_recipientes_fk FOREIGN KEY ( t_recipientes_id_recipiente )
        REFERENCES t_recipientes ( id_recipiente );

ALTER TABLE t_rota_recipiente
    ADD CONSTRAINT relation_9_t_recipientes_fk FOREIGN KEY ( t_recipientes_id_recipiente )
        REFERENCES t_recipientes ( id_recipiente );

ALTER TABLE t_rota_recipiente
    ADD CONSTRAINT relation_9_t_rotas_fk FOREIGN KEY ( t_rotas_id_rota )
        REFERENCES t_rotas ( id_rota );

ALTER TABLE t_agendamentos
    ADD CONSTRAINT t_agendamentos_t_caminhoes_fk FOREIGN KEY ( t_caminhoes_id_caminhao )
        REFERENCES t_caminhoes ( id_caminhao );

ALTER TABLE t_agendamentos
    ADD CONSTRAINT t_agendamentos_t_rotas_fk FOREIGN KEY ( t_rotas_id_rota )
        REFERENCES t_rotas ( id_rota );

ALTER TABLE t_notificacoes
    ADD CONSTRAINT t_notificacoes_t_caminhoes_fk FOREIGN KEY ( t_caminhoes_id_caminhao )
        REFERENCES t_caminhoes ( id_caminhao );

ALTER TABLE t_notificacoes
    ADD CONSTRAINT t_notificacoes_t_rotas_fk FOREIGN KEY ( t_rotas_id_rota )
        REFERENCES t_rotas ( id_rota );

ALTER TABLE t_rotas
    ADD CONSTRAINT t_rotas_t_caminhoes_fk FOREIGN KEY ( t_caminhoes_id_caminhao )
        REFERENCES t_caminhoes ( id_caminhao );

-- Nome dentro do limite de 30 caracteres do Oracle (t_recipientes_t_agendamentos_fk excede o limite)
ALTER TABLE t_recipientes
    ADD CONSTRAINT rec_agend_fk FOREIGN KEY ( t_agendamentos_id_agendamento )
        REFERENCES t_agendamentos ( id_agendamento );
