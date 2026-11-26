#!/usr/bin/env bash
# ============================================================================
# branding/apply-macos.sh - app de macOS (.dmg) do OPC Remoto (só o CLIENTE).
# Usado SÓ pelo workflow "OPC Remoto (macOS)". Windows e Linux não usam este
# arquivo e não mudam com ele.
#
# 1) roda o apply.sh sem alterações (mesmas travas e mesma marca: whitelist do
#    NOC, sem limite de ociosidade, senha temporária, só recebe, fim do
#    atendimento fecha o app)
# 2) ajusta o que é do Mac: nome no menu/Finder, identificador próprio do app
#    (br.com.opcaotelecom.opcremoto: não mistura permissões com um RustDesk
#    oficial na mesma máquina), copyright e ícone .icns.
#    O pacote continua sendo gerado como RustDesk.app (o build.py depende desse
#    nome); o workflow renomeia para "OPC Remoto.app" no fim. Com esse nome o
#    app nunca se considera "instalado" (o código procura /Applications/OPCRemoto.app),
#    então roda sempre como o portátil do Windows: só com o app aberto.
#
# Precisa rodar no macOS (sips/iconutil) com python3 + Pillow e GNU coreutils.
# ============================================================================
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VARIANTE="${VARIANTE:-cliente}"
export VARIANTE
die() { echo "::error::branding-macos: $*"; exit 1; }
[[ "$VARIANTE" == "cliente" ]] || die "no macOS só existe o app do cliente (VARIANTE=$VARIANTE)"

bash "$HERE/apply.sh"

# shellcheck source=/dev/null
source "$HERE/app.env"
BUNDLE_ID="br.com.opcaotelecom.$(printf '%s' "$APP_NAME" | tr '[:upper:]' '[:lower:]')"

# troca por expressão regular; exige exatamente N ocorrências
replace_re() {  # arquivo  regex  substituição  quantidade
  local f="$1"
  PAT="$2" REP="$3" N="$4" python3 - "$f" <<'PY' || die "troca falhou em $f: $2"
import os, re, sys
p = sys.argv[1]
data = open(p, encoding="utf-8", newline="").read()
data, n = re.subn(os.environ["PAT"], lambda m: m.expand(os.environ["REP"]), data)
if n != int(os.environ["N"]):
    sys.exit(f"esperava {os.environ['N']} ocorrência(s), achei {n}")
open(p, "w", encoding="utf-8", newline="").write(data)
PY
  echo "  ok  $f"
}

echo "== mac 1/3 nome, identificador e copyright"
replace_re flutter/macos/Runner/Info.plist \
  '<key>CFBundleName</key>(\s*)<string>\$\(PRODUCT_NAME\)</string>' \
  "<key>CFBundleName</key>\\1<string>${PRODUCT}</string>\\1<key>CFBundleDisplayName</key>\\1<string>${PRODUCT}</string>" 1
replace_re flutter/macos/Runner.xcodeproj/project.pbxproj \
  'PRODUCT_BUNDLE_IDENTIFIER = com\.carriez\.rustdesk;' \
  "PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID};" 3
replace_re flutter/macos/Runner/Configs/AppInfo.xcconfig \
  'PRODUCT_BUNDLE_IDENTIFIER = com\.carriez\.flutterHbb' \
  "PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID}" 1
replace_re flutter/macos/Runner/Configs/AppInfo.xcconfig \
  'PRODUCT_COPYRIGHT = [^\r\n]*' \
  "PRODUCT_COPYRIGHT = ${PRODUCT} - ${COMPANY}. Software livre (AGPL-3.0); copyright Purslane Tech Pte. Ltd. e colaboradores." 1

echo "== mac 2/3 ícone (.icns a partir do res/icon.png da marca)"
command -v sips >/dev/null && command -v iconutil >/dev/null || die "sips/iconutil não encontrados (rodar no macOS)"
WORK="$(mktemp -d)"
SET="$WORK/AppIcon.iconset"
mkdir -p "$SET"
for s in 16 32 128 256 512; do
  sips -z "$s" "$s" res/icon.png --out "$SET/icon_${s}x${s}.png" >/dev/null
  d=$((s * 2))
  sips -z "$d" "$d" res/icon.png --out "$SET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$SET" -o flutter/macos/Runner/AppIcon.icns
cp -f res/icon.png res/mac-icon.png
rm -rf "$WORK"
echo "  ok  flutter/macos/Runner/AppIcon.icns"

echo "== mac 3/3 conferência"
grep -q "<string>${PRODUCT}</string>" flutter/macos/Runner/Info.plist || die "CFBundleName"
[[ "$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID};" flutter/macos/Runner.xcodeproj/project.pbxproj)" == 3 ]] || die "bundle id"
! grep -q 'com.carriez.rustdesk;' flutter/macos/Runner.xcodeproj/project.pbxproj || die "sobrou bundle id antigo"
[[ "$(head -c 4 flutter/macos/Runner/AppIcon.icns)" == "icns" ]] || die "AppIcon.icns inválido"
grep -q '"allow-auto-disconnect", "N"' libs/hbb_common/src/config.rs || die "travas do apply.sh"
grep -q 'opc_encerrar_se_sem_sessao();' src/server/connection.rs || die "fim do atendimento"
echo "branding macOS ok: ${PRODUCT} (${BUNDLE_ID})"
