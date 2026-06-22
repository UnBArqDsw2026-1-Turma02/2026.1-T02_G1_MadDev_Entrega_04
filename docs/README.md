# MadDev

**MadDev** é um jogo 2D *roguelike dungeon crawler* top-down desenvolvido na **Godot Engine 4.6 / GDScript**, com temática universitária satírica. Este site reúne toda a documentação do projeto, produzida ao longo das quatro entregas da disciplina **Arquitetura e Desenho de Software (FGA0208)** — UnB / FCTE, Turma 02, Grupo 01.

## Navegação rápida

| Seção | Conteúdo |
|-------|----------|
| 🎯 [Visão Geral do Produto](/VisaoGeral/VisaoGeralProduto.md) | O que é o jogo, público-alvo, pilares e funcionalidades |
| 🎮 [Game Design Document](/GDD/GameDesignDocument.md) | Mecânicas, progressão, inimigos, itens e direção de arte |
| 📋 [Backlog](/Documentacao/Backlog.md) · [Roadmap](/Documentacao/Roadmap.md) | Requisitos (RF/RNF), histórias de usuário e plano de desenvolvimento |
| 1️⃣ [Entrega 01 — Base](/Base/1.Base.md) | Design Sprint, artefatos generalistas, BPMN e metodologia |
| 2️⃣ [Entrega 02 — Modelagem UML](/Modelagem/2.Modelagem.md) | Diagramas estáticos, dinâmicos e de casos de uso |
| 3️⃣ [Entrega 03 — Padrões GoF](/PadroesDeProjeto/3.PadroesDeProjeto.md) | Padrões criacionais, estruturais e comportamentais |
| 4️⃣ [Entrega 04 — Arquitetura](/ArquiteturaReutilizacao/4.ArquiteturaReutilizacao.md) | Documento de Arquitetura de Software (DAS) |
| 👥 [Contribuições](/Contribuicoes/Contribuicoes.md) | Equipe e participações por entrega |

## Sobre o projeto

O jogador controla um estudante universitário que explora salas geradas a cada partida, enfrenta "objetos escolares zumbificados" (livros, cadernos, provas) e, ao final, um chefe que personifica uma matéria de Arquitetura de Computadores fora de controle. Cada *run* é independente: ao morrer, todo o progresso é resetado (**permadeath**).

- **Gênero:** Roguelike dungeon crawler, top-down, single-player
- **Plataforma:** PC Desktop (Windows / Linux)
- **Motor / Linguagem:** Godot 4.6 / GDScript
- **Referência de gênero:** [Tiny Rogues](https://store.steampowered.com/app/2088570/Tiny_Rogues/) (nome e identidade do MadDev são originais)

## Tecnologia da documentação

Site estático gerado com [docsify](https://docsify.js.org/). Para rodar localmente:

```shell
# opção 1 — docsify-cli
npm i docsify-cli -g
docsify serve ./docs

# opção 2 — servidor estático simples
python -m http.server 3000 --directory ./docs
```

Diagramas são renderizados com [Mermaid](https://mermaid.js.org/); imagens UML ficam em `docs/Assets/`.

## Equipe — Grupo 01

| Aluno | GitHub |
|-------|--------|
| Breno Lucena Cordeiro | [@BrenoLUCO](https://github.com/BrenoLUCO) |
| Felipe Santos Veríssimo | [@verissimoo](https://github.com/verissimoo) |
| Kauã Richard de Souza Cavalcante | [@rich4rd1](https://github.com/rich4rd1) |
| Lucas Freire Lopes | [@AguionStryke](https://github.com/AguionStryke) |
| Mateus Vinicius Vieira | [@matix0](https://github.com/matix0) |
| Philipe Barbosa de Morais | [@PhMoraiis](https://github.com/PhMoraiis) |
| Pietro Calegari Visentin | [@Pietrocv](https://github.com/Pietrocv) |
| Vinicius Fernandes Rufino | [@RufinoVfR](https://github.com/RufinoVfR) |
