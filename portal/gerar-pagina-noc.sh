#!/usr/bin/env bash
# ============================================================================
# gerar-pagina-noc.sh - gera site/index-noc.html a partir do site/index.html
# publicado, inserindo o quadro "Área técnica" logo abaixo do quadro do cliente.
# O nginx entrega index-noc.html só para a rede do provedor (geo $rede_noc).
#
# Rodar SEMPRE depois de publicar uma página nova (index.html), senão a rede
# do NOC continua vendo a página antiga:
#   sudo bash /opt/rustdesk-web/gerar-pagina-noc.sh
# O <script> da página não muda, então o hash do CSP continua valendo.
# ============================================================================
set -euo pipefail
W=/opt/rustdesk-web
SRC="$W/site/index.html"
QUADRO="$W/quadro-tecnico.html"
DST="$W/site/index-noc.html"

python3 - "$SRC" "$QUADRO" "$DST.tmp" <<'PY'
import sys
src, quadro, dst = sys.argv[1:4]
html = open(src, encoding="utf-8").read()
bloco = open(quadro, encoding="utf-8").read()
ancora = '\n  <h2 class="title">Como funciona</h2>'
if html.count(ancora) != 1:
    sys.exit(f"âncora encontrada {html.count(ancora)}x (esperado 1): página mudou?")
open(dst, "w", encoding="utf-8").write(html.replace(ancora, bloco + ancora))
PY

# o <script> tem que ser idêntico ao da página pública (CSP por hash)
s1="$(sed -n '/<script>/,/<\/script>/p' "$SRC" | sha256sum)"
s2="$(sed -n '/<script>/,/<\/script>/p' "$DST.tmp" | sha256sum)"
[[ "$s1" == "$s2" ]] || { echo "ERRO: script diferente da página pública"; rm -f "$DST.tmp"; exit 1; }
grep -q 'Área técnica' "$DST.tmp" || { echo "ERRO: quadro não inserido"; rm -f "$DST.tmp"; exit 1; }

install -m 644 -o root -g root "$DST.tmp" "$DST"
rm -f "$DST.tmp"
echo "ok: $DST ($(wc -c < "$DST") bytes)"
