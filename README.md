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
/database: Scripts SQL de criação de tabelas e constraints.
/procedures: Scripts PL/SQL com as lógicas de automação.
/docs: Documentação do Product Discovery e matriz CSD.

