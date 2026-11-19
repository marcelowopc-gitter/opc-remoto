# Histórico de versões - OPC Remoto

Cada versão publicada no portal de suporte. O SHA-256 é o do exe em `/baixar`.

## opc-1.5.3-r8 - 2026-11-19 (atual)
Base: RustDesk 1.5.3. Commit `a10ae42`. Só o app do cliente muda (técnico continua o r4:
o limite de ociosidade é aplicado pelo lado que recebe a conexão).
SHA-256 (cliente, site): `79a1a1d0acc23492fb19d44c6ec5a62b38a9e9cd8ce48a4205193380df3907ea`
- Sem limite de ociosidade: a sessão não cai mais após 15 min parada. Só cai
  se o cliente fechar o app ou a conexão cair. A senha temporária continua a
  mesma enquanto o app estiver aberto (r7), então dá para reconectar.

## opc-1.5.3-r7 - 2026-11-18
Base: RustDesk 1.5.3. Commit `1ddcaa5`. Só o app do cliente muda (técnico continua o r4).
SHA-256 (cliente, site): `b9e784ec5a23b422b95f891244e67af6c341026862b923a3c2e8d55d03d92ab3`
- Senha temporária fixa enquanto o app estiver aberto: não troca mais a cada
  acesso. Se a sessão cair (ociosidade de 15 min, rede), o técnico reconecta com
  a mesma senha. Fechar e abrir o app gera senha nova. Continua trocando sozinha
  após 10 senhas erradas seguidas, e o cliente pode trocar no botão de atualizar.
  Whitelist do NOC continua.

## opc-1.5.3-r6 - 2026-11-13
Base: RustDesk 1.5.3. Commit `291dd11`. Só o app do cliente muda (técnico continua o r4).
SHA-256 (cliente, site): `7f7a660f7ec7934bbde796380156666c68b86c7ff889398f2b04328250ab46dc`
- Terminal remoto (PowerShell/cmd) LIGADO para o técnico.
- Modo privacidade (tela preta no cliente) DESLIGADO: o cliente sempre vê a tela.
- Mantidos: tela/teclado/mouse, arquivos, área de transferência, áudio, bloqueio
  de teclado/mouse e reinício remoto. Whitelist do NOC continua.

## opc-1.5.3-r5 - 2026-11-13
Base: RustDesk 1.5.3. Commit `2a4c6ae`. Só o app do cliente muda (técnico continua o r4).
SHA-256 (cliente, site): `ace8b6f4624e8ce5b4d28ca5932df2fa72d71b69bae97f7cb5e1614b2c482bba`
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
