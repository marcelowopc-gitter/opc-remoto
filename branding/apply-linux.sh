#!/usr/bin/env bash
# ============================================================================
# branding/apply-linux.sh - marca do pacote LINUX (.deb, Ubuntu/Debian).
# Usado SÓ pelo workflow "OPC Remoto (Linux x64)". Os apps de Windows não usam
# este arquivo e não mudam com ele.
#
# 1) roda o apply.sh sem alterações (mesmas travas e mesma marca do Windows:
#    whitelist do NOC, sem limite de ociosidade, senha temporária, cliente só
#    recebe, técnico só conecta e grava)
# 2) troca o que só existe no pacote Linux: título da janela, atalho do menu,
#    nome do serviço, descrição do pacote e ícone .svg
#
# O pacote e o binário continuam "rustdesk" (caminhos fixos no código e no
# serviço systemd); só o que o usuário vê muda.
# Variante pela variável VARIANTE (cliente/tecnico), igual ao apply.sh.
# ============================================================================
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VARIANTE="${VARIANTE:-cliente}"
export VARIANTE

bash "$HERE/apply.sh"

case "$VARIANTE" in
  cliente) ENV_FILE="$HERE/app.env" ;;
  tecnico) ENV_FILE="$HERE/app-tecnico.env" ;;
  *) echo "::error::branding-linux: VARIANTE inválida: $VARIANTE"; exit 1 ;;
esac
# shellcheck source=/dev/null
source "$ENV_FILE"

die() { echo "::error::branding-linux: $*"; exit 1; }

# troca um trecho de texto fixo; exige exatamente N ocorrências (padrão 1)
replace_text() {  # arquivo  texto_antigo  texto_novo  [quantidade]
  local f="$1"
  OLD="$2" NEW="$3" N="${4:-1}" python3 - "$f" <<'PY' || die "troca falhou em $f: $2"
import os, sys
p = sys.argv[1]
old, new, n = os.environ["OLD"], os.environ["NEW"], int(os.environ["N"])
data = open(p, encoding="utf-8", newline="").read()
got = data.count(old)
if got != n:
    sys.exit(f"esperava {n} ocorrência(s), achei {got}")
data = data.replace(old, new)
open(p, "w", encoding="utf-8", newline="").write(data)
PY
  echo "  ok  $f"
}

echo "== Linux 1/3 janela, menu, serviço e pacote"
replace_text flutter/linux/my_application.cc 'gtk_header_bar_set_title(header_bar, "rustdesk");' "gtk_header_bar_set_title(header_bar, \"${PRODUCT}\");"
replace_text flutter/linux/my_application.cc 'gtk_window_set_title(window, "rustdesk");' "gtk_window_set_title(window, \"${PRODUCT}\");"
replace_text res/rustdesk.desktop 'Name=RustDesk' "Name=${PRODUCT}"
replace_text res/rustdesk.desktop 'Comment=Remote Desktop' "Comment=${DESCRIPTION}"
replace_text res/rustdesk.desktop 'Name=Open a New Window' 'Name=Nova janela'
replace_text res/rustdesk-link.desktop 'Name=RustDesk' "Name=${PRODUCT}"
replace_text res/rustdesk.service 'Description=RustDesk' "Description=${PRODUCT}"
replace_text build.py 'Homepage: https://rustdesk.com' "Homepage: ${SITE_URL}"
replace_text build.py 'Description: A remote control software.' "Description: ${DESCRIPTION}"

echo "== Linux 2/3 ícone do menu (.svg)"
# o menu prefere o .svg ao .png; o svg só embrulha o ícone 256 que o apply.sh
# já gerou da marca (res/128x128@2x.png)
python3 - res/128x128@2x.png res/scalable.svg <<'PY'
import base64, sys
b = base64.b64encode(open(sys.argv[1], "rb").read()).decode()
open(sys.argv[2], "w", encoding="utf-8").write(
    '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
    'width="256" height="256" viewBox="0 0 256 256">'
    f'<image width="256" height="256" xlink:href="data:image/png;base64,{b}"/></svg>\n')
PY
echo "  ok  res/scalable.svg"

echo "== Linux 3/3 conferência"
grep -qxF "Name=${PRODUCT}" res/rustdesk.desktop || die "atalho (.desktop)"
grep -qF "gtk_window_set_title(window, \"${PRODUCT}\");" flutter/linux/my_application.cc || die "título da janela"
grep -qxF "Description=${PRODUCT}" res/rustdesk.service || die "serviço"
grep -qF "Description: ${DESCRIPTION}" build.py || die "descrição do pacote"
grep -q 'data:image/png;base64,' res/scalable.svg || die "ícone (.svg)"
echo "pacote Linux ${PRODUCT} pronto para o build (variante ${VARIANTE})"
