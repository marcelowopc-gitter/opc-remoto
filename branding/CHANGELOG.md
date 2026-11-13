# Histórico de versões - OPC Remoto

Cada versão publicada no portal de suporte. O SHA-256 é o do exe em `/baixar`.

## opc-1.5.3-r5 - (em teste)
Base: RustDesk 1.5.3. Só o app do cliente muda (técnico continua o r4).
- Whitelist: o OPC Remoto só aceita conexões vindas do IP de saída do NOC/VPN
  (`WHITELIST` em app.env, hoje 187.86.63.2). De outra rede o técnico recebe
  "Your ip is blocked by the peer", mesmo com ID e senha certos.

## opc-1.5.3-r4 - 2026-11-13
Base: RustDesk 1.5.3. Commit `baeace9`.
SHA-256 (cliente, site): `8df3d9e65216bc7ea8cbe550819e46135e83f94f08cff89948c700c9db595ad1`
SHA-256 (técnico, interno): `a64aa623b0fd57a0f7a4c36a62fded9738263be4013cff7cf9fa0a75beadd0c2`
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
