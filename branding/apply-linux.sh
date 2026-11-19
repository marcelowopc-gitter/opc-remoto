#!/usr/bin/env bash
# ============================================================================
# branding/apply-linux.sh - pacote LINUX (.deb, Ubuntu/Debian) do OPC.
# Usado SÓ pelo workflow "OPC Remoto (Linux x64)". Os apps de Windows não usam
# este arquivo e não mudam com ele.
#
# 1) roda o apply.sh sem alterações (mesmas travas e mesma marca do Windows:
#    whitelist do NOC, sem limite de ociosidade, senha temporária, cliente só
#    recebe, técnico só conecta e grava)
# 2) pacote com o nome do app: opcremoto (cliente) / opctecnico (técnico).
#    Binário, pasta, serviço, atalho e ícone próprios: os dois convivem na mesma
#    máquina e não conflitam com um RustDesk oficial. (O código do RustDesk no
#    Linux já procura serviço/processos pelo nome do app.)
# 3) cliente: acesso SÓ COM O APP ABERTO, como no Windows portátil
#    - o serviço não sobe no boot
#    - abrir o app pelo menu cria /run/<app>/abrir -> <app>.path liga o serviço
#    - <app>-vigia (root) desliga o serviço quando a janela do app fecha
#    - fechar a janela encerra o app (no Linux o padrão era só esconder)
#    - cada abertura sobe o serviço de novo = senha temporária nova (igual r7)
#    técnico: serviço normal do RustDesk (só faz conexões de saída)
#
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
N="$(printf '%s' "$APP_NAME" | tr 'A-Z' 'a-z')"   # opcremoto / opctecnico
[[ "$N" =~ ^[a-z0-9]+$ ]] || die "nome do pacote inválido: $N"
echo "pacote Linux: $N (variante $VARIANTE)"

# troca um trecho de texto fixo; exige exatamente N ocorrências (padrão 1)
replace_text() {  # arquivo  texto_antigo  texto_novo  [quantidade]
  local f="$1"
  OLD="$2" NEW="$3" N_OC="${4:-1}" python3 - "$f" <<'PY' || die "troca falhou em $f: $2"
import os, sys
p = sys.argv[1]
old, new, n = os.environ["OLD"], os.environ["NEW"], int(os.environ["N_OC"])
data = open(p, encoding="utf-8", newline="").read()
got = data.count(old)
if got != n:
    sys.exit(f"esperava {n} ocorrência(s), achei {got}")
data = data.replace(old, new)
open(p, "w", encoding="utf-8", newline="").write(data)
PY
  echo "  ok  $f"
}

# grava arquivo a partir de modelo, trocando @N@ e @PRODUCT@
write_tpl() {  # destino  modo  (conteúdo na entrada padrão)
  mkdir -p "$(dirname "$1")"
  sed -e "s|@N@|${N}|g" -e "s|@PRODUCT@|${PRODUCT}|g" > "$1"
  chmod "$2" "$1"
  echo "  ok  $1"
}

echo "== Linux 1/5 nome do binário, janela e pacote"
replace_text flutter/linux/CMakeLists.txt 'set(BINARY_NAME "rustdesk")' "set(BINARY_NAME \"${N}\")"
replace_text flutter/linux/CMakeLists.txt 'set(APPLICATION_ID "com.carriez.flutter_hbb")' "set(APPLICATION_ID \"br.com.opcaotelecom.${N}\")"
replace_text flutter/linux/my_application.cc 'gtk_header_bar_set_title(header_bar, "rustdesk");' "gtk_header_bar_set_title(header_bar, \"${PRODUCT}\");"
replace_text flutter/linux/my_application.cc 'gtk_window_set_title(window, "rustdesk");' "gtk_window_set_title(window, \"${PRODUCT}\");"
replace_text flutter/linux/my_application.cc 'gtk_icon_theme_load_icon(theme, "rustdesk",' "gtk_icon_theme_load_icon(theme, \"${N}\","
replace_text build.py '    content = """Package: rustdesk' "    content = \"\"\"Package: ${N}"
replace_text build.py 'Homepage: https://rustdesk.com' "Homepage: ${SITE_URL}"
replace_text build.py 'Description: A remote control software.' "Description: ${DESCRIPTION}"
# caminhos do .deb: só dentro de build_flutter_deb (o build usado aqui)
PKG="$N" python3 - build.py <<'PY' || die "troca falhou em build.py (build_flutter_deb)"
import os, sys
p, n = sys.argv[1], os.environ["PKG"]
src = open(p, encoding="utf-8", newline="").read()
ini = src.index("def build_flutter_deb(")
fim = src.index("\ndef ", ini + 1)
fn = src[ini:fim]
trocas = [  # (antigo, novo, quantidade esperada)
    ("tmpdeb/usr/share/rustdesk", f"tmpdeb/usr/share/{n}", 6),
    ("tmpdeb/usr/bin/rustdesk", f"tmpdeb/usr/bin/{n}", 1),
    (f"cp ../res/rustdesk.service tmpdeb/usr/share/{n}/files/systemd/'",
     f"cp ../res/rustdesk.service tmpdeb/usr/share/{n}/files/systemd/{n}.service'", 1),
    ("apps/rustdesk.png", f"apps/{n}.png", 1),
    ("apps/rustdesk.svg", f"apps/{n}.svg", 1),
    ("applications/rustdesk.desktop", f"applications/{n}.desktop", 1),
    ("applications/rustdesk-link.desktop", f"applications/{n}-link.desktop", 1),
    ("    system2('mkdir -p tmpdeb/DEBIAN')\n",
     "    system2('mkdir -p tmpdeb/DEBIAN')\n"
     "    # OPC: arquivos extras do pacote (cliente: acesso só com o app aberto)\n"
     "    if os.path.isdir('../res/opc-linux'):\n"
     "        system2('cp -r ../res/opc-linux/. tmpdeb/')\n", 1),
]
for old, new, q in trocas:
    got = fn.count(old)
    if got != q:
        sys.exit(f"build_flutter_deb: esperava {q}x '{old}', achei {got}")
    fn = fn.replace(old, new)
open(p, "w", encoding="utf-8", newline="").write(src[:ini] + fn + src[fim:])
PY
echo "  ok  build.py (build_flutter_deb -> /usr/share/${N})"

echo "== Linux 2/5 atalho do menu, serviço e scripts do pacote"
if [[ "$VARIANTE" == "cliente" ]]; then
  EXEC="/usr/share/${N}/opc-abrir.sh"
else
  EXEC="${N}"
fi
write_tpl res/rustdesk.desktop 644 <<EOF
[Desktop Entry]
Name=@PRODUCT@
GenericName=Acesso Remoto
Comment=${DESCRIPTION}
Exec=${EXEC} %u
Icon=@N@
Terminal=false
Type=Application
StartupNotify=true
Categories=Network;RemoteAccess;GTK;
StartupWMClass=@N@
EOF
write_tpl res/rustdesk-link.desktop 644 <<EOF
[Desktop Entry]
Name=@PRODUCT@
NoDisplay=true
MimeType=x-scheme-handler/@N@;
TryExec=@N@
Exec=${EXEC} %u
Icon=@N@
Terminal=false
Type=Application
StartupNotify=false
StartupWMClass=@N@
EOF

if [[ "$VARIANTE" == "cliente" ]]; then
  # sem [Install]: nem o próprio app consegue deixar o serviço ligado no boot
  write_tpl res/rustdesk.service 644 <<'EOF'
[Unit]
Description=@PRODUCT@
Requires=network.target
After=systemd-user-sessions.service
# OPC: só roda enquanto o app estiver aberto (o vigia sai quando o app fecha)
BindsTo=@N@-vigia.service
After=@N@-vigia.service

[Service]
Type=simple
ExecStart=/usr/bin/@N@ --service
ExecStop=pkill -f "@N@ --"
PIDFile=/run/@N@.pid
KillMode=mixed
TimeoutStopSec=30
User=root
LimitNOFILE=100000
Environment="PULSE_LATENCY_MSEC=60" "PIPEWIRE_LATENCY=1024/48000"
EOF
  ATIVAR='		# OPC: acesso só com o app aberto. O serviço NÃO sobe no boot: quem liga
		# é o @N@.path quando o app abre, e o @N@-vigia desliga quando fecha.
		systemd-tmpfiles --create /usr/lib/tmpfiles.d/@N@.conf || true
		systemctl stop @N@ >/dev/null 2>&1 || true
		systemctl enable @N@.path
		systemctl start @N@.path'
else
  write_tpl res/rustdesk.service 644 <<'EOF'
[Unit]
Description=@PRODUCT@
Requires=network.target
After=systemd-user-sessions.service

[Service]
Type=simple
ExecStart=/usr/bin/@N@ --service
ExecStop=pkill -f "@N@ --"
PIDFile=/run/@N@.pid
KillMode=mixed
TimeoutStopSec=30
User=root
LimitNOFILE=100000
Environment="PULSE_LATENCY_MSEC=60" "PIPEWIRE_LATENCY=1024/48000"

[Install]
WantedBy=multi-user.target
EOF
  ATIVAR='		systemctl enable @N@
		systemctl start @N@'
fi

write_tpl res/DEBIAN/postinst 755 <<EOF
#!/bin/bash

set -e

if [ "\$1" = configure ]; then

	INITSYS=\$(ls -al /proc/1/exe | awk -F' ' '{print \$NF}' | awk -F'/' '{print \$NF}')
	ln -f -s /usr/share/@N@/@N@ /usr/bin/@N@

	if [ "systemd" == "\$INITSYS" ]; then
		rm -f /etc/systemd/system/@N@.service >/dev/null 2>&1 || true
		mkdir -p /usr/lib/systemd/system/
		cp /usr/share/@N@/files/systemd/@N@.service /usr/lib/systemd/system/@N@.service
		# Ubuntu 18.04: ExecStop precisa de caminho absoluto
		if [ -e /usr/bin/pkill ]; then
			sed -i "s|pkill|/usr/bin/pkill|g" /usr/lib/systemd/system/@N@.service
		fi
		systemctl daemon-reload
${ATIVAR}
	fi
fi
EOF
# o preinst original parava o serviço "rustdesk": aqui só o do próprio app
write_tpl res/DEBIAN/preinst 755 <<'EOF'
#!/bin/bash

set -e

case $1 in
    install|upgrade)
		INITSYS=$(ls -al /proc/1/exe | awk -F' ' '{print $NF}' | awk -F'/' '{print $NF}')
		if [ "systemd" == "${INITSYS}" ]; then
			systemctl stop @N@ >/dev/null 2>&1 || true
			sleep 1
		fi
        ;;
esac

exit 0
EOF
write_tpl res/DEBIAN/prerm 755 <<'EOF'
#!/bin/bash

set -e

case $1 in
    remove|upgrade)
		INITSYS=$(ls -al /proc/1/exe | awk -F' ' '{print $NF}' | awk -F'/' '{print $NF}')
		rm -f /usr/bin/@N@

		if [ "systemd" == "${INITSYS}" ]; then
			systemctl stop @N@.path >/dev/null 2>&1 || true
			systemctl disable @N@.path >/dev/null 2>&1 || true
			systemctl stop @N@ || true
			systemctl disable @N@ >/dev/null 2>&1 || true
			rm -f /etc/systemd/system/@N@.service /usr/lib/systemd/system/@N@.service || true
		fi
        ;;
esac

exit 0
EOF
write_tpl res/DEBIAN/postrm 755 <<'EOF'
#!/bin/bash

set -e

case $1 in
    purge)
		rm -rf /root/.config/@N@ || true
        ;;
esac

if [ -d /run/systemd/system ]; then
	systemctl daemon-reload >/dev/null 2>&1 || true
fi

exit 0
EOF

echo "== Linux 3/5 cliente: acesso só com o app aberto"
if [[ "$VARIANTE" == "cliente" ]]; then
  X=res/opc-linux
  write_tpl "$X/usr/share/$N/opc-abrir.sh" 755 <<'EOF'
#!/bin/sh
# @PRODUCT@: liga o acesso (o @N@.path sobe o serviço) e abre o app.
# O acesso desliga sozinho quando o app fecha (@N@-vigia).
: > /run/@N@/abrir 2>/dev/null || true
exec /usr/share/@N@/@N@ "$@"
EOF
  write_tpl "$X/usr/share/$N/files/opc-vigia.sh" 755 <<'EOF'
#!/bin/sh
# @PRODUCT@: mantém o acesso ligado só enquanto a janela do app estiver aberta.
# Roda como root (@N@-vigia.service). Quando este script termina, o systemd
# desliga o @N@.service (BindsTo) e qualquer sessão em andamento cai.
APP=/usr/share/@N@/@N@
app_aberto() {
	for d in /proc/[0-9]*; do
		[ "$(readlink "$d/exe" 2>/dev/null)" = "$APP" ] || continue
		a1=$(tr '\0' '\n' < "$d/cmdline" 2>/dev/null | sed -n 2p)
		case "$a1" in --*) continue ;; esac   # --server, --tray, --cm...
		return 0
	done
	return 1
}
# espera a janela subir (até 30 s) e consome o aviso de abertura
i=0
while ! app_aberto && [ "$i" -lt 30 ]; do sleep 1; i=$((i + 1)); done
rm -f /run/@N@/abrir
while app_aberto; do sleep 3; done
exit 0
EOF
  write_tpl "$X/usr/lib/systemd/system/$N-vigia.service" 644 <<'EOF'
[Unit]
Description=@PRODUCT@ - acesso só com o app aberto

[Service]
Type=simple
ExecStart=/usr/share/@N@/files/opc-vigia.sh
EOF
  write_tpl "$X/usr/lib/systemd/system/$N.path" 644 <<'EOF'
[Unit]
Description=@PRODUCT@ - liga o acesso quando o app abre

[Path]
PathExists=/run/@N@/abrir
Unit=@N@.service

[Install]
WantedBy=multi-user.target
EOF
  write_tpl "$X/usr/lib/tmpfiles.d/$N.conf" 644 <<'EOF'
# pasta onde o app avisa que abriu (qualquer usuário local pode criar o aviso;
# o vigia só mantém o serviço se a janela do app estiver realmente aberta)
d /run/@N@ 1777 root root -
EOF
  # fechar a janela encerra o app (no Linux o padrão era esconder e seguir rodando)
  F=flutter/lib/desktop/widgets/tabbar_widget.dart
  replace_text "$F" "import 'dart:async';" "import 'dart:async';
import 'dart:io' show exit;"
  replace_text "$F" "    mainWindowClose() async => await windowManager.hide();" \
"    mainWindowClose() async {
      // OPC (cliente Linux): fechar encerra o app e o acesso remoto
      if (isLinux) exit(0);
      await windowManager.hide();
    }"
else
  echo "  técnico: serviço normal (só conexões de saída)"
fi

echo "== Linux 4/5 ícone do menu (.svg)"
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

echo "== Linux 5/5 conferência"
grep -qF "set(BINARY_NAME \"${N}\")" flutter/linux/CMakeLists.txt || die "nome do binário"
grep -qF "Package: ${N}" build.py || die "nome do pacote"
grep -qF "tmpdeb/usr/share/${N}/files/systemd/${N}.service" build.py || die "serviço no pacote"
! sed -n '/^def build_flutter_deb(/,/^def /p' build.py | grep -q 'usr/share/rustdesk\|usr/bin/rustdesk' || die "caminho rustdesk restante no .deb"
grep -qxF "Name=${PRODUCT}" res/rustdesk.desktop || die "atalho (.desktop)"
grep -qxF "ExecStart=/usr/bin/${N} --service" res/rustdesk.service || die "serviço"
! grep -q '@N@\|@PRODUCT@' res/rustdesk.desktop res/rustdesk-link.desktop res/rustdesk.service res/DEBIAN/preinst res/DEBIAN/postinst res/DEBIAN/prerm res/DEBIAN/postrm || die "modelo sem troca"
! grep -qw 'rustdesk' res/DEBIAN/preinst res/DEBIAN/postinst res/DEBIAN/prerm res/DEBIAN/postrm || die "script do pacote ainda cita rustdesk"
for s in preinst postinst prerm postrm; do bash -n "res/DEBIAN/$s" || die "res/DEBIAN/$s com erro de sintaxe"; done
if [[ "$VARIANTE" == "cliente" ]]; then
  ! grep -q '^\[Install\]' res/rustdesk.service || die "cliente: serviço não pode subir no boot"
  grep -qxF "BindsTo=${N}-vigia.service" res/rustdesk.service || die "cliente: vigia"
  grep -qF "systemctl enable ${N}.path" res/DEBIAN/postinst || die "cliente: gatilho de abertura"
  sh -n "res/opc-linux/usr/share/${N}/opc-abrir.sh" && sh -n "res/opc-linux/usr/share/${N}/files/opc-vigia.sh" || die "cliente: script com erro de sintaxe"
  grep -qF "if (isLinux) exit(0);" flutter/lib/desktop/widgets/tabbar_widget.dart || die "cliente: fechar encerra o app"
else
  grep -qF "systemctl enable ${N}" res/DEBIAN/postinst || die "técnico: serviço"
fi
grep -q 'data:image/png;base64,' res/scalable.svg || die "ícone (.svg)"
echo "pacote Linux ${N} (${PRODUCT}) pronto para o build"
