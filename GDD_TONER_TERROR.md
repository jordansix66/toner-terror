# Toner Terror — Game Design Document

**Versão:** 0.2  
**Data:** 14 de setembro de 2026  
**Estado:** protótipo de validação  
**Engine:** Godot 4 com GDScript  
**Modelo comercial:** compra única, sem microtransações

> Este documento descreve a direção pretendida para o jogo. Recursos da versão comercial continuam condicionados à aprovação do protótipo por testes com jogadores.

## 1. Conceito do jogo

### Resumo

**Toner Terror** é um jogo de comédia sobrenatural, gerenciamento e cooperação em que uma pequena gráfica funciona durante o turno da madrugada. O jogador recebe lotes de serviços, percorre postos de trabalho e transforma documentos por meio de cópia, corte, grampeamento, colagem e outros acabamentos. Ao final de cada noite, o lucro é usado para comprar equipamentos e ampliar a operação. Conforme as noites avançam, máquinas, papéis e funcionários podem ser afetados por maldições que alteram regras e controles.

### Frase de apresentação

Administre uma gráfica no turno da madrugada, entregue lotes de papel em várias bancadas e sobreviva às maldições que transformam erros de produção em caos paranormal.

### Gênero

- Gerenciamento de tempo e fluxo de produção.
- Simulação acessível de tarefas manuais.
- Roguelike com progressão entre noites.
- Cooperação assimétrica na segunda fase do desenvolvimento.
- Comédia de terror leve, sem foco em violência gráfica ou sustos intensos.

### Plataformas

- **Principal:** Windows, com lançamento pretendido na Steam.
- **Possível depois da validação:** Android, utilizando o mesmo projeto com interface adaptada para toque.
- O protótipo será desenvolvido e testado primeiro no Windows.

### Público-alvo

- Pessoas de diferentes idades, com linguagem visual acessível e conteúdo familiar.
- Apelo principal para público jovem e jovem adulto, sem restringir o jogo a essa faixa.
- Jogadores que gostam de cooperação, tarefas rápidas, organização sob pressão e humor absurdo.
- Fãs de jogos de cozinha e produção em equipe, com postos de trabalho e divisão espontânea de funções.
- Criadores de conteúdo que procuram situações inesperadas e fáceis de mostrar em vídeos curtos.

A classificação indicativa oficial será definida mais adiante conforme o conteúdo final das maldições, textos e efeitos visuais. A direção atual evita gore, linguagem pesada e terror perturbador.

### Proposta

Entregar a satisfação tátil e sonora de operar equipamentos de gráfica, a tensão de organizar uma linha de produção e a surpresa de consequências sobrenaturais. O jogo deve ser fácil de começar, permitir estratégias diferentes de divisão do trabalho e gerar histórias engraçadas a cada noite.

### Pilares de design

1. **Trabalho manual satisfatório:** copiar, cortar, grampear e colar devem ser agradáveis por imagem, ritmo e som.
2. **Fluxo legível:** o jogador precisa entender onde o lote está, qual é a próxima etapa e por que houve um erro.
3. **Estratégias flexíveis:** no multiplayer, jogadores podem se especializar, trocar de posto ou conduzir um lote inteiro.
4. **Erros divertidos:** falhar deve produzir uma reação clara e engraçada, não apenas retirar pontos.
5. **Noites diferentes:** compras e maldições criam combinações variadas sem exigir uma quantidade impossível de conteúdo.
6. **Complexidade gradual:** o tutorial ensina o básico e novas ferramentas são explicadas por textos curtos quando aparecem.

## 2. Gameplay

### O que o jogador faz

1. Recebe um lote com quantidade, documento, tamanho, corte e acabamento exigidos.
2. Leva o lote até o primeiro posto necessário.
3. Configura e opera copiadora, guilhotina, bancada de grampeamento, cola ou outro equipamento.
4. Move o trabalho entre as etapas na ordem correta.
5. Confere unidades potencialmente defeituosas e refaz o que estiver errado.
6. Entrega o lote concluído e recebe pagamento conforme velocidade, precisão e desperdício.
7. Repete o processo até o encerramento da noite.
8. Usa o lucro para comprar equipamentos, ferramentas e novas bancadas antes da noite seguinte.

### Referência de ritmo

A jogabilidade segue a lógica de jogos no estilo **Let's Cook**: pedidos entram, tarefas são distribuídas entre postos, produtos passam por várias etapas e a equipe precisa evitar gargalos. Toner Terror diferencia essa estrutura pelo trabalho de gráfica, pela progressão roguelike entre noites e pelas maldições que alteram equipamentos, produtos e jogadores.

### Controles

#### Protótipo no Windows

- **Mouse:** selecionar lotes, opções, ferramentas e ações das bancadas.
- **Botão esquerdo:** mover o personagem ou cursor, interagir e operar equipamentos.
- **Teclado:** movimentação e atalhos poderão ser adotados quando a estrutura espacial da gráfica estiver definida.
- O tutorial inicial apresenta movimentação, retirada de pedidos, primeira cópia e entrega.
- Novas ferramentas são explicadas por textos curtos na tela de compra e na primeira utilização.

#### Adaptações futuras

- **Tela de toque:** os mesmos botões, com áreas grandes e sem depender de passar o ponteiro sobre elementos.
- **Teclado e controle:** atalhos e navegação por foco poderão ser adicionados por acessibilidade, após a validação.

### Loop principal

```text
Receber lote de trabalho
      ↓
Planejar a sequência de bancadas
      ↓
Copiar → cortar → grampear/colar → conferir
      ↓
Entregar lote → receber pagamento
Erro ou maldição → conferir e refazer unidades
      ↓
Encerrar noite → comprar e reorganizar equipamentos
      ↓
Iniciar nova noite com regras e maldições diferentes
```

### Duração pretendida

- **Primeiro protótipo:** uma rodada de 5 a 10 minutos com poucos lotes e uma linha de produção curta.
- **Versão comercial, hipótese:** noites de 10 a 20 minutos e campanha total definida por testes de repetição e progressão.

## 3. Mecânicas

### Cópia

- Cada clique produz uma cópia e consome uma unidade de toner.
- O jogador precisa atingir a quantidade exata solicitada.
- A máquina fornece resposta visual e sonora a cada cópia.

### Seleção de documento

O protótipo usa três tipos:

- **Memo:** memorando interno.
- **Invoice:** fatura do escritório.
- **Photo:** fotografia de funcionário ou objeto suspeito.

Cada pedido indica qual original deve ser usado. Documentos especiais poderão ter efeitos exclusivos na versão comercial.

### Tamanho

- **50%:** redução.
- **100%:** tamanho normal.
- **150%:** ampliação.

O tamanho errado produz uma cópia defeituosa ou uma anomalia proporcional ao erro.

### Acabamento

- **None:** sem acabamento.
- **Stamp:** documento carimbado.
- **Staple:** documento grampeado.

Sobreposição de documentos é uma possibilidade futura e não faz parte do primeiro protótipo.

### Corte com guilhotina

- O lote é posicionado na bancada de corte.
- O jogador alinha o papel usando marcações visuais e aciona a lâmina.
- Pedidos podem exigir formato inteiro, meio papel, tiras ou medidas especiais.
- Um corte incorreto desperdiça aquela unidade e exige reposição.
- A interação deve transmitir precisão sem exigir movimentos realistas excessivamente difíceis.

### Grampeamento

- O jogador posiciona o lote e aplica um ou mais grampos no local solicitado.
- Quantidade e posição podem variar conforme o pedido.
- Grampeadores melhores trabalham com mais folhas ou têm menor chance de emperrar.

### Colagem

- O jogador aplica cola e une as partes indicadas pelo pedido.
- Excesso, falta ou posição errada podem reduzir a qualidade ou exigir refação.
- A versão inicial deve usar uma interação simples e legível, evitando simulação física complexa.

### Fluxo de produção

- Cada lote possui uma sequência de etapas.
- O jogador transporta o lote entre bancadas e acompanha seu estado visualmente.
- Algumas etapas são opcionais; executar uma operação não solicitada também constitui erro.
- No multiplayer, vários lotes podem estar em processamento simultaneamente.

### Toner

- Cada cópia reduz a reserva de toner.
- Com o toner vazio, a máquina para até o cartucho ser trocado.
- A troca deve ser rápida e claramente comunicada.
- Futuramente poderão existir cartuchos defeituosos ou cores incomuns, desde que acrescentem decisões e não apenas trabalho repetitivo.

### Erros e anomalias

Erros de documento, tamanho, corte ou acabamento podem afetar uma unidade ou comprometer o lote. Maldições também podem criar defeitos que precisam ser encontrados durante a conferência. Exemplos:

- A copiadora prende o papel.
- Uma cópia do chefe escapa da bandeja.
- Os grampeadores começam a sussurrar.
- Uma fotografia recebe olhos adicionais.
- O escritório passa a ter um “andar 13”.
- Os controles de uma bancada ficam invertidos.
- As opções da copiadora mudam de posição.
- Cópias assumem formatos estranhos e precisam ser avaliadas uma a uma.

Unidades defeituosas devem ser separadas e refeitas. As consequências do protótipo podem ser apresentadas por texto, cor, tremor e animação simples. Na produção, algumas serão eventos visuais completos e afetarão temporariamente o fluxo da gráfica.

### Pontuação

- A medida principal de desempenho é o **lucro da noite**.
- Entregas corretas geram receita; atraso, desperdício e refação reduzem a margem.
- Sequências sem erro e entregas rápidas podem conceder bônus.
- A pontuação de desempenho pode existir separadamente para avaliação, mas as compras usam o lucro.
- Uma noite ruim não deve tornar impossível continuar; o jogo precisa oferecer recuperação.

### Combate

Não existe combate tradicional. A tensão vem da máquina, das regras e das consequências. Caso uma anomalia exija reação, ela será resolvida com controles da bancada, não com armas ou movimentação de personagem.

### Movimentação

O jogador se desloca pela gráfica entre o balcão de pedidos, equipamentos, bancadas e área de entrega. O espaço deve ser compacto e legível, com distâncias curtas. No primeiro protótipo, a movimentação pode ser simplificada para selecionar postos; a forma final — personagem controlado diretamente ou transição por cliques — será decidida por teste.

### Inventário

O inventário é operacional, compartilhado pela gráfica, e inclui:

- Lotes em andamento.
- Papel e documentos originais.
- Toner.
- Grampos.
- Cola e materiais de acabamento.
- Ferramentas e equipamentos adquiridos.

O protótipo não precisa simular todos os consumíveis. Só entram recursos que criem decisões claras.

### Habilidades e melhorias

Não existem habilidades especiais no primeiro protótipo. A progressão acontece principalmente pela compra e disposição de equipamentos:

- Copiadoras mais rápidas ou com maior capacidade de toner.
- Guilhotinas com guias mais precisas.
- Grampeadores capazes de processar lotes maiores.
- Bancadas adicionais para reduzir filas.
- Ferramentas de conferência e identificação de defeitos.
- Carrinhos ou áreas de armazenamento para organizar lotes.

Melhorias devem ampliar estratégias e capacidade produtiva sem automatizar completamente o trabalho manual.

## 4. Progressão

### Protótipo

- Uma noite curta com poucos lotes.
- Tutorial inicial de retirada, cópia, acabamento e entrega.
- Linha mínima com copiadora e duas tarefas de acabamento representativas.
- Tela final informa lucro, entregas, desperdício e erros.
- Uma compra simples ao final permite testar a sensação de progressão.

### Versão comercial proposta

- Estrutura roguelike dividida em noites de trabalho.
- Cada noite apresenta uma combinação de pedidos, modificadores e eventos parcialmente aleatórios.
- O lucro final é utilizado para comprar equipamentos, bancadas, ferramentas e melhorias.
- O jogador decide como organizar a gráfica e quais gargalos resolver.
- A campanha termina por uma meta definida de noites ou por um evento final; o formato exato será validado antes da produção.
- A dificuldade cresce pela combinação de etapas e maldições, não por comandos escondidos.

### Curva de dificuldade sugerida

1. Receber, copiar e entregar um lote simples.
2. Ampliação, redução e controle de toner.
3. Corte, carimbo, grampeamento e colagem.
4. Vários lotes simultâneos e gestão de suprimentos.
5. Compra, disposição e especialização de bancadas.
6. Documentos especiais, maldições e necessidade de inspeção.
7. No multiplayer, sabotador e efeitos que alteram postos ou controles.

### Desbloqueios

- Novos documentos e produtos gráficos.
- Novas etapas de produção.
- Equipamentos, ferramentas e bancadas compráveis.
- Maior capacidade de suprimentos e armazenamento.
- Consequências sobrenaturais adicionais.
- Novos modificadores de noite e maldições.
- Modo multiplayer e regra do sabotador apenas na segunda fase do desenvolvimento.
- Modo de turno infinito, somente depois da campanha ou de uma meta clara.

### Recompensas

- Lucro para reinvestir na gráfica.
- Avaliação ao final da noite.
- Novos memorandos que revelam a história.
- Adesivos, objetos de mesa ou alterações visuais sem compra adicional.
- Finais ou epílogos baseados no desempenho.

Nenhum desbloqueio será vendido separadamente.

## 5. Fases e mapas

### Estrutura principal

O jogo acontece dentro de uma gráfica compacta, organizada em postos de trabalho. Não há mundo aberto nem exploração extensa. O mapa é o próprio espaço de produção, e sua disposição interfere no tempo gasto para transportar lotes e na colaboração entre jogadores.

Postos previstos incluem:

- Balcão de entrada e saída de pedidos.
- Fotocopiadora.
- Guilhotina.
- Bancada de grampeamento e carimbo.
- Bancada de colagem.
- Armazenamento de materiais e área de inspeção.

### Estrutura de partida

- Planejamento e compras antes da abertura.
- Início da noite.
- Entrada de lotes com sequências diferentes de produção.
- Divisão ou rotação de funções entre os jogadores.
- Introdução de eventos e maldições.
- Encerramento da noite com cálculo de receita, custos, desperdício e lucro.
- Compra e reorganização da gráfica antes da próxima noite.

### Variação ambiental

A mesma gráfica muda durante a campanha:

- Luzes piscam ou mudam de cor.
- Papéis acumulam na bancada.
- Objetos aparecem em locais errados.
- Recados da administração ficam mais estranhos.
- A copiadora ganha marcas, olhos ou peças improvisadas.
- Novas bancadas ocupam espaço e alteram as rotas de trabalho.
- Equipamentos amaldiçoados exigem inspeção ou operação diferente.

Outras filiais e mapas distintos ficam fora da primeira versão, salvo se os testes mostrarem necessidade real.

## 6. Arte e interface

### Estilo visual

- Pixel art 2D estilizada, expressiva e legível.
- Escritório noturno com cores escuras, verde de monitor e rosa de alerta sobrenatural.
- Equipamentos com silhuetas claras, animações exageradas e detalhes mecânicos reconhecíveis.
- Aparência de tecnologia corporativa antiga, sem buscar realismo fotográfico.
- Efeitos modernos de luz, partículas e distorção podem complementar a pixel art sem prejudicar sua nitidez.

### Composição da tela

- **Área principal:** mapa compacto da gráfica, personagens, lotes e postos de trabalho.
- **HUD:** noite atual, tempo, lucro, pedidos e alertas de materiais.
- **Ao interagir com um posto:** painel legível com configurações e ação da ferramenta.
- **Entre noites:** tela de compras, melhorias e organização da gráfica.
- **Sobreposição:** consequências importantes, tutorial e resultado da noite.

### HUD

O HUD mostra apenas informações necessárias:

- Noite e tempo restante.
- Lucro atual e custos acumulados.
- Fila de pedidos e prazo de cada lote.
- Etapas concluídas e próxima etapa do lote carregado.
- Níveis de toner e outros materiais relevantes.
- Estado de equipamentos e maldições ativas.
- Mensagem de erro, inspeção ou refação.

### Menus previstos

- Tela inicial: jogar, opções e sair.
- Pausa: continuar, reiniciar turno, opções e voltar ao menu.
- Opções: volumes separados, tela, idioma e acessibilidade.
- Resultado do turno: desempenho e próxima ação.

O protótipo precisa apenas da partida e da tela de resultado.

### Animações

- Papel entrando e saindo.
- Luz do scanner atravessando o documento.
- Botões pressionados e visor reagindo.
- Lâmina da guilhotina cortando o papel.
- Grampeador comprimindo o lote.
- Cola sendo aplicada e peças sendo unidas.
- Personagens carregando, entregando e inspecionando trabalhos.
- Tremor da máquina em erros.
- Fumaça, toner ou deformação visual em anomalias.
- Transições curtas; nenhuma animação deve atrasar repetidamente o jogador.

### Acessibilidade visual

- Texto com bom contraste e tamanho ajustável na produção.
- Seleções indicadas por forma e texto, não apenas por cor.
- Opção de reduzir tremores e flashes.
- Interface utilizável em diferentes proporções de tela.
- Não depender de letras minúsculas nos documentos para informações essenciais.

## 7. Áudio

### Direção musical

- Música ambiente discreta, com clima de gráfica vazia e humor inquietante.
- Camadas adicionais podem surgir conforme erros e anomalias aumentam.
- A música não deve encobrir os sons funcionais e ASMR dos equipamentos.
- Deve existir opção para reduzir ou desligar a música e destacar os sons do trabalho.

### Efeitos sonoros essenciais

- Cliques e bipes diferentes para selecionar e confirmar configurações.
- Motor, ventilação e luz do scanner.
- Papel sendo puxado, deslizando, dobrando e saindo.
- Corte seco e satisfatório da guilhotina.
- Impacto mecânico do grampeador e queda dos grampos.
- Aplicação de cola, pressão e separação de superfícies.
- Carimbo e manuseio de lotes.
- Aviso de toner baixo ou vazio.
- Papel preso.
- Som de sucesso.
- Vinheta sobrenatural curta para erros especiais.

Os sons de operação têm função ASMR e são parte central da identidade do jogo. Devem ser limpos, próximos e variados o suficiente para não cansar durante ações repetidas.

### Vozes

- Não haverá dublagem no protótipo.
- A versão comercial poderá usar mensagens distorcidas da copiadora ou do interfone em quantidade pequena.
- A história deve continuar compreensível sem vozes, facilitando localização e acessibilidade.

### Opções de áudio

- Volume geral.
- Volume da música.
- Volume dos efeitos.
- Vozes, caso sejam adicionadas.

## 8. História e personagens

### Premissa

O jogador assume o turno da madrugada de uma pequena gráfica com equipamentos antigos e regras estranhamente específicas. A peça mais suspeita é uma copiadora chamada **Night Owl Copymaster 3000**, mas a maldição gradualmente se espalha para documentos, ferramentas, bancadas e funcionários. Durante as noites, os pedidos revelam que a gráfica não apenas reproduz documentos: ela pode reproduzir, alterar ou libertar aquilo que eles representam.

### Personagem do jogador

- No modo solo, um funcionário controlável realiza todas as etapas da produção.
- A aparência deve ser simples e personalizável por opções gratuitas conquistadas no jogo.
- A personalidade é expressa principalmente pelas decisões de compra, organização e resposta às maldições.

### Copiadora

- Principal presença sobrenatural inicial e antagonista cômica.
- Comunica-se pelo visor, sons e comportamento.
- Alterna entre ferramenta útil, animal temperamental e entidade sobrenatural.

### Administração

- Aparece por memorandos, pedidos, mensagens e avaliações.
- Trata eventos impossíveis como problemas burocráticos normais.
- Pode estar escondendo a origem da máquina.

### Funcionários do escritório

- Surgem por fotografias, faturas, bilhetes e consequências das cópias.
- Não exigem personagens animados completos na versão 1.

### Arco narrativo proposto

1. As primeiras noites começam como trabalho comum em uma gráfica pequena.
2. Regras absurdas indicam que a copiadora é perigosa.
3. A operação cresce com o lucro e novos equipamentos também passam a apresentar comportamentos estranhos.
4. Os pedidos sugerem que a administração e alguns clientes conhecem a maldição.
5. A máquina passa a testar ou manipular os funcionários.
6. O desempenho e as decisões de expansão determinam um epílogo cômico ou inquietante.

A história deve apoiar o gameplay; não haverá longas cenas interrompendo os pedidos.

## 9. Monetização

### Modelo escolhido

- Compra única.
- Preço baixo, decidido somente após validar qualidade, duração e concorrência.
- Possível demonstração gratuita separada.

### O que não existirá

- Anúncios.
- Microtransações.
- Moeda premium.
- Passe de temporada.
- Venda de vidas, energia ou vantagens.
- Skins pagas planejadas.
- Caixas de recompensa.

Atualizações pequenas de correção e qualidade serão gratuitas. Expansões pagas só seriam consideradas no futuro se trouxessem conteúdo substancial e se o jogo base já estivesse completo.

## 10. Multiplayer

### Fase 1 — solo

- O primeiro ciclo jogável e a primeira validação são exclusivamente solo.
- Um jogador recebe pedidos, percorre postos, executa todas as etapas e administra as compras.
- Essa fase prova se cada tarefa é clara e satisfatória antes de multiplicar a complexidade.

### Fase 2 — cooperação

- Vários jogadores trabalham simultaneamente na mesma gráfica.
- Cada jogador pode ocupar um ou mais postos de trabalho.
- As funções não são obrigatoriamente fixas.
- A equipe pode escolher estratégias diferentes conforme o mapa, os equipamentos e os pedidos.

Estratégias possíveis:

- **Especialização:** cada pessoa permanece responsável por uma bancada.
- **Apoio flexível:** jogadores mudam de posto para resolver filas e emergências.
- **Rotação por lote:** uma pessoa conduz um trabalho por todas as etapas, e a responsabilidade muda no lote seguinte.
- **Duplas de produção:** uma pessoa prepara e configura; outra finaliza, inspeciona e entrega.

O design não deve declarar uma única divisão correta. A graça vem da comunicação e da adaptação da equipe.

### Sabotador amaldiçoado

Depois de algumas noites iniciais, o jogo passa a escolher aleatoriamente um jogador para receber a função de sabotador naquela operação ou noite.

O sabotador continua participando do trabalho, mas também pode escolher um alvo para a maldição:

- Uma bancada de trabalho.
- Um equipamento específico.
- Outro jogador.

Possíveis efeitos:

- Controles temporariamente invertidos.
- Opções da copiadora embaralhadas ou trocando de posição.
- Equipamento mais difícil ou lento de operar.
- Cópias com formas, proporções ou marcas estranhas.
- Defeitos ocultos que obrigam a equipe a avaliar as unidades individualmente.
- Necessidade de separar e refazer cópias defeituosas antes da entrega.

A sabotagem precisa ser limitada, temporária e recuperável. Ela deve criar desconfiança e situações engraçadas sem permitir que uma pessoa destrua toda a campanha ou deixe outra sem jogar. Frequência, duração, identidade secreta ou revelada e recompensa do sabotador serão definidas por testes específicos na segunda fase.

### Tecnologia e modos

- A primeira implementação multiplayer deve priorizar jogo local.
- Compartilhamento remoto da sessão pode ser considerado antes de criar rede própria.
- Matchmaking, contas, servidores dedicados e multiplayer on-line nativo não pertencem à primeira fase.
- Ranking global não está planejado; resultados locais por equipe podem ser registrados.

## 11. Escopo do protótipo de validação

### Incluído

- Uma gráfica compacta com postos representados de forma temporária.
- Tutorial solo básico.
- Uma copiadora visual temporária.
- Uma guilhotina e uma bancada simples de acabamento.
- Três documentos.
- Três tamanhos.
- Corte, grampeamento e colagem em versões simplificadas.
- Quantidades de 1 a 4.
- Toner e troca de cartucho.
- Poucos lotes por noite.
- Lucro, tela de resultado e uma compra simples entre noites.
- Algumas consequências apresentadas por texto, cor e animação simples.
- Versão executável para Windows.

### Excluído

- Multiplayer e sabotador.
- Campanha completa.
- Arte e áudio definitivos.
- Loja, conquistas e Steamworks.
- Android configurado e publicado.
- Sobreposição de documentos.
- Física complexa de papel.
- Servidores e contas.

## 12. Critério para avançar à produção

O protótipo só será aprovado se, em teste com pelo menos cinco pessoas que não conheçam o jogo:

- Quatro entenderem o primeiro pedido em até dois minutos sem explicação verbal.
- Quatro completarem o turno.
- A diversão receber média mínima de 3,5 em 5.
- Pelo menos três quiserem jogar outra rodada.
- Nenhuma falha impedir uma sessão de 15 minutos.

Se esses resultados não forem atingidos depois de uma rodada curta de correções, o conceito será reformulado ou arquivado antes de qualquer gasto com publicação ou arte final.

O multiplayer possui um portão separado: somente depois do ciclo solo aprovado será criado um teste local de divisão de postos. A regra do sabotador será testada depois que a cooperação normal já for divertida e compreensível, para que não esconda problemas básicos do fluxo de produção.
