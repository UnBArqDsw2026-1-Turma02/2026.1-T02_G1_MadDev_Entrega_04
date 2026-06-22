# Ata de Reunião - Reunião 3
 
**Data**: 14/04/2026  
**Horário**: 19:00 - 19:40  
**Local**: Remoto - Discord  
 
---
 
## 1. Participantes
 
| Matrícula | Nome                             | Presença |
| --------- | -------------------------------- | -------- |
| 202017343 | Breno Lucena Cordeiro            | [x]      |
| 211061716 | Felipe Santos Veríssimo          | [x]      |
| 221022631 | Kauã Richard de Souza Cavalcante | [x]      |
| 190112093 | Lucas Freire Lopes               | [x]      |
| 202016963 | Mateus Vinicius Vieira           | [x]      |
| 211062830 | Philipe Barbosa de Morais        | [x]      |
| 232014754 | Pietro Calegari Visentin         | [x]      |
| 200062891 | Vinicius Fernandes Rufino        | [x]      |
 

![Evidência da Reunião](../Assets/reuniao03.png)

---
 
## 2. Sprint Atual
 
**Número da Sprint**: Sprint 2  
**Data de Início**: 14/04/2026  
**Data de Término**: 21/04/2026  
**Objetivo**: Desenvolver os artefatos de Modelagem UML referentes à Entrega 2, contemplando um diagrama de Modelagem Organizacional/Requisitos (Caso de Uso), um de Modelagem Estática e um de Modelagem Dinâmica por integrante  
 
---
 
## 3. Pauta e Discussões
 
### Tópicos Abordados
 
#### **Alinhamento sobre a Entrega 2 — Modelagem UML**
 
No início da reunião, foi apresentado o escopo completo da Entrega 2. Ficou definido que todos os 8 integrantes devem entregar, individualmente, três diagramas UML: um de Modelagem Organizacional/Requisitos (Diagrama de Caso de Uso), um de Modelagem Estática (Diagrama de Classes, Componentes ou Pacotes) e um de Modelagem Dinâmica (Diagrama de Sequência, Colaboração, Atividades ou Estados).
 
#### **Estudo do conteúdo de UML**
 
Foi orientado a todos os integrantes que, antes de iniciar o desenvolvimento dos diagramas, dediquem tempo para estudar o conteúdo teórico de UML disponibilizado pela professora. Cada membro deve se familiarizar com os tipos de diagrama que irá produzir, em especial a notação, os elementos e as relações corretas para cada modelo.
 
#### **Apresentação das User Stories relacionadas**
 
Foram apresentadas as User Stories do backlog que cada diagrama deve cobrir. O objetivo foi garantir rastreabilidade entre os artefatos UML e os requisitos levantados na Entrega 1, de forma que cada diagrama represente uma funcionalidade real do jogo e esteja vinculado a pelo menos uma US.
 
#### **Atribuição dos diagramas por integrante**
 
Após a apresentação das US's, foi realizada a distribuição dos três diagramas para cada integrante, levando em consideração as funcionalidades do jogo e o equilíbrio de carga entre os membros. As revisões cruzadas também foram definidas em pares para garantir consistência e qualidade dos artefatos antes da entrega final.
 
---
 
## 4. Artefatos Gerados
 
| Artefato                                                                                                              | Responsável        | Status    |
| --------------------------------------------------------------------------------------------------------------------- | ------------------ | --------- |
| Planejamento da Sprint 2                                                                                              | Todos Participaram | Concluído |
| [Modelagem Organizacional — Diagramas de Caso de Uso](/Modelagem/2.3.ModelagemOrganizacionalCasosDeUso.md)            | Todos Participaram | Concluído |
| [Modelagem Estática — Diagramas de Classes, Componentes e Pacotes](/Modelagem/2.1.ModelagemEstatica.md)               | Todos Participaram | Concluído |
| [Modelagem Dinâmica — Diagramas de Sequência, Colaboração, Atividades e Estados](/Modelagem/2.2.ModelagemDinamica.md) | Todos Participaram | Concluído |
 
---
 
## 5. Ações e Compromissos
 
| Ação                                                                                              | Responsável | Prazo      | Status    |
| ------------------------------------------------------------------------------------------------- | ----------- | ---------- | --------- |
| Estudar conteúdo de UML antes de iniciar os diagramas                                             | Todos       | 15/04/2026 | Concluído |
| Caso de Uso — Iniciar partida e navegar no menu principal (US-48)                                 | Breno       | 19/04/2026 | Concluído |
| Diagrama de Pacotes — UI/Menu/Config (US-48)                                                      | Breno       | 19/04/2026 | Concluído |
| Diagrama de Sequência — abrir jogo → menu → iniciar partida (US-48)                               | Breno       | 19/04/2026 | Concluído |
| Caso de Uso — Pausar e retomar partida (US-49, US-50)                                             | Felipe      | 19/04/2026 | Concluído |
| Diagrama de Componentes — Game Loop + Pause Controller (US-49, US-50)                             | Felipe      | 19/04/2026 | Concluído |
| Diagrama de Estados — Running/Paused/GameOver (US-49, US-50)                                      | Felipe      | 19/04/2026 | Concluído |
| Caso de Uso — Combate do jogador (US-21, US-22)                                                   | Kauã        | 19/04/2026 | Concluído |
| Diagrama de Classes — Player, Weapon, Projectile, Hitbox (US-21, US-22)                           | Kauã        | 19/04/2026 | Concluído |
| Diagrama de Sequência — input de ataque → cálculo de dano → feedback (US-21, US-22)               | Kauã        | 19/04/2026 | Concluído |
| Caso de Uso — Vida, cura e morte do personagem (US-18, US-19, US-20)                              | Lucas       | 19/04/2026 | Concluído |
| Diagrama de Classes — Health, HealingItem, DamageEvent (US-18, US-19, US-20)                      | Lucas       | 19/04/2026 | Concluído |
| Diagrama de Atividades — fluxo de dano/cura/morte (US-18, US-19, US-20)                           | Lucas       | 19/04/2026 | Concluído |
| Caso de Uso — Comportamento de inimigos em combate (US-30 a US-33)                                | Mateus      | 19/04/2026 | Concluído |
| Diagrama de Classes — Enemy, AIController, Pattern, Resistance (US-30 a US-33)                    | Mateus      | 19/04/2026 | Concluído |
| Diagrama de Colaboração — Enemy ↔ Player ↔ Projectile (US-30 a US-33)                             | Mateus      | 19/04/2026 | Concluído |
| Caso de Uso — Uso de consumíveis: bomba, chave e poção (US-34, US-35, US-36)                      | Philipe     | 19/04/2026 | Concluído |
| Diagrama de Componentes — InventoryService + ItemEffectEngine (US-34 a US-36)                     | Philipe     | 19/04/2026 | Concluído |
| Diagrama de Atividades — selecionar item → validar uso → aplicar efeito (US-34 a US-36)           | Philipe     | 19/04/2026 | Concluído |
| Caso de Uso — Equipar itens: arma, armadura e acessório (US-37, US-38, US-39)                     | Pietro      | 19/04/2026 | Concluído |
| Diagrama de Pacotes — Items/Equipment/Stats (US-37, US-38, US-39)                                 | Pietro      | 19/04/2026 | Concluído |
| Diagrama de Estados — equipado/desequipado/bloqueado (US-37, US-38, US-39)                        | Pietro      | 19/04/2026 | Concluído |
| Caso de Uso — Inventário e descarte de itens (US-51, US-52)                                       | Vinicius    | 19/04/2026 | Concluído |
| Diagrama de Componentes — InventoryUI + Persistência de sessão (US-51, US-52)                     | Vinicius    | 19/04/2026 | Concluído |
| Diagrama de Sequência — abrir inventário → descartar item → atualizar UI (US-51, US-52)           | Vinicius    | 19/04/2026 | Concluído |
| Revisão cruzada dos artefatos (Breno ↔ Felipe, Kauã ↔ Lucas, Mateus ↔ Philipe, Pietro ↔ Vinicius) | Todos       | 20/04/2026 | Concluído |
| Publicação dos artefatos no repositório/GitPages                                                  | Todos       | 21/04/2026 | Concluído |
 
---
 
## 6. Próximas Reuniões
 
**Data**: [27/04/2026]  
**Horário**: [18:00 - 20:00]  
**Pauta Prevista**: [Planejamento para a Sprint 3]  
 
---
 
## 7. Observações Finais
 
Foi reforçado que todos os diagramas devem seguir o padrão visual definido pelo grupo: título com nome do diagrama, US cobertas e versão (ex.: v1, v2). A ferramenta padrão acordada é o draw.io (diagrams.net) ou PlantUML/StarUML para quem já dominar. Em caso de sobrecarga, redistribuir tarefas mantendo a regra de que todos devem ter ao menos uma entrega por bloco de modelagem.
 
---
 
**Responsável pela Ata**: Vinícius Rufino 
**Data de Finalização**: 19:40
 
## Histórico de Versionamento
 
| Nome                                             | Alteração                   | Versão | Data       |
| ------------------------------------------------ | --------------------------- | ------ | ---------- |
| [Vinícius Rufino](https://github.com/RufinoVfR/) | Criação da Ata da Reunião 3 | v1.0   | 14/04/2026 |