#!/usr/bin/env bash
# ============================================================================
# branding/apply.sh - aplica a marca "Suporte OPC" (Opção Telecom) ao código
# do RustDesk antes do build. Rodar na raiz do repositório, depois do checkout
# com submódulos. Cada troca é conferida: se o código mudar (outra versão),
# o script falha em vez de gerar um build pela metade.
#
#   - nome do app (APP_NAME) -> SuporteOPC  (config própria em %APPDATA%\SuporteOPC)
#   - telas de Rede/Servidor/Proxy/WebSocket ocultas, cartões de ajuda ocultos
#   - ícones (exe, janela, bandeja), logo da tela inicial, tela de extração
#   - cor de destaque azul Opção, metadados do exe (nome/descrição)
#
# Requer: python3 com Pillow (instalado aqui via pip se faltar).
# ============================================================================
set -euo pipefail

APP_NAME="SuporteOPC"
PRODUCT="Suporte OPC"
DESCRIPTION="Suporte OPC - Acesso Remoto (Opcao Telecom)"
ACCENT="0A46A6"          # azul Opção para botões/destaques (logo #003482, mais claro p/ tema escuro)
SPLASH_BG="0, 19, 75"    # #00134B (marinho do site)
LOGO_SHA256="855e6b16d7b90e646b8d6ab012d5aeae93311e4ae0760cc13cb4d528905f1ce6"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
die() { echo "::error::branding: $*"; exit 1; }

# substitui exatamente 1 ocorrência (linha inteira, texto fixo) e confere
replace_line() {  # arquivo  linha_antiga  linha_nova   (aceita LF ou CRLF)
  local f="$1"
  OLD="$2" NEW="$3" python3 - "$f" <<'PY' || die "troca falhou em $f: $2"
import os, sys
p = sys.argv[1]
old, new = os.environ["OLD"], os.environ["NEW"]
lines = open(p, encoding="utf-8", newline="").read().split("\n")
hits = [i for i, l in enumerate(lines) if l.rstrip("\r") == old]
if len(hits) != 1:
    sys.exit(f"esperava 1 linha, achei {len(hits)}")
i = hits[0]
lines[i] = new + ("\r" if lines[i].endswith("\r") else "")
open(p, "w", encoding="utf-8", newline="").write("\n".join(lines))
check = open(p, encoding="utf-8").read().splitlines()
if new not in check:
    sys.exit("troca não conferiu")
PY
  echo "  ok  $f"
}

echo "== 1/5 nome do app e telas ocultas (hbb_common)"
F=libs/hbb_common/src/config.rs
replace_line "$F" \
  '    pub static ref APP_NAME: RwLock<String> = RwLock::new("RustDesk".to_owned());' \
  "    pub static ref APP_NAME: RwLock<String> = RwLock::new(\"${APP_NAME}\".to_owned());"
replace_line "$F" \
  '    pub static ref BUILTIN_SETTINGS: RwLock<HashMap<String, String>> = Default::default();' \
  '    pub static ref BUILTIN_SETTINGS: RwLock<HashMap<String, String>> = RwLock::new([("hide-network-settings", "Y"), ("hide-server-settings", "Y"), ("hide-proxy-settings", "Y"), ("hide-websocket-settings", "Y"), ("hide-help-cards", "Y")].iter().map(|(k, v)| (k.to_string(), v.to_string())).collect());'

echo "== 2/5 metadados do executável"
F=flutter/windows/runner/Runner.rc
replace_line "$F" '            VALUE "FileDescription", "RustDesk Remote Desktop" "\0"' \
                  "            VALUE \"FileDescription\", \"${DESCRIPTION}\" \"\\0\""
replace_line "$F" '            VALUE "ProductName", "RustDesk" "\0"' \
                  "            VALUE \"ProductName\", \"${PRODUCT}\" \"\\0\""
for F in Cargo.toml libs/portable/Cargo.toml; do
  replace_line "$F" 'ProductName = "RustDesk"' "ProductName = \"${PRODUCT}\""
  replace_line "$F" 'FileDescription = "RustDesk Remote Desktop"' "FileDescription = \"${DESCRIPTION}\""
done

echo "== 3/5 cores"
F=flutter/lib/common.dart
replace_line "$F" '  static const Color accent = Color(0xFF0071FF);'   "  static const Color accent = Color(0xFF${ACCENT});"
replace_line "$F" '  static const Color accent50 = Color(0x770071FF);' "  static const Color accent50 = Color(0x77${ACCENT});"
replace_line "$F" '  static const Color accent80 = Color(0xAA0071FF);' "  static const Color accent80 = Color(0xAA${ACCENT});"
replace_line "$F" '  static const Color button = Color(0xFF2C8CFF);'   "  static const Color button = Color(0xFF${ACCENT});"
replace_line libs/portable/src/ui.rs 'const BG_COLOR: [u8; 3] = [90, 90, 120];' "const BG_COLOR: [u8; 3] = [${SPLASH_BG}];"

echo "== 4/5 ícones e logos"
WORK="$(mktemp -d)"
python3 -m pip install -q pillow >/dev/null 2>&1 || python3 -m pip install -q --user pillow
python3 - "$HERE/logo-opcao-telecom.png.b64" "$WORK/marca/logo-opcao-telecom.png" <<'PY'
import base64, os, sys
os.makedirs(os.path.dirname(sys.argv[2]), exist_ok=True)
open(sys.argv[2], "wb").write(base64.b64decode(open(sys.argv[1]).read()))
PY
GOT="$(sha256sum "$WORK/marca/logo-opcao-telecom.png" | cut -d' ' -f1)"
[[ "$GOT" == "$LOGO_SHA256" ]] || die "logo com SHA-256 inesperado ($GOT)"
python3 "$HERE/gen_brand.py" "$WORK/marca" "$WORK/out"
O="$WORK/out"
cp -f "$O/icon.ico"       res/icon.ico
cp -f "$O/tray-icon.ico"  res/tray-icon.ico
cp -f "$O/32x32.png"      res/32x32.png
cp -f "$O/64x64.png"      res/64x64.png
cp -f "$O/128x128.png"    res/128x128.png
cp -f "$O/256x256.png"    res/128x128@2x.png
cp -f "$O/icon-1024.png"  res/icon.png
cp -f "$O/app_icon.ico"   flutter/windows/runner/resources/app_icon.ico
cp -f "$O/icon.png"       flutter/assets/icon.png
cp -f "$O/logo.png"       flutter/assets/logo.png
cp -f "$O/logo_light.png" flutter/assets/logo_light.png
cp -f "$O/logo_dark.png"  flutter/assets/logo_dark.png
cp -f "$O/label.png"      libs/portable/src/res/label.png
rm -rf "$WORK"

echo "== 5/5 conferência"
grep -q "RwLock::new(\"${APP_NAME}\"" libs/hbb_common/src/config.rs || die "APP_NAME"
grep -q '"hide-network-settings", "Y"' libs/hbb_common/src/config.rs || die "BUILTIN_SETTINGS"
for f in res/icon.ico flutter/windows/runner/resources/app_icon.ico flutter/assets/logo.png libs/portable/src/res/label.png; do
  [[ -s "$f" ]] || die "arquivo vazio: $f"
done
echo "marca ${PRODUCT} aplicada (app ${APP_NAME})"
