# Histórico de versões - OPC Remoto

Cada versão publicada no portal de suporte. O SHA-256 é o do exe em `/baixar`.

## opc-1.5.3-r4 - (em teste)
Base: RustDesk 1.5.3.
- Dois apps no mesmo workflow (campo "variante"):
  - **OPC Remoto** (cliente, site): só recebe conexões; não dá para usar o app
    do site para acessar outro computador.
  - **OPC Tecnico** (NOC, interno): só conecta; grava toda sessão
    automaticamente. Não publicar no site.
- Artifact do técnico: `opc-tecnico-windows-x64`.

## opc-1.5.3-r3 - 2026-11-12
Base: RustDesk 1.5.3. Commit `801daa7`.
SHA-256: `6918a5334833ef1f2c3393381da2a95739d8cd4e32f4be0025de28ec895f8d20`
- Login/conta desligado (aba Conta, botão Login, catálogo e grupos ocultos).
- ID não pode ser trocado pelo usuário.
- Terminal remoto, câmera, impressora remota e descoberta na LAN desligados.
- Workflow renomeado para "OPC Remoto (Windows x64)", artifact `opc-remoto-windows-x64`.

## opc-1.5.3-r2 - 2026-11-12
Commit `3031a1b`. SHA-256: `5ba63ad0608f0ce57a9ad7f973b6c8b2cde3b2d00094e85d0ec678b925f84fca`
- Só senha temporária; tela Segurança oculta; túnel TCP desligado.
- Sessão ociosa cai em 15 min; aceite por senha ou clique.
- Instalação como serviço bloqueada (só portátil).

## opc-1.5.3-r1 - 2026-11-12
- Primeira versão com a marca OPC Remoto (nome, ícones, cores, metadados).
