# Marca OPC Remoto (Opção Telecom)

Arquivos usados pelo workflow `rustdesk-custom-windows.yml` (opção "Aplicar marca").

- `app.env` - nome do app, nome do executável, empresa e links. Mude aqui.
- `apply.sh` - aplica nome, oculta telas de Rede/Servidor/Proxy, ajusta a tela
  "Sobre", cores, metadados do exe e copia ícones/logos gerados. Cada troca é
  conferida; se o código mudar, o build falha cedo.
- `gen_brand.py` - desenha o ícone e gera logos e a imagem da tela de extração.
- `logo-opcao-telecom.png.b64` - logo Opção Telecom (PNG em base64, SHA-256 conferido).

Licença: este programa é derivado de software livre sob GNU AGPL-3.0. A tela
"Sobre" mantém o aviso de licença e o link do código-fonte, como a licença exige.
