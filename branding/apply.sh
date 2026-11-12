#!/usr/bin/env bash
# ============================================================================
# branding/apply.sh - aplica a marca da Opção Telecom ao código antes do build.
# Nome, URLs e nome do executável vêm de branding/app.env.
# Rodar na raiz do repositório, depois do checkout com submódulos. Cada troca é
# conferida: se o código mudar (outra versão), o script falha em vez de gerar
# um build pela metade.
#
#   - nome do app (APP_NAME): título, barra de tarefas, mensagens traduzidas
#     (o próprio app troca "RustDesk" pelo APP_NAME nas traduções)
#   - telas de Rede/Servidor/Proxy/WebSocket ocultas, cartões de ajuda e
#     "Desenvolvido por" ocultos
#   - tela "Sobre": links para o site da Opção, aviso de licença AGPL-3.0 com
#     link do código-fonte (obrigatório pela licença) e cor da marca
#   - título fixo da aba, legenda de mensagens do Windows
#   - ícones, logo, tela de extração, cor de destaque, metadados do exe
#
#
# Variante (variável VARIANTE, padrão "cliente"):
#   cliente - app público do site: SÓ RECEBE conexões (sem "conectar a outro
#             ID"); quem baixar não consegue usar para acessar outra máquina.
#             Identidade em app.env.
#   tecnico - app interno do NOC: SÓ CONECTA (a máquina do técnico não pode ser
#             acessada) e grava toda sessão automaticamente (pasta Vídeos).
#             Identidade em app-tecnico.env. NÃO publicar no site.
#
# Requer: python3 com Pillow (instalado aqui via pip se faltar).
# ============================================================================
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VARIANTE="${VARIANTE:-cliente}"
case "$VARIANTE" in
  cliente) ENV_FILE="$HERE/app.env";         CONN_TYPE="incoming" ;;
  tecnico) ENV_FILE="$HERE/app-tecnico.env"; CONN_TYPE="outgoing" ;;
  *) echo "::error::branding: VARIANTE inválida: $VARIANTE (use cliente ou tecnico)"; exit 1 ;;
esac
# shellcheck source=/dev/null
source "$ENV_FILE"
echo "variante: $VARIANTE (conn-type=$CONN_TYPE, $(basename "$ENV_FILE"))"
ACCENT="0A46A6"          # azul Opção para botões/destaques
SPLASH_BG="0, 19, 75"    # #00134B (marinho do site)
LOGO_SHA256="855e6b16d7b90e646b8d6ab012d5aeae93311e4ae0760cc13cb4d528905f1ce6"
EXE_STEM="${EXE_NAME%.exe}"

die() { echo "::error::branding: $*"; exit 1; }
[[ "$APP_NAME" =~ ^[A-Za-z0-9]+$ ]] || die "APP_NAME deve ser só letras/números: $APP_NAME"

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
if data.count(new) < n:
    sys.exit("troca não conferiu")
PY
  echo "  ok  $f"
}

echo "== 1/6 nome do app e opções ocultas (hbb_common)"
F=libs/hbb_common/src/config.rs
replace_text "$F" \
  'pub static ref APP_NAME: RwLock<String> = RwLock::new("RustDesk".to_owned());' \
  "pub static ref APP_NAME: RwLock<String> = RwLock::new(\"${APP_NAME}\".to_owned());"
replace_text "$F" \
  'pub static ref BUILTIN_SETTINGS: RwLock<HashMap<String, String>> = Default::default();' \
  'pub static ref BUILTIN_SETTINGS: RwLock<HashMap<String, String>> = RwLock::new([("hide-network-settings", "Y"), ("hide-server-settings", "Y"), ("hide-proxy-settings", "Y"), ("hide-websocket-settings", "Y"), ("hide-help-cards", "Y"), ("hide-powered-by-me", "Y"), ("hide-security-settings", "Y"), ("disable-change-permanent-password", "Y"), ("disable-change-id", "Y")].iter().map(|(k, v)| (k.to_string(), v.to_string())).collect());'
# segurança (o usuário não consegue mudar):
#   - só senha temporária: senha fixa salva é ignorada (sem acesso permanente)
#   - túnel TCP desligado (sem encaminhar portas para a rede do cliente)
#   - sessão ociosa cai em ${IDLE_MIN} min
#   - aceite por senha ou por clique do cliente
#   - terminal remoto, câmera, impressora remota e descoberta na LAN desligados
#   - instalação como serviço bloqueada (só modo portátil)
#   - login/conta desligado (aba Conta, botão Login, catálogo, grupos)
#   - ID não pode ser trocado pelo usuário
#   - tipo de conexão fixo pela variante (cliente só recebe, técnico só conecta)
#   - técnico: gravação automática de toda sessão de saída
IDLE_MIN=15
replace_text "$F" \
  'pub static ref OVERWRITE_SETTINGS: RwLock<HashMap<String, String>> = Default::default();' \
  "pub static ref OVERWRITE_SETTINGS: RwLock<HashMap<String, String>> = RwLock::new([(\"verification-method\", \"use-temporary-password\"), (\"enable-tunnel\", \"N\"), (\"allow-auto-disconnect\", \"Y\"), (\"auto-disconnect-timeout\", \"${IDLE_MIN}\"), (\"approve-mode\", \"password-click\"), (\"enable-terminal\", \"N\"), (\"enable-camera\", \"N\"), (\"enable-remote-printer\", \"N\"), (\"enable-lan-discovery\", \"N\")].iter().map(|(k, v)| (k.to_string(), v.to_string())).collect());"
replace_text "$F" \
  'pub static ref HARD_SETTINGS: RwLock<HashMap<String, String>> = Default::default();' \
  "pub static ref HARD_SETTINGS: RwLock<HashMap<String, String>> = RwLock::new([(\"disable-installation\", \"Y\"), (\"disable-account\", \"Y\"), (\"conn-type\", \"${CONN_TYPE}\")].iter().map(|(k, v)| (k.to_string(), v.to_string())).collect());"
if [[ "$VARIANTE" == "tecnico" ]]; then
  replace_text "$F" \
    'pub static ref OVERWRITE_LOCAL_SETTINGS: RwLock<HashMap<String, String>> = Default::default();' \
    'pub static ref OVERWRITE_LOCAL_SETTINGS: RwLock<HashMap<String, String>> = RwLock::new([("allow-auto-record-outgoing", "Y")].iter().map(|(k, v)| (k.to_string(), v.to_string())).collect());'
fi

echo "== 2/6 textos fixos na interface"
F=flutter/lib/desktop/pages/desktop_setting_page.dart
replace_text "$F" "launchUrlString('https://rustdesk.com/privacy.html');" "launchUrlString('${SITE_URL}');"
replace_text "$F" "launchUrlString('https://rustdesk.com');" "launchUrlString('${SITE_URL}');"
replace_text "$F" \
  "'Copyright © \${DateTime.now().toString().substring(0, 4)} Purslane Tech Pte. Ltd.\\n\$license'," \
  "'${PRODUCT} · ${COMPANY}\\nSoftware livre sob licença GNU AGPL-3.0, sem garantia.\\nCopyright © Purslane Tech Pte. Ltd. e colaboradores.\\nCódigo-fonte: ${SOURCE_URL}\\n\$license',"
replace_text "$F" "decoration: const BoxDecoration(color: Color(0xFF2c8cff))," "decoration: const BoxDecoration(color: Color(0xFF00134B)),"
replace_text flutter/lib/desktop/widgets/tabbar_widget.dart '"RustDesk",' "\"${PRODUCT}\","
replace_text src/platform/windows.rs 'let caption = "RustDesk Output"' "let caption = \"${PRODUCT}\""

echo "== 3/6 metadados do executável"
F=flutter/windows/runner/Runner.rc
replace_text "$F" 'VALUE "CompanyName", "Purslane Tech Pte. Ltd." "\0"' "VALUE \"CompanyName\", \"${COMPANY}\" \"\\0\""
replace_text "$F" 'VALUE "FileDescription", "RustDesk Remote Desktop" "\0"' "VALUE \"FileDescription\", \"${DESCRIPTION}\" \"\\0\""
replace_text "$F" 'VALUE "InternalName", "rustdesk" "\0"' "VALUE \"InternalName\", \"${EXE_STEM}\" \"\\0\""
replace_text "$F" 'VALUE "OriginalFilename", "rustdesk.exe" "\0"' "VALUE \"OriginalFilename\", \"${EXE_NAME}\" \"\\0\""
replace_text "$F" 'VALUE "ProductName", "RustDesk" "\0"' "VALUE \"ProductName\", \"${PRODUCT}\" \"\\0\""
for F in Cargo.toml libs/portable/Cargo.toml; do
  replace_text "$F" 'ProductName = "RustDesk"' "ProductName = \"${PRODUCT}\""
  replace_text "$F" 'FileDescription = "RustDesk Remote Desktop"' "FileDescription = \"${DESCRIPTION}\""
  replace_text "$F" 'OriginalFilename = "rustdesk.exe"' "OriginalFilename = \"${EXE_NAME}\""
done
replace_text libs/portable/Cargo.toml 'description = "RustDesk Remote Desktop"' "description = \"${DESCRIPTION}\""

echo "== 4/6 cores"
F=flutter/lib/common.dart
replace_text "$F" '  static const Color accent = Color(0xFF0071FF);'   "  static const Color accent = Color(0xFF${ACCENT});"
replace_text "$F" '  static const Color accent50 = Color(0x770071FF);' "  static const Color accent50 = Color(0x77${ACCENT});"
replace_text "$F" '  static const Color accent80 = Color(0xAA0071FF);' "  static const Color accent80 = Color(0xAA${ACCENT});"
replace_text "$F" '  static const Color button = Color(0xFF2C8CFF);'   "  static const Color button = Color(0xFF${ACCENT});"
replace_text libs/portable/src/ui.rs 'const BG_COLOR: [u8; 3] = [90, 90, 120];' "const BG_COLOR: [u8; 3] = [${SPLASH_BG}];"

echo "== 5/6 ícones e logos"
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

echo "== 6/6 conferência"
grep -q "RwLock::new(\"${APP_NAME}\"" libs/hbb_common/src/config.rs || die "APP_NAME"
grep -q '"hide-security-settings", "Y"' libs/hbb_common/src/config.rs || die "BUILTIN_SETTINGS"
grep -q '"verification-method", "use-temporary-password"' libs/hbb_common/src/config.rs || die "OVERWRITE_SETTINGS"
grep -q '"disable-installation", "Y"' libs/hbb_common/src/config.rs || die "HARD_SETTINGS"
grep -q '"disable-account", "Y"' libs/hbb_common/src/config.rs || die "HARD_SETTINGS (login)"
grep -q '"enable-terminal", "N"' libs/hbb_common/src/config.rs || die "OVERWRITE_SETTINGS (terminal)"
grep -q "\"conn-type\", \"${CONN_TYPE}\"" libs/hbb_common/src/config.rs || die "HARD_SETTINGS (conn-type)"
if [[ "$VARIANTE" == "tecnico" ]]; then
  grep -q '"allow-auto-record-outgoing", "Y"' libs/hbb_common/src/config.rs || die "OVERWRITE_LOCAL_SETTINGS (gravação)"
fi
! grep -q "rustdesk.com" flutter/lib/desktop/pages/desktop_setting_page.dart || die "link rustdesk.com restante na tela Sobre"
for f in res/icon.ico flutter/windows/runner/resources/app_icon.ico flutter/assets/logo.png libs/portable/src/res/label.png; do
  [[ -s "$f" ]] || die "arquivo vazio: $f"
done
echo "marca ${PRODUCT} aplicada (variante ${VARIANTE}, app ${APP_NAME}, exe ${EXE_NAME})"
