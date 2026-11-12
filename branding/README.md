# Marca OPC Remoto / OPC Tecnico (Opção Telecom)

Arquivos usados pelo workflow `rustdesk-custom-windows.yml` (opção "Aplicar marca").
O workflow gera um de dois apps, escolhido no campo **variante**:

| Variante | App | Uso | Conexão |
|---|---|---|---|
| `cliente` | OPC Remoto (`opc-remoto-…exe`) | público, baixado no site | **só recebe**: não tem "conectar a outro ID" |
| `tecnico` | OPC Tecnico (`opc-tecnico-…exe`) | interno do NOC, **não publicar** | **só conecta** e grava toda sessão (pasta Vídeos) |

Assim, quem baixar o app do site não consegue usá-lo para acessar outro
computador, e a máquina do técnico não pode ser acessada por ninguém.

- `app.env` - nome, executável, empresa e links do app do cliente.
- `app-tecnico.env` - o mesmo para o app do técnico (nome próprio: config e
  pasta separadas, os dois podem rodar na mesma máquina).
- `apply.sh` - aplica nome, oculta telas de Rede/Servidor/Proxy, ajusta a tela
  "Sobre", cores, metadados do exe e copia ícones/logos gerados. Cada troca é
  conferida; se o código mudar, o build falha cedo. Variante pela variável
  `VARIANTE` (padrão `cliente`).
  Segurança forçada (o usuário não altera): só senha temporária, tela de
  Segurança oculta, túnel TCP desligado, sessão ociosa cai em 15 min, aceite por
  senha ou clique, instalação como serviço bloqueada (só portátil), login/conta
  desligado, ID fixo, terminal remoto, câmera, impressora remota e descoberta
  na rede local desligados, tipo de conexão fixo pela variante.
- `gen_brand.py` - desenha o ícone e gera logos e a imagem da tela de extração.
- `logo-opcao-telecom.png.b64` - logo Opção Telecom (PNG em base64, SHA-256 conferido).
- `CHANGELOG.md` - histórico das versões publicadas.

Licença: este programa é derivado de software livre sob GNU AGPL-3.0. A tela
"Sobre" mantém o aviso de licença e o link do código-fonte, como a licença exige.
