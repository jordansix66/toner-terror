# Padrão de iluminação — Toner Terror

Decisão do usuário: todas as próximas imagens e modelos devem ter três versões de iluminação: claro, médio e escuro.

- Claro: interior limpo, iluminação branca uniforme e boa visibilidade. Referência aprovada: `shop-interior-empty-clean-night-v1.png`.
- Médio: iluminação amarelada/âmbar localizada, sombras azuladas e visibilidade reduzida, seguindo a referência da mesa de encadernação enviada pelo usuário. Cenário: `shop-interior-empty-medium-night-v1.png`.
- Escuro: luzes apagadas, quase nenhuma iluminação, contornos residuais frios e detalhes difíceis de enxergar. Cenário: `shop-interior-empty-dark-night-v1.png`.

As três versões de cada arte devem manter enquadramento, dimensões, perspectiva, objetos e escala da pixel art. Variar somente a iluminação. O interior vazio usa 1672 × 941 pixels; a câmera e a arquitetura são fixas. Conferir o alinhamento das versões antes de integrar transições ao jogo.

Manter a gráfica limpa nesta fase, sem sangue, sujeira ou danos. Preservar as versões anteriores em arquivos separados.

## Geração destas variantes

Ferramenta: edição de imagens integrada (imagegen).

Prompt médio: alterar apenas a iluminação da sala vazia aprovada, usando luz âmbar discreta dos painéis existentes e sombras azul-violeta conforme a referência enviada. Preservar arquitetura e todos os elementos.

Prompt escuro: alterar apenas a iluminação da mesma base, apagando os painéis e deixando iluminação residual azul quase imperceptível. Preservar arquitetura e todos os elementos.
