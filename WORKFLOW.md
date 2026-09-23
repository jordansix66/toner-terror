# Fluxo de pedidos

O jogo começa no balcão de atendimento. Um pedido pode conter vários lotes,
cada um com documento, quantidade, escala, carimbo, corte e acabamento próprios.
Há um pedido ativo por vez. O primeiro reproduz o exemplo de 5 memorandos a 50%
com carimbo, 15 faturas a 150% com grampo e 30 fotos a 100% com corte.
Depois da entrega, os próximos pedidos têm 2–3 lotes variados.

1. Confira e receba o pedido no balcão.
2. Na fotocopiadora, selecione o lote, documento, escala e carimbo. Escolha
   quantas folhas imprimir por acionamento, respeitando o toner disponível.
   Reponha o toner para continuar; a impressão parcial é preservada.
3. Corte somente os lotes que pedirem corte: tesoura para 1–5 folhas no lote;
   guilhotina para 6 ou mais.
4. Na mesa de encadernamento, grampeie ou encaderne conforme o pedido.
   As duas opções são mutuamente exclusivas e acontecem depois do corte,
   quando ele for necessário.
5. Embale cada lote. Retorne ao balcão e entregue o pedido completo.

Use o seletor de lotes para trabalhar em vários lotes na mesma estação.
O botão de navegação indica o próximo destino do lote selecionado.
Sair da bancada ou voltar ao menu preserva o trabalho durante a sessão.
Ainda não há salvamento do pedido em disco ao fechar o jogo.

Erros de configuração não avançam o lote e descontam até 25 pontos.
Uma impressão incorreta consome toner. É possível corrigir e tentar novamente.
Cada lote entregue concede 100 pontos; embalagem e entrega duplicadas são bloqueadas.

## Estrutura e testes

game_state.gd centraliza pedidos, pré-requisitos e mutações de progresso.
workflow_station.gd compartilha a interface das cinco bancadas, sobre o layout
da fotocopiadora. main.gd e cutting_station.gd são entradas dessas cenas.

Com o Godot no PATH, execute:

    godot --headless --path . --script res://tests/workflow_test.gd
    godot --headless --path . --script res://tests/workflow_ui_test.gd

Os testes cobrem o pedido de exemplo, fluxo pelos controles, trocas de bancada,
impressão parcial, bloqueios, corte em 1/5/6/30 folhas, grampeamento versus
encadernação, embalagem, entrega e recebimento do pedido seguinte.

As imagens de balcão v3, encadernamento v4 e embalagem v2 já estavam no workspace
e agora são referenciadas pelo jogo. Inclua-as com seus arquivos .import no commit.
