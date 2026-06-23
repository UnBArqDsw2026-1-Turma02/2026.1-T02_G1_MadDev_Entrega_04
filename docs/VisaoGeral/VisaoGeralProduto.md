# Visão Geral do Produto

## O que é o MadDev

**MadDev** é um jogo eletrônico 2D do gênero **roguelike dungeon crawler** com perspectiva *top-down*, desenvolvido na **Godot Engine 4.6** em **GDScript**. O projeto é a aplicação prática da disciplina **Arquitetura e Desenho de Software (FGA0208)** da Universidade de Brasília (UnB), Turma 02, Grupo 01, no semestre 2026.1.

O jogo tem temática **acadêmica/universitária** com tom satírico e exagerado sobre a vida de estudante: o jogador controla um universitário que explora salas geradas a cada partida, enfrentando "objetos escolares zumbificados" (livros, cadernos, provas) e, ao final, um chefe que personifica uma matéria de Arquitetura de Computadores fora de controle.

> Inspiração de referência: o jogo [*Tiny Rogues*](https://store.steampowered.com/app/2088570/Tiny_Rogues/). O nome e a identidade do MadDev são originais; a referência serve apenas para situar gênero, público-alvo e pilares de jogabilidade.

## Identidade do Projeto

| Item | Descrição |
|------|-----------|
| **Nome** | MadDev |
| **Gênero** | Roguelike *dungeon crawler*, top-down, single-player |
| **Plataforma** | PC Desktop (Windows / Linux) |
| **Motor** | Godot Engine 4.6 |
| **Linguagem** | GDScript |
| **Disciplina** | FGA0208 — Arquitetura e Desenho de Software (UnB / FCTE) |
| **Grupo** | Turma 02 — Grupo 01 |

## Público-Alvo

Jogadores de roguelikes e *dungeon crawlers* que apreciam partidas curtas, rejogabilidade alta e progressão dentro de cada *run*. O tom universitário satírico amplia o apelo para o público estudantil, que reconhece as referências (provas, atestados, café, atlética, jubilamento).

## Pilares de Jogabilidade

1. **Permadeath e rejogabilidade** — cada *run* é independente; ao morrer, todo o estado (itens, atributos, XP, nível) é resetado. Não há persistência entre partidas.
2. **Progressão dentro da run** — o personagem evolui coletando itens, subindo de nível e escolhendo melhorias de atributo a cada *level up*.
3. **Combate dinâmico** — ataque com projéteis, esquiva (*dash*) e variedade de armas e inimigos com padrões distintos.
4. **Exploração estruturada** — uma run percorre 12 salas com tipos variados (combate, baú, loja, sala segura, pré-boss e boss).
5. **Identidade satírica** — estética *pixel art* 16-bit e humor sobre a vida acadêmica.

## Principais Funcionalidades

- Sistema de **vida em corações**, cura e morte do personagem.
- **Ataque** com dano e projéteis e **esquiva (dash)** com *cooldown*.
- **Atributos** (Vida, Dano, Velocidade e Cooldown de Dash), **experiência** e **modificadores**.
- **Seleção de personagem** entre quatro perfis com atributos base distintos (Calouro, Veterano, Jubilado, Mano da Atlética).
- **Inimigos** com vida, resistência, mira, movimentação e padrões variados, incluindo um **chefe (boss)**.
- **Consumíveis** (bombas, chaves, poções, itens de status e de benefício) e **equipáveis** em 5 slots.
- **Sistema de raridade** de itens (Comum, Incomum, Raro, Épico) sinalizado por cor.
- **Economia e loja** com moeda obtida ao explodir baús e NPCs vendedores.
- **Geração de salas** (12 por run) com preview de recompensa nas portas e regra anti-*softblock*.
- **Interface**: menu principal, pausa, fim de jogo, HUD e inventário.

> O detalhamento completo das mecânicas, atributos, tipos de inimigo e o catálogo de arte está no [Game Design Document](/GDD/GameDesignDocument.md). Os requisitos formais (RF/RNF) e as histórias de usuário estão no [Backlog](/Documentacao/Backlog.md).

## Tecnologia

A geração do site de documentação é feita com [docsify](https://docsify.js.org/). O jogo é desenvolvido na **Godot 4.6** e versionado em repositório próprio (branch `game`). A arquitetura adotada (camadas + orientação a eventos) e os 23 padrões GoF aplicados estão documentados no módulo de [Arquitetura de Software](/ArquiteturaReutilizacao/4.1.DAS.md).

## Estrutura desta Documentação

Esta wiki consolida as quatro entregas do projeto:

- **[Base](/Base/1.Base.md)** — Entrega 01: Design Sprint, artefatos generalistas (5W2H, Mapa Mental, Glossário/LAL, Ishikawa, Rich Picture, Protótipos, Riscos, Backlog, Estimativas), BPMN e metodologia.
- **[Modelagem UML](/Modelagem/2.Modelagem.md)** — Entrega 02: diagramas estáticos (pacotes, componentes, classes), dinâmicos (sequência, atividades, estados) e casos de uso.
- **[Padrões de Projeto GoF](/PadroesDeProjeto/3.PadroesDeProjeto.md)** — Entrega 03: padrões criacionais, estruturais e comportamentais aplicados no código.
- **[Arquitetura de Software](/ArquiteturaReutilizacao/4.ArquiteturaReutilizacao.md)** — Entrega 04: Documento de Arquitetura de Software (DAS).

## 🔄 Atualização — Entrega Final (jun/2026)

> Complemento ao estado do produto. **O jogo está jogável de ponta a ponta** (Godot 4.6, branch `game`): menu → seleção de personagem → 12 salas em sequência → combate, itens, economia e loja → boss → morte/vitória → reset. Toda a lógica (Issues 01–18) está implementada e validada em `godot --headless`. **Resta a produção de arte e áudio** (sprites, texturas, trilha e SFX). Detalhes em [Roadmap](/Documentacao/Roadmap.md) e [GDD](/GDD/GameDesignDocument.md).

## Histórico de Versionamento

| Nome | Alteração | Versão | Data |
|------|-----------|--------|------|
| Equipe MadDev | Criação da página de Visão Geral do Produto | v1.0 | 22/06/2026 |
