# Backlog de Desenvolvimento — Jogo

## O que é um Backlog?

Um **Backlog** é a lista ordenada de todas as funcionalidades, melhorias e correções que precisam ser implementadas em um projeto. Funciona como um "inventário de trabalho" onde cada item representa algo que será desenvolvido. O backlog é dinâmico e evolui conforme o projeto avança, com itens sendo adicionados, removidos ou repriorizados.

**Características principais:**
- Contém todos os requisitos do projeto
- Está organizado por ordem de prioridade
- Serve como fonte única da verdade para o que precisa ser feito
- Permite rastreabilidade e visibilidade do progresso


### O que são requisitos?

**Requisitos** são as condições e capacidades que o sistema deve atender para cumprir os objetivos do projeto.

- **Requisitos Funcionais (RF):** descrevem **o que** o jogo deve fazer, como movimentação, ataque, menus e inventário.
- **Requisitos Não Funcionais (RNF):** descrevem **como** essas funcionalidades devem ser apresentadas ou percebidas, como clareza visual, feedback sonoro e consistência de balanceamento.


### O que é um Tema?

Um **Tema** é um agrupamento de alto nível que representa uma grande área funcional do projeto. Temas reúnem múltiplos épicos relacionados a um mesmo domínio ou aspecto do sistema.

---

### O que é um Épico?

Um **Épico** é um grande corpo de trabalho que pode ser ainda subdividido. Representa uma funcionalidade completa e significativa que requer múltiplas histórias para ser implementada.


---

### O que é uma História de Usuário?

Uma **História de Usuário** (User Story) é uma descrição pequena e focada de uma funcionalidade do ponto de vista do usuário. Segue o formato: "Como [tipo de usuário], quero [ação], para que [benefício]".

**Características:**
- Deve ser concluída em um sprint ou ciclo de desenvolvimento
- Testável e mensurável
- Agrupa-se em épicos maiores
- Cada história tem um ID único para rastreamento

---

## 🔄 Atualização — Entrega Final (jun/2026)

> Complemento (nada abaixo foi removido). Os requisitos e Histórias de Usuário deste backlog estão, na sua **quase totalidade, implementados** na branch `game` (Godot 4.6) — Issues 01–18 do `tasks.md` concluídas e validadas em `godot --headless`. Pendentes apenas os requisitos de **arte/áudio** (RF-01..RF-04 · US-01..US-17, Issues 19–22). O mapeamento US → código está no [Roadmap](/Documentacao/Roadmap.md).
>
> **Observação (US-07 / US-53 — dash):** a implementação usa **modelo de cargas** (2 cargas com recarga por tempo), em vez de um cooldown fixo único — a "redução de cooldown de dash" continua sendo o atributo que acelera a recarga.

## Tabelas de Requisitos, Temas, Épicos e Histórias de Usuário

### Tabela de Requisitos

| ID     | Tipo | Requisito                                                                                             |
| ------ | ---- | ----------------------------------------------------------------------------------------------------- |
| RF-01  | RF   | O jogo deve apresentar sprites para personagem, inimigos e itens.                                                                                                           |
| RF-02  | RF   | O jogo deve apresentar texturas de menu e do ambiente.                                                                                                                      |
| RF-03  | RF   | O jogo deve reproduzir músicas de tema, menu, vitória e derrota.                                                                                                            |
| RF-04  | RF   | O jogo deve reproduzir efeitos sonoros de combate, movimentação, UI e uso de itens.                                                                                         |
| RF-05  | RF   | O jogador deve possuir sistema de vida em corações, cura e morte — cada hit remove 1 ou meio coração.                                                                       |
| RF-06  | RF   | O jogador deve poder atacar com dano e projéteis, com sistema unificado baseado em instanciação de projéteis.                                                               |
| RF-07  | RF   | O jogador deve se movimentar com colisões no cenário e possuir esquiva (dash) com cooldown fixo reduzível por modificador de atributo (Redução de Cooldown de Dash).                                                     |
| RF-08  | RF   | O jogador deve possuir atributos (Vida, Dano, Velocidade e Cooldown de Dash), experiência, modificadores de atributos e seleção de tipo de personagem com atributos base distintos.|
| RF-09  | RF   | Os inimigos devem possuir vida, resistência, ataque, mira, movimentação, padrões de movimentação e dano de colisão ao tocar o jogador.                                      |
| RF-10  | RF   | O jogo deve permitir uso de consumíveis utilitários fixos (bombas, chaves, poções), consumíveis de status (que aumentam um atributo do jogador) e consumíveis de benefício.          |
| RF-11  | RF   | O jogo deve permitir equipar armas e armaduras/acessórios nos 5 slots disponíveis (cabeça, tronco, perna, pé, acessório), com sistema de raridade de 4 níveis.              |
| RF-12  | RF   | O jogo deve gerar salas seguindo estrutura de 12 salas por run, com tipos variados, preview de recompensa nas portas e regra anti-softblock.                                 |
| RF-13  | RF   | O jogo deve definir tipos e quantidades de armas (classificadas por alcance: longo e curto alcance) e inimigos, incluindo um chefe (boss).                               |
| RF-14  | RF   | O projeto deve manter tabelas de design para atributos, inimigos, itens, raridade, loja e recompensas de sala.                                                              |
| RF-15  | RF   | O jogo deve disponibilizar: menu principal (com opção Sair), menu de pausa, menu de retomada, menu de fim de jogo e HUD durante a partida.                                  |
| RF-16  | RF   | O jogo deve disponibilizar inventário e permitir descarte de itens.                                                                                                         |
| RF-17  | RF   | O jogo deve implementar sistema de raridade de itens (Comum, Incomum, Raro, Épico) com sinalização visual por cor.                                                          |
| RF-18  | RF   | O jogo deve implementar sistema de moeda obtida ao explodir baús e sala de loja com NPCs vendedores por categoria.                                                          |
| RNF-01 | RNF  | A apresentação visual deve permitir reconhecimento fácil de personagem, inimigos e itens.                                                                                   |
| RNF-02 | RNF  | A navegação de menu deve ser clara e agradável para o jogador.                                                                                                              |
| RNF-03 | RNF  | O cenário deve ser visualmente compreensível.                                                                                                                               |
| RNF-04 | RNF  | O jogo deve fornecer feedback sonoro para ações e eventos principais.                                                                                                       |
| RNF-05 | RNF  | O balanceamento do jogo deve ser consistente e os ajustes de combate devem ser claros para a equipe.                                                                        |
| RNF-06 | RNF  | A dificuldade e a variedade de conteúdo devem ser controladas por definição de quantidades no design.                                                                       |
| RNF-07 | RNF  | Ao morrer, todo o estado da sessão (itens, stats, XP e nível) deve ser completamente resetado, sem qualquer persistência entre runs.                                        |

### Tabela de Temas

| Código | Tema        | Descrição                                         |
| ------ | ----------- | ------------------------------------------------- |
| T-01   | Assets      | Todos os recursos visuais e áudio do jogo         |
| T-02   | Player      | Sistemas e mecânicas do personagem principal      |
| T-03   | Inimigos    | Comportamento, ataque e movimentação dos inimigos |
| T-04   | Itens       | Sistema de consumíveis e equipáveis               |
| T-05   | Game Design | Design e tipos de salas do jogo                   |
| T-06   | UI          | Interface do usuário e menus                      |

---

### Tabela de Épicos

| Código | Épico                        | Tema               | Descrição                               |
| ------ | ---------------------------- | ------------------ | --------------------------------------- |
| E-01   | Artes                        | T-01 — Assets      | Sprites e elementos visuais                          |
| E-02   | Músicas                      | T-01 — Assets      | Música tema e menu                                   |
| E-03   | Efeitos Sonoros              | T-01 — Assets      | Efeitos sonoros do jogo (player, inimigos e UI)      |
| E-04   | Sistema de Vida do Jogador   | T-02 — Player      | Dano, cura, corações e morte do jogador              |
| E-05   | Sistema de Ataque            | T-02 — Player      | Ataques e projéteis                                  |
| E-06   | Sistema de Movimentação      | T-02 — Player      | Movimento, colisões e dash                           |
| E-07   | Sistema de Atributos (Stats) | T-02 — Player      | Atributos, modificadores e progressão          |
| E-08   | Sistema de Vida dos Inimigos | T-03 — Inimigos    | Dano, resistência e morte dos inimigos               |
| E-09   | Sistema de Ataque            | T-03 — Inimigos    | Ataques, mira e dano de colisão                      |
| E-10   | Sistema de Movimentação      | T-03 — Inimigos    | Rastreamento e padrões                               |
| E-11   | Consumíveis                  | T-04 — Itens       | Utilitários fixos, consumíveis de status e benefício |
| E-12   | Equipáveis                   | T-04 — Itens       | Armas, armaduras e acessórios com raridade           |
| E-13   | Tipos de Sala                | T-05 — Game Design | Salas, recompensas, portas e estrutura da run        |
| E-14   | Tipos de Arma                | T-05 — Game Design | Definição dos tipos de armas do jogador              |
| E-15   | Tipos de Inimigo             | T-05 — Game Design | Definição dos tipos de inimigos                      |
| E-16   | Tabelas de Design            | T-05 — Game Design | Base de dados para design do jogo                    |
| E-17   | Menus                        | T-06 — UI          | Criação dos menus e HUD do jogo                      |
| E-18   | Inventário                   | T-06 — UI          | Criação da interface do inventário                   |
| E-19   | Sistema de Raridade          | T-04 — Itens       | Raridade de itens e armas (Comum/Incomum/Raro/Épico) |
| E-20   | Economia e Loja              | T-05 — Game Design | Moeda, loja e NPCs vendedores                        |


### Tabela de Histórias de Usuário

| Código | Tema | Épico | Descrição                                                                                                                       | MoSCoW      |
| ------ | ---- | ----- | ------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| US-01  | T-01 | E-01  | Como jogador, quero sprites para o personagem, para que eu o reconheça facilmente durante a partida.                            | Must Have   |
| US-02  | T-01 | E-01  | Como jogador, quero sprites para os inimigos, para que eu identifique ameaças na tela.                                          | Must Have   |
| US-03  | T-01 | E-01  | Como jogador, quero sprites para os itens, para que eu reconheça o que pode ser coletado.                                       | Must Have   |
| US-04  | T-01 | E-01  | Como jogador, quero texturas no menu, para que a navegação fique mais clara e agradável.                                        | Must Have   |
| US-05  | T-01 | E-01  | Como jogador, quero texturas do ambiente, para que o cenário do jogo seja compreensível.                                        | Should Have |
| US-06  | T-01 | E-02  | Como jogador, quero uma música tema, para que o jogo tenha identidade sonora.                                                   | Should Have |
| US-07  | T-01 | E-02  | Como jogador, quero música no menu, para que a tela inicial tenha ambientação.                                                  | Should Have |
| US-08  | T-01 | E-02  | Como jogador, quero música de vitória, para que eu receba feedback quando vencer.                                               | Should Have |
| US-09  | T-01 | E-02  | Como jogador, quero música de derrota, para que eu receba feedback quando perder.                                               | Should Have |
| US-10  | T-01 | E-03  | Como jogador, quero som de ataque do personagem, para que eu perceba quando atacar.                                             | Must Have   |
| US-11  | T-01 | E-03  | Como jogador, quero som ao receber dano, para que eu saiba quando fui atingido.                                                 | Must Have   |
| US-12  | T-01 | E-03  | Como jogador, quero som de morte do personagem, para que eu entenda o fim da tentativa.                                         | Should Have |
| US-13  | T-01 | E-03  | Como jogador, quero sons de movimentação, para que o deslocamento tenha retorno sonoro.                                         | Should Have |
| US-14  | T-01 | E-03  | Como jogador, quero sons de ataque dos inimigos, para que eu identifique quando eles atacam.                                    | Must Have   |
| US-15  | T-01 | E-03  | Como jogador, quero sons de morte dos inimigos, para que eu saiba quando eles foram derrotados.                                 | Must Have   |
| US-16  | T-01 | E-03  | Como jogador, quero sons de interação com a UI, para que minhas ações em menus tenham confirmação.                              | Must Have   |
| US-17  | T-01 | E-03  | Como jogador, quero sons ao usar itens, para que eu tenha confirmação do uso.                                                   | Must Have   |
| <span id="US-18">US-18</span>  | T-02 | E-04  | Como jogador, quero um sistema de vida em corações, para que eu acompanhe minha sobrevivência — cada hit remove 1 ou meio coração.                                          | Must Have   |
| <span id="US-19">US-19</span>  | T-02 | E-04  | Como jogador, quero um sistema de cura, para que eu possa recuperar corações durante a partida.                                                                             | Must Have   |
| <span id="US-20">US-20</span>  | T-02 | E-04  | Como jogador, quero um sistema de morte do personagem, para que a partida seja encerrada ao zerar os corações.                                                              | Must Have   |
| <span id="US-21">US-21</span>  | T-02 | E-05  | Como jogador, quero causar dano com meu ataque, para que eu possa derrotar inimigos.                                            | Must Have   |
| <span id="US-22">US-22</span>  | T-02 | E-05  | Como jogador, quero usar projéteis, para que eu possa atacar à distância.                                                       | Must Have   |
| US-23  | T-02 | E-06  | Como jogador, quero movimentar o personagem, para que eu explore o mapa do jogo.                                                | Must Have   |
| US-24  | T-02 | E-06  | Como jogador, quero colisões no personagem, para que eu não atravesse limites e objetos sólidos.                                | Must Have   |
| US-25  | T-02 | E-07  | Como jogador, quero atributos (Vida, Dano e Velocidade) no personagem, para que o desempenho mude conforme progressão e escolhas.                               | Must Have   |
| US-26  | T-02 | E-07  | Como jogador, quero ganhar experiência ao coletar consumíveis de status, para que eu progrida de nível ao longo da run.                                                     | Must Have   |
| US-27  | T-02 | E-07  | Como jogador, quero modificadores de atributos, para que efeitos de itens e level up alterem meus sistemas de jogo.                                                         | Must Have   |
| US-28  | T-03 | E-08  | Como jogador, quero que inimigos tenham vida, para que exista condição de derrota dos adversários.                              | Must Have   |
| US-29  | T-03 | E-08  | Como jogador, quero inimigos com resistência, para que o desafio de combate varie.                                              | Must Have   |
| <span id="US-30">US-30</span>  | T-03 | E-09  | Como jogador, quero que inimigos ataquem com projéteis e causem dano de colisão ao tocar o personagem, para que o combate ofereça desafio.                                  | Must Have   |
| <span id="US-31">US-31</span>  | T-03 | E-09  | Como jogador, quero que inimigos mirem em mim, para que os ataques façam sentido no confronto.                                  | Must Have   |
| <span id="US-32">US-32</span>  | T-03 | E-10  | Como jogador, quero movimentação dos inimigos, para que eles se desloquem pelo cenário.                                         | Must Have   |
| <span id="US-33">US-33</span>  | T-03 | E-10  | Como jogador, quero padrões de movimentação dos inimigos, para que os comportamentos sejam variados.                            | Must Have   |
| <span id="US-34">US-34</span>  | T-04 | E-11  | Como jogador, quero usar bombas consumíveis, para que eu tenha mais opções táticas em jogo.                                     | Must Have   |
| <span id="US-35">US-35</span>  | T-04 | E-11  | Como jogador, quero usar chaves consumíveis, para que eu interaja com bloqueios e acessos do jogo.                              | Must Have   |
| <span id="US-36">US-36</span>  | T-04 | E-11  | Como jogador, quero usar poções consumíveis, para que eu tenha recursos de suporte na partida.                                  | Must Have   |
| <span id="US-37">US-37</span>  | T-04 | E-12  | Como jogador, quero equipar armas, para que eu altere minha forma de ataque.                                                    | Must Have   |
| <span id="US-38">US-38</span>  | T-04 | E-12  | Como jogador, quero equipar armaduras, para que eu aumente minha proteção.                                                      | Must Have   |
| <span id="US-39">US-39</span>  | T-04 | E-12  | Como jogador, quero equipar acessórios, para que eu complemente os atributos do personagem.                                     | Must Have   |
| US-40  | T-05 | E-13  | Como jogador, quero tipos diferentes de sala com recompensas distintas, para que a exploração não seja repetitiva.                                                          | Should Have |
| US-41  | T-05 | E-13  | Como jogador, quero geração de salas seguindo uma estrutura de 12 salas (sala 1 vazia, salas 2-10 com tipos variados, sala 11 pré-boss, sala 12 boss) com variação de layout, para que cada partida tenha ritmo definido e conteúdo variado. | Must Have   |
| US-42  | T-05 | E-14  | Como jogador, quero tipos de arma definidos por alcance e comportamento (longo alcance, que dispara projétil convencional; curto alcance, cujo projétil vai e volta), para que eu tenha estilos de combate diferentes.     | Must Have   |
| US-43  | T-05 | E-14  | Como jogador, quero quantidades de armas definidas, para que o jogo mantenha equilíbrio de variedade.                                                                       | Must Have   |
| US-44  | T-05 | E-15  | Como jogador, quero tipos de inimigo definidos, incluindo um chefe, para que eu enfrente desafios distintos ao longo da run.                                                 | Must Have   |
| US-45  | T-05 | E-15  | Como jogador, quero quantidades de inimigos definidas, para que a dificuldade seja controlada.                                  | Must Have   |
| US-46  | T-05 | E-16  | Como equipe de desenvolvimento, quero tabelas de atributos, inimigos e itens, para que o balanceamento seja consistente.        | Must Have   |
| US-47  | T-05 | E-16  | Como equipe de desenvolvimento, quero tabelas de atributos e interações com armas, para que os ajustes de combate sejam claros. | Must Have   |
| <span id="US-48">US-48</span>  | T-06 | E-17  | Como jogador, quero um menu principal, para que eu inicie o jogo e acesse opções básicas.                                       | Must Have   |
| <span id="US-49">US-49</span>  | T-06 | E-17  | Como jogador, quero pausar a partida, para que eu interrompa o jogo quando necessário.                                                                                      | Must Have   |
| <span id="US-50">US-50</span>  | T-06 | E-17  | Como jogador, quero retomar a partida pausada, para que eu continue de onde parei.                                                                                          | Must Have   |
| <span id="US-51">US-51</span>  | T-06 | E-18  | Como jogador, quero um inventário, para que eu organize os itens coletados.                                                                                                 | Must Have   |
| <span id="US-52">US-52</span>  | T-06 | E-18  | Como jogador, quero descartar itens do inventário, para que eu gerencie melhor o espaço disponível.                                                                         | Must Have   |
| US-53  | T-02 | E-06  | Como jogador, quero realizar uma esquiva (dash) com cooldown fixo reduzível por modificador de atributo (Redução de Cooldown de Dash), para que eu desvie de ataques inimigos durante o combate.                         | Must Have   |
| US-54  | T-02 | E-07  | Como jogador, ao subir de nível, quero que o jogo congele e me apresente a escolha entre +Dano, +Vida Máxima ou +Velocidade, para que eu personalize minha progressão.      | Must Have   |
| US-55  | T-02 | E-07  | Como jogador, quero escolher entre tipos de personagem (Calouro, Veterano, Jubilado, Cara da Atlética) com atributos base distintos, para que eu inicie a run com um perfil adequado ao meu estilo. | Must Have   |
| US-56  | T-04 | E-11  | Como jogador, quero usar consumíveis de benefício (slot único, substituído ao coletar outro), para que eu obtenha efeitos durante a partida.                                 | Must Have   |
| US-57  | T-05 | E-13  | Como jogador, quero que as saídas da sala sejam bloqueadas enquanto houver inimigos vivos, para que o combate seja obrigatório antes de avançar.                             | Must Have   |
| US-59  | T-06 | E-17  | Como jogador, quero uma opção de sair no menu principal, para que eu possa encerrar a aplicação facilmente.                                                                  | Must Have   |
| US-60  | T-06 | E-17  | Como jogador, quero um HUD durante a partida exibindo meus corações, arma equipada, bombas, poções, chaves e consumível de benefício, para que eu acompanhe meu estado em tempo real. | Must Have   |
| US-62  | T-06 | E-17  | Como jogador, quero um menu de fim de jogo exibindo o resultado da tentativa, para que eu saiba se venci ou perdi e escolha o próximo passo.                                 | Must Have   |
| US-63  | T-05 | E-13  | Como jogador, quero encontrar salas de baú (armas, equipamentos ou consumíveis), para que eu obtenha recompensas sem combate durante a run.                                  | Must Have   |
| US-64  | T-05 | E-13  | Como jogador, quero encontrar salas seguras que restauram minha vida totalmente, para que eu possa me recuperar entre combates.                                              | Must Have   |
| US-65  | T-05 | E-13  | Como jogador, quero encontrar portas trancadas e bloqueadas por rochas como rotas opcionais, para que eu use chaves e bombas em troca de recompensas extras.                 | Should Have |
| US-66  | T-05 | E-13  | Como jogador, quero que sempre haja pelo menos uma porta aberta em cada sala, para que eu nunca fique bloqueado sem poder avançar na run.                                    | Must Have   |
| US-67  | T-05 | E-13  | Como jogador, quero ver um ícone de recompensa em cada porta antes de entrar na sala, para que eu tome decisões estratégicas sobre qual caminho seguir.                      | Must Have   |
| US-68  | T-04 | E-11  | Como jogador, quero usar consumíveis de status que concedem +1 em um atributo (Dano, Vida ou Velocidade) e +1 XP, para que eu fortaleça meu personagem durante a run.       | Must Have   |
| US-69  | T-04 | E-19  | Como jogador, quero que itens e armas possuam raridade (Comum, Incomum, Raro, Épico) sinalizada por cor, para que eu identifique rapidamente o valor de um item.            | Must Have   |
| US-70  | T-05 | E-20  | Como jogador, quero obter moeda ao explodir baús com bomba, para que eu possa comprar itens na sala de loja.                                                                 | Must Have   |
| US-71  | T-05 | E-20  | Como jogador, quero encontrar uma sala de loja com NPCs vendedores (Armeiro, Equipador, Boticário, Mentor), para que eu possa comprar itens com moeda durante a run.         | Must Have   |
| US-72  | T-04 | E-11  | Como jogador, quero explodir um baú com bomba para obter loot alternativo (moeda, bomba ou chave), para que eu tenha uma opção estratégica quando não tiver chave.           | Must Have   |

## Referências

- Material de Apoio disponibilizado via Aprender3

## Histórico de Versionamento

| Nome                                        | Alteração                                    | Versão | Data       |
| ------------------------------------------- | -------------------------------------------- | ------ | ---------- |
| [Mateus Vieira](https://github.com/matix0/) | Priorização das Histórias de Usuário         | v0.3   | 04/04/2026 |
| [Mateus Vieira](https://github.com/matix0/) | Adição das Tabelas                           | v0.2   | 03/04/2026 |
| [Mateus Vieira](https://github.com/matix0/) | Criação da estrutura do documento de Backlog | v0.1   | 02/04/2026 |
| [Mateus Vieira](https://github.com/matix0/) | Atualização de RFs/RNFs, épicos, USs existentes e adição de US-53 a US-72 | v1.0 | 01/06/2026 |
| [Mateus Vieira](https://github.com/matix0/) | Alinhamento de RF-07/08/10/13 e US-25/42/53/54/68 ao modelo de atributos do GDD (Dano/Vida/Velocidade + Cooldown de Dash), removendo divergência Força/Destreza/Inteligência | v1.1 | 01/06/2026 |
| [Mateus Vieira](https://github.com/matix0) e  [Vinícius Rufino](https://github.com/RufinoVfR) | Atualização do Backlog de Requisitos | v1.2 | 08/06/2026 |