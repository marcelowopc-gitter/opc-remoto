# Portal de suporte (suporteopc.duckdns.org:8088)

Cópia versionada dos arquivos do portal. O que vale é o que está no servidor;
ao mudar lá, atualize aqui também.

| Arquivo | No servidor |
|---|---|
| `index.html.tpl` | `/home/temperonmusk/rustdesk-build/index.html.tpl` |
| `nginx.conf` | `/opt/rustdesk-web/nginx.conf` (bind mount de arquivo: trocar com `cat >`, nunca `mv`) |
| `quadro-tecnico.html` | `/opt/rustdesk-web/quadro-tecnico.html` |
| `gerar-pagina-noc.sh` | `/opt/rustdesk-web/gerar-pagina-noc.sh` |
| `docker-compose.yml` | `/opt/rustdesk-web/docker-compose.yml` |

Fora daqui (não versionar): `certs/`, `acme/` (token DuckDNS), os binários em
`site/files` e `site/tecnico`, e as fontes em `site/fonts` (Lato, OFL).

## Publicar a página
```bash
W=/opt/rustdesk-web; T=/home/temperonmusk/rustdesk-build/index.html.tpl; TS=$(date +%Y%m%d-%H%M%S)
sudo cp -a $W/site/index.html $W/backup-pagina/index.html.bak-$TS
SW=$(sudo sha256sum $W/site/files/suporte.exe | cut -d' ' -f1)
SL=$(sudo sha256sum $W/site/files/opc-remoto-linux.deb | cut -d' ' -f1)
sed -e "s/__SHA__/$SW/" -e "s/__SHA_LINUX__/$SL/" $T > /tmp/index.new && sudo sh -c "cat /tmp/index.new > $W/site/index.html"
sudo bash $W/gerar-pagina-noc.sh   # sempre depois do index.html
```

## Cuidados
- O `<script>` da página é liberado na CSP pelo hash (`script-src 'sha256-…'` no
  `nginx.conf`). Mudou o script: recalcular o hash e atualizar o nginx.
- A página da rede do NOC (`index-noc.html`) e `/tecnico/` só são servidas para
  187.86.63.2 (`geo $rede_noc`); para o resto respondem 404.
- Acesso por IP ou outro nome no HTTPS: `return 444`.
- Testar o nginx antes de recarregar: `docker exec rustdesk-web nginx -t`, depois
  `docker exec rustdesk-web nginx -s reload` (sem reiniciar o container).
