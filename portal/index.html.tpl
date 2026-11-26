<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex">
<title>Suporte Remoto · Opção Telecom</title>
<meta name="description" content="Baixe o programa de suporte, abra e diga ao técnico o número e a senha que aparecem na tela.">
<link rel="icon" type="image/png" href="/img/icone-64.png">
<style>
/* Lato servida pelo próprio portal (o IP do visitante não vai para o Google) */
@font-face{font-family:Lato;font-style:normal;font-weight:400;font-display:swap;src:url(/fonts/lato-400.woff2) format("woff2")}
@font-face{font-family:Lato;font-style:normal;font-weight:700;font-display:swap;src:url(/fonts/lato-700.woff2) format("woff2")}
@font-face{font-family:Lato;font-style:normal;font-weight:900;font-display:swap;src:url(/fonts/lato-900.woff2) format("woff2")}
/* Opção Telecom: marinho #00134B, azul #003482, vermelho #E21E23 */
:root{
  --navy:#00134B; --blue:#003482; --blue-2:#0a4fc4; --red:#E21E23;
  --bg:#f3f6fb; --surface:#ffffff; --surface-2:#f6f8fc; --ink:#0b1533; --muted:#4a5571; --line:#d9e1ee;
  --accent:#003482; --accent-hover:#00134B; --focus:#E21E23;
  --win:#0067c0; --win-ink:#ffffff;
  --shadow:0 1px 2px rgba(0,19,75,.06),0 16px 36px -14px rgba(0,19,75,.25);
  color-scheme:light;
}
@media (prefers-color-scheme:dark){
  :root{
    --bg:#060c1e; --surface:#0d1733; --surface-2:#0a1229; --ink:#eef2fb; --muted:#b3bdd3; --line:#22305a;
    --accent:#3d7bf0; --accent-hover:#5a90f5; --focus:#ff6b6f;
    --shadow:0 1px 2px rgba(0,0,0,.4),0 16px 36px -14px rgba(0,0,0,.7);
    color-scheme:dark;
  }
}
*{box-sizing:border-box}
html{-webkit-text-size-adjust:100%}
body{margin:0;background:var(--bg);color:var(--ink);font:18px/1.6 Lato,"Segoe UI",system-ui,-apple-system,Roboto,Arial,sans-serif}
a{color:var(--accent)}
a:focus-visible,summary:focus-visible{outline:3px solid var(--focus);outline-offset:3px;border-radius:8px}
.wrap{max-width:880px;margin:0 auto;padding:0 20px}
svg{flex:none}

/* topo azul */
.band{color:#fff;background:linear-gradient(160deg,#000d36 0%,var(--navy) 50%,#00296f 100%);padding-bottom:96px;position:relative}
.band::after{content:"";position:absolute;left:0;right:0;top:0;height:5px;background:linear-gradient(90deg,var(--red) 0 25%,var(--blue-2) 25% 100%)}
.top .wrap{display:flex;align-items:center;gap:14px;height:84px}
.top img{height:38px;width:auto;display:block}
.top .sep{width:1px;height:30px;background:rgba(255,255,255,.3)}
.top .label{font-weight:700;font-size:17px;color:rgba(255,255,255,.95)}
.hero{padding-top:28px;text-align:center}
.hero h1{margin:0 auto 14px;max-width:700px;font-weight:900;font-size:clamp(32px,5.4vw,50px);line-height:1.12;letter-spacing:-.015em}
.hero p{margin:0 auto;max-width:600px;color:rgba(255,255,255,.88);font-size:20px}

/* cartão principal com o botão */
main.wrap{margin-top:-64px;position:relative}
.card{background:var(--surface);border:1px solid var(--line);border-radius:18px;box-shadow:var(--shadow);padding:26px 28px}
.app{display:flex;align-items:center;gap:20px}
.app img{width:64px;height:64px;border-radius:14px;display:block}
.app .info{flex:1;min-width:0}
.app .name{margin:0;font-size:24px;font-weight:900;line-height:1.2}
.app .by{margin:2px 0 0;color:var(--muted);font-size:16px}
.btn{display:inline-flex;align-items:center;justify-content:center;gap:10px;min-height:54px;padding:12px 30px;border-radius:10px;
  font-size:19px;font-weight:700;text-decoration:none;color:#fff;background:var(--accent);border:1px solid var(--accent);transition:background .15s}
.btn:hover{background:var(--accent-hover)}
.btn:focus-visible{outline:4px solid var(--focus);outline-offset:3px}
.btns{display:flex;flex-direction:column;gap:10px}
.btn.alt{background:transparent;color:var(--accent);border:2px solid var(--accent)}
.btn.alt:hover{background:var(--surface-2)}
.tut{margin:18px 0 0;background:var(--surface-2)}
.tut summary{font-size:17px;padding:14px 18px}
.tut ol{margin:0;padding-left:22px}
.tut li{margin:0 0 12px}
.tut code{display:block;margin:8px 0 0;padding:10px 12px;border-radius:8px;background:var(--surface);border:1px solid var(--line);color:var(--ink);font:15px/1.5 Consolas,ui-monospace,monospace;word-break:break-all;user-select:all}
.tut .nota{margin:4px 0 0;font-size:15px}
.card .sub{margin:18px 0 0;padding-top:16px;border-top:1px solid var(--line);color:var(--muted);font-size:16px;display:flex;flex-wrap:wrap;gap:6px 22px}
.card .sub span{display:inline-flex;align-items:center;gap:7px}
.card .sub svg{color:#15803d}

.notice{display:none;margin:0 0 18px;padding:16px 18px;border:2px solid #f2b8ba;background:#fff3f3;color:#7a1215;border-radius:14px;font-size:18px;text-align:left}
@media (prefers-color-scheme:dark){.notice{background:rgba(226,30,35,.12);border-color:rgba(255,107,111,.5);color:#ffd5d6}}
.notice.show{display:flex;gap:12px;align-items:flex-start}

/* passos */
h2.title{font-size:26px;font-weight:900;letter-spacing:-.01em;margin:48px 0 18px;text-align:center}
.steps{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin:0;padding:0;list-style:none}
.step{background:var(--surface);border:1px solid var(--line);border-radius:18px;padding:24px 20px;box-shadow:var(--shadow);display:flex;flex-direction:column;align-items:center;text-align:center}
.step .n{display:grid;place-items:center;width:52px;height:52px;border-radius:50%;background:var(--red);color:#fff;font-size:26px;font-weight:900;margin-bottom:12px}
.step h3{margin:0 0 6px;font-size:21px;font-weight:900;line-height:1.25}
.step p{margin:0;color:var(--muted);font-size:17px}
.step .extra{margin-top:16px;width:100%}

/* desenho do aviso azul do Windows */
.win{background:var(--win);color:var(--win-ink);border-radius:10px;padding:12px 14px;text-align:left;font-size:14px;line-height:1.4}
.win b{display:block;font-size:15px;margin-bottom:6px}
.win .lnk{text-decoration:underline;font-weight:700}
.win .row{display:flex;justify-content:flex-end;gap:6px;margin-top:10px}
.win .bt{border:1px solid rgba(255,255,255,.8);padding:4px 10px;font-size:13px;border-radius:4px}
.win .bt.hl{background:#fff;color:var(--win);font-weight:900;outline:3px solid var(--red);outline-offset:2px}

/* exemplo da tela do app */
.mock{border:2px solid var(--line);border-radius:14px;background:var(--surface-2);padding:10px 16px;font-size:16px}
.mock .row{display:flex;justify-content:space-between;align-items:center;gap:12px;padding:8px 0}
.mock .row+.row{border-top:1px dashed var(--line)}
.mock span{color:var(--muted);font-weight:700}
.mock strong{font:700 21px/1 Consolas,"Cascadia Mono",ui-monospace,monospace;letter-spacing:.05em}
.small{margin-top:8px;font-size:14px;color:var(--muted)}

/* tranquilidade */
.calm{display:grid;grid-template-columns:repeat(2,1fr);gap:14px;margin:28px 0 0;padding:0;list-style:none}
.calm li{display:flex;gap:12px;align-items:flex-start;padding:16px;border-radius:14px;background:var(--surface);border:1px solid var(--line);font-size:17px}
.calm i{display:grid;place-items:center;width:30px;height:30px;border-radius:50%;background:#e3f4e8;color:#15803d}
@media (prefers-color-scheme:dark){.calm i{background:rgba(74,222,128,.15);color:#4ade80}}

/* alerta contra golpe */
.golpe{display:flex;gap:12px;align-items:flex-start;margin:14px 0 0;padding:16px 18px;border:2px solid #f2b8ba;background:#fff3f3;color:#7a1215;border-radius:14px;font-size:17px}
.golpe svg{margin-top:2px}
@media (prefers-color-scheme:dark){.golpe{background:rgba(226,30,35,.12);border-color:rgba(255,107,111,.5);color:#ffd5d6}}

/* dúvidas */
details{background:var(--surface);border:1px solid var(--line);border-radius:14px;margin-bottom:10px}
summary{cursor:pointer;list-style:none;display:flex;align-items:center;justify-content:space-between;gap:12px;padding:18px 20px;font-weight:700;font-size:18px}
summary::-webkit-details-marker{display:none}
summary::after{content:"";width:10px;height:10px;border-right:3px solid var(--muted);border-bottom:3px solid var(--muted);transform:rotate(45deg);transition:transform .2s;margin-right:4px}
details[open] summary::after{transform:rotate(-135deg)}
details .body{padding:0 20px 18px;color:var(--muted);font-size:17px}
details .body b{color:var(--ink)}

footer{margin:52px 0 0;border-top:1px solid var(--line);padding:22px 0 36px;color:var(--muted);font-size:14px;text-align:center}
footer details{display:inline-block;background:transparent;border:0;margin:6px 0 0}
footer summary{padding:0;font-weight:400;font-size:13px;justify-content:center}
footer summary::after{display:none}
footer .hash{margin-top:6px;font:12px/1.7 Consolas,ui-monospace,monospace;word-break:break-all}

@media (max-width:760px){
  body{font-size:17px}
  .steps,.calm{grid-template-columns:1fr}
  .top .sep,.top .label{display:none}
  .top img{height:32px}
  .hero p{font-size:18px}
  .app{flex-wrap:wrap;gap:14px}
  .app img{width:52px;height:52px}
  .app .name{font-size:21px}
  .btn{width:100%}
  .btns{width:100%}
  .card{padding:22px 18px}
}
@media (prefers-reduced-motion:reduce){*{transition:none!important}}
</style>
</head>
<body>

<div class="band">
  <header class="top">
    <div class="wrap">
      <img src="/img/logo-opcao.png" alt="Opção Telecom" width="154" height="38">
      <span class="sep" aria-hidden="true"></span>
      <span class="label">Suporte Remoto</span>
    </div>
  </header>
  <section class="hero wrap">
    <h1>Vamos resolver pelo seu computador</h1>
    <p>Com a sua permissão, o técnico da Opção vê a sua tela e resolve o problema enquanto você acompanha.</p>
  </section>
</div>

<main class="wrap">

  <div class="card">
    <div class="notice" id="naoWindows" role="note">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 9v4M12 17h.01"/><path d="M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/></svg>
      <div><b>Abra esta página no computador.</b> O atendimento funciona em computadores com Windows ou Linux (Ubuntu e Debian).</div>
    </div>
    <div class="app">
      <img src="/img/icone-64.png" alt="" width="64" height="64">
      <div class="info">
        <p class="name">OPC Remoto Cliente</p>
        <p class="by">Programa de suporte da Opção Telecom</p>
      </div>
      <div class="btns">
        <a class="btn" href="/baixar">Baixar para Windows</a>
        <a class="btn alt" href="/baixar-linux">Baixar para Linux</a>
      </div>
    </div>
    <details class="tut">
      <summary>Usa Linux? Veja como instalar</summary>
      <div class="body">
        <ol>
          <li>Clique em <b>Baixar para Linux</b>. O arquivo <b>opc-remoto.deb</b> vai para a pasta <b>Downloads</b>.</li>
          <li>Dê <b>dois cliques</b> no arquivo, clique em <b>Instalar</b> e digite a senha do computador.<br>
            Se não abrir, use o <b>Terminal</b> (teclas <b>Ctrl + Alt + T</b>), cole o comando abaixo e tecle Enter:
            <code>sudo apt install ./Downloads/opc-remoto.deb</code></li>
          <li>Abra o <b>OPC Remoto</b> pelo menu de aplicativos e diga ao técnico o <b>ID</b> e a <b>Senha</b>. Se aparecer um pedido para compartilhar a tela, clique em <b>Compartilhar</b>.</li>
        </ol>
        <p class="nota">Só é preciso instalar uma vez. Nos próximos atendimentos, basta abrir pelo menu. Para encerrar, feche a janela do programa.</p>
      </div>
    </details>
    <p class="sub">
      <span><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>No Windows, não precisa instalar</span>
      <span><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>Não pede cadastro</span>
      <span><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>Usado só durante o atendimento</span>
    </p>
  </div>

  <h2 class="title">Como funciona</h2>
  <ol class="steps">
    <li class="step">
      <div class="n" aria-hidden="true">1</div>
      <h3>Baixe o programa</h3>
      <p>Clique em <b>Baixar</b>, no quadro acima. O arquivo vai para a pasta <b>Downloads</b>.</p>
    </li>
    <li class="step">
      <div class="n" aria-hidden="true">2</div>
      <h3>Abra o arquivo</h3>
      <p>Dê dois cliques nele. Se aparecer este aviso azul, clique em <b>Mais informações</b> e depois em <b>Executar assim mesmo</b>.</p>
      <div class="extra" aria-hidden="true">
        <div class="win">
          <b>O Windows protegeu o computador</b>
          <span class="lnk">Mais informações</span>
          <div class="row"><span class="bt hl">Executar assim mesmo</span><span class="bt">Não executar</span></div>
        </div>
      </div>
    </li>
    <li class="step">
      <div class="n" aria-hidden="true">3</div>
      <h3>Fale os números ao técnico</h3>
      <p>Diga o <b>ID</b> e a <b>Senha</b> que aparecem na tela do programa.</p>
      <div class="extra">
        <div class="mock" role="img" aria-label="Exemplo: ID 123 456 789 e senha a1b2c3">
          <div class="row"><span>ID</span><strong>123 456 789</strong></div>
          <div class="row"><span>Senha</span><strong>a1b2c3</strong></div>
        </div>
        <div class="small">Só um exemplo. Os seus serão outros.</div>
      </div>
    </li>
  </ol>

  <ul class="calm">
    <li><i aria-hidden="true"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg></i><span>O técnico só entra com a senha que <b>você</b> passar.</span></li>
    <li><i aria-hidden="true"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg></i><span>Você vê na tela tudo o que é feito.</span></li>
    <li><i aria-hidden="true"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg></i><span>Quando o técnico encerra, o programa <b>fecha sozinho</b>. Você também pode fechar quando quiser.</span></li>
    <li><i aria-hidden="true"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg></i><span>O atendimento é <b>gravado</b> para a sua segurança.</span></li>
  </ul>

  <div class="golpe" role="note">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/><path d="M12 9v4"/><path d="M12 17h.01"/></svg>
    <span><b>Cuidado com golpes:</b> a Opção Telecom nunca pede senha de banco, Pix ou código recebido por SMS. Só passe o ID e a senha ao técnico com quem você abriu o atendimento.</span>
  </div>

  <h2 class="title">Precisa de ajuda?</h2>
  <details>
    <summary>Não encontro o arquivo baixado</summary>
    <div class="body">Abra a pasta <b>Downloads</b> do computador e dê dois cliques no arquivo <b>opc-remoto</b>.</div>
  </details>
  <details>
    <summary>O navegador perguntou se quero manter o arquivo</summary>
    <div class="body">Pode escolher <b>Manter</b>. O programa é da Opção Telecom e serve só para o nosso atendimento.</div>
  </details>
  <details>
    <summary>O programa abriu, mas aparece “Não pronto”</summary>
    <div class="body">Confira se a internet está funcionando e espere alguns segundos. Se continuar, feche e abra o programa de novo ou avise o técnico.</div>
  </details>
  <details>
    <summary>Depois do atendimento, preciso fazer algo?</summary>
    <div class="body">Não. Quando o técnico encerra, o programa fecha sozinho, o acesso termina e a senha deixa de valer. Para um novo atendimento, baixe e abra o programa de novo. Se quiser, pode apagar o arquivo da pasta Downloads.</div>
  </details>

</main>

<footer>
  <div class="wrap">
    <div>Opção Telecom &middot; Suporte Remoto</div>
    <details>
      <summary>Informações técnicas</summary>
      <div class="hash">
        SHA-256 Windows: __SHA__<br>
        SHA-256 Linux: __SHA_LINUX__<br>
        OPC Remoto &middot; software livre (GNU AGPL-3.0) &middot; <a href="https://github.com/marcelowopc-gitter/opc-remoto">código-fonte</a>
      </div>
    </details>
  </div>
</footer>

<script>
(function () {
  try {
    var ua = navigator.userAgent || "";
    var mobile = /Android|iPhone|iPad|iPod|Mobile/i.test(ua);
    var windows = /Windows/i.test(ua);
    var linux = /Linux/i.test(ua) && !/Android/i.test(ua);
    if (mobile || !(windows || linux)) document.getElementById("naoWindows").classList.add("show");
  } catch (e) {}
})();
</script>
</body>
</html>
