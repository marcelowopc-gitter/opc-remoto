# Marca Suporte OPC

Arquivos usados pelo workflow `rustdesk-custom-windows.yml` (passo "Aplicar marca").

- `apply.sh` - troca nome do app (SuporteOPC), oculta telas de Rede/Servidor/Proxy,
  aplica cor de destaque, metadados do exe e copia os ícones/logos gerados.
  Cada troca é conferida; se o código do RustDesk mudar, o build falha cedo.
- `gen_brand.py` - desenha o ícone (anel "O" branco, traço vermelho, fundo marinho/azul)
  e gera logos claro/escuro e a imagem da tela de extração a partir do logo.
- `logo-opcao-telecom.png.b64` - logo Opção Telecom (PNG em base64, SHA-256 conferido).

Para mudar a marca, edite estes arquivos; o workflow não precisa ser alterado.

Código baseado no RustDesk (AGPL-3.0): https://github.com/rustdesk/rustdesk
