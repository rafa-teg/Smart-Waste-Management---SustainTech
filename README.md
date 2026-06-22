<img width="2625" height="1163" alt="Image" src="https://github.com/user-attachments/assets/56c84c53-a218-470f-a93e-618a07c949da" />

- Smart Waste Management - SustainTech
Este projeto foi desenvolvido como parte da formação em Análise e Desenvolvimento de Sistemas (ADS) na FIAP. A solução foca-se na otimização da logística reversa de resíduos eletrônicos, unindo uma visão estratégica de negócio (Product Discovery) com uma arquitetura robusta de base de dados.

- Visão do Produto e Discovery
O projeto nasceu da identificação de uma falha crítica na coordenação entre geradores de resíduos e pontos de descarte. Através da metodologia Startup One, validámos a viabilidade e a dor do mercado.

- Análise de Mercado (TAM/SAM/SOM)
TAM (Total Addressable Market): Mercado brasileiro com potencial de gerar até R$ 8 bilhões anuais na reciclagem de lixo eletrónico.
SAM (Serviceable Available Market): Foco no estado de São Paulo, o maior produtor de resíduos do país.
SOM (Serviceable Obtainable Market): Alcance inicial de 10% da Região Metropolitana de São Paulo.

- User Research (Pesquisa de Campo)
Realizamos mais de 10 entrevistas estruturadas com diferentes perfis (desde professores a programadores).
Insight Principal: 80% dos utilizadores gostariam de descartar corretamente, mas não sabem onde encontrar ecopontos ou como funciona o processo de recolha.
Solução Proposta: Uma plataforma mobile para agendamento automático e rastreio do destino final do resíduo.

- Arquitetura do Banco de Dados
A camada de dados foi projetada em Oracle SQL para suportar operações logísticas complexas e sensores de capacidade em tempo real.
Diagrama Entidade-Relacionamento (MER)

- Tecnologias e Automações (PL/SQL)
O diferencial técnico deste projeto é a inteligência embutida na base de dados através de Stored Procedures:
Agendamento Automático: O sistema monitoriza a capacidade_atual dos recipientes. Ao atingir 80% da capacidade máxima, uma coleta é agendada automaticamente.
Gestão de Incidentes: Monitoramento proativa da frota. Se um camião reportar o status de 'Avariado' ou 'Atrasado', a rota é interrompida e o centro de controlo é notificado instantaneamente.
Otimização de Rotas: Procedimentos para atualização dinâmica de localização e status (Em execução, Concluída), visando a redução de custos de combustível.

- Estrutura do Repositório
/database/scripts: Scripts SQL de criação de tabelas, constraints, sequences e da tabela de log de erros (01_tables.sql, 02_constraints.sql, 03_sequences.sql, 04_log_table.sql).
/procedures: Scripts PL/SQL com as lógicas de automação (uma procedure por arquivo) e a procedure utilitária de log de erros (log_erro.sql).
/tests: Scripts PL/SQL autocontidos que testam cada procedure (seed de dados + chamada + verificação).

- Known Issues
Deduplicação de agendamentos em AgendarColetaAutomatica (procedures/agendar_coleta_automatica.sql): a checagem de "já existe agendamento pendente?" usa o FK estático t_recipientes.t_agendamentos_id_agendamento, que a procedure nunca atualiza após criar um novo agendamento. Na prática, isso significa que a deduplicação não funciona entre execuções sucessivas: se um recipiente continuar acima de 80% de capacidade, cada chamada da procedure (ex.: um job diário) tende a criar um novo agendamento duplicado, já que o link do recipiente nunca passa a apontar para o agendamento mais recente. Esse comportamento foi identificado ao escrever tests/test_agendar_coleta_automatica.sql. Detalhes e correção proposta: [issue #2](https://github.com/rafa-teg/Smart-Waste-Management---SustainTech/issues/2).

