import Vapor

struct AdminWebController: Sendable {
    func index(_ req: Request) -> Response {
        let html = """
        <!doctype html>
        <html lang="es">
          <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>ClosetSocial Admin</title>
            <style>
              :root {
                color-scheme: light;
                --bg: #f3f6fc;
                --surface: rgba(255, 255, 255, 0.94);
                --surface-strong: #ffffff;
                --text: #162033;
                --muted: #63718a;
                --border: #d8e0ee;
                --accent: #2a5cff;
                --accent-soft: rgba(42, 92, 255, 0.12);
                --success: #0f8a5f;
                --danger: #d84a4a;
                --shadow: 0 24px 60px rgba(22, 32, 51, 0.08);
                --radius-xl: 28px;
                --radius-lg: 22px;
                --radius-md: 16px;
              }

              * { box-sizing: border-box; }

              body {
                margin: 0;
                font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Segoe UI", sans-serif;
                color: var(--text);
                background:
                  radial-gradient(circle at top left, rgba(42, 92, 255, 0.16), transparent 28%),
                  radial-gradient(circle at top right, rgba(105, 162, 255, 0.12), transparent 20%),
                  linear-gradient(180deg, #f8fbff 0%, #eef3fb 100%);
              }

              .page {
                width: min(1180px, calc(100vw - 28px));
                margin: 24px auto 48px;
              }

              .hero,
              .panel,
              .metric-card,
              .catalog-card {
                background: var(--surface);
                border: 1px solid var(--border);
                border-radius: var(--radius-xl);
                box-shadow: var(--shadow);
                backdrop-filter: blur(14px);
              }

              .hero {
                padding: 28px;
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                gap: 20px;
                margin-bottom: 18px;
              }

              .eyebrow {
                margin: 0 0 10px;
                text-transform: uppercase;
                letter-spacing: 0.16em;
                font-size: 12px;
                font-weight: 700;
                color: var(--accent);
              }

              h1 {
                margin: 0;
                font-size: clamp(34px, 5vw, 56px);
                line-height: 0.96;
                letter-spacing: -0.05em;
              }

              h2 {
                margin: 0;
                font-size: 24px;
                letter-spacing: -0.03em;
              }

              h3 {
                margin: 0;
                font-size: 20px;
                letter-spacing: -0.02em;
              }

              p {
                margin: 0;
              }

              .hero-copy p:last-child,
              .panel-copy,
              .metric-foot,
              .hint,
              td.muted,
              .empty-state {
                color: var(--muted);
                line-height: 1.6;
              }

              .hero-copy p:last-child {
                margin-top: 14px;
                max-width: 58ch;
              }

              .hero-actions {
                display: flex;
                flex-wrap: wrap;
                gap: 12px;
              }

              button,
              .button-like {
                appearance: none;
                border: 0;
                border-radius: 999px;
                min-height: 44px;
                padding: 0 16px;
                font: inherit;
                font-weight: 700;
                cursor: pointer;
                transition: transform 180ms ease, background 180ms ease, opacity 180ms ease;
              }

              button:hover,
              .button-like:hover {
                transform: translateY(-1px);
              }

              .button-primary {
                color: #fff;
                background: linear-gradient(135deg, var(--accent), #5f82ff);
              }

              .button-secondary {
                color: var(--text);
                background: var(--surface-strong);
                border: 1px solid var(--border);
              }

              .button-danger {
                color: var(--danger);
                background: rgba(216, 74, 74, 0.08);
                border: 1px solid rgba(216, 74, 74, 0.18);
              }

              .panel {
                padding: 24px;
                margin-bottom: 18px;
              }

              .panel-head {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                gap: 16px;
                margin-bottom: 18px;
              }

              .status {
                display: none;
                margin-bottom: 18px;
                padding: 14px 16px;
                border-radius: 18px;
                border: 1px solid var(--border);
                background: var(--surface-strong);
                line-height: 1.5;
              }

              .status.is-visible {
                display: block;
              }

              .status.is-error {
                color: var(--danger);
                border-color: rgba(216, 74, 74, 0.22);
                background: rgba(216, 74, 74, 0.06);
              }

              .status.is-success {
                color: var(--success);
                border-color: rgba(15, 138, 95, 0.22);
                background: rgba(15, 138, 95, 0.07);
              }

              .login-grid,
              .catalog-grid,
              .metrics-grid {
                display: grid;
                gap: 16px;
              }

              .login-grid {
                grid-template-columns: 1.05fr 0.95fr;
              }

              .catalog-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
              }

              .metrics-grid {
                grid-template-columns: repeat(3, minmax(0, 1fr));
              }

              .stack {
                display: grid;
                gap: 14px;
              }

              label {
                display: block;
                margin-bottom: 8px;
                font-size: 14px;
                font-weight: 600;
              }

              input,
              textarea {
                width: 100%;
                border: 1px solid var(--border);
                background: #fff;
                color: var(--text);
                border-radius: 14px;
                padding: 14px 16px;
                font: inherit;
              }

              textarea {
                min-height: 128px;
                resize: vertical;
              }

              .form-row {
                display: grid;
                gap: 14px;
              }

              .login-actions,
              .catalog-form {
                display: flex;
                flex-wrap: wrap;
                gap: 12px;
                align-items: center;
              }

              .catalog-form input {
                flex: 1 1 220px;
              }

              .dashboard-head,
              .catalog-card-head {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                gap: 16px;
                flex-wrap: wrap;
              }

              .badge {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                min-height: 36px;
                padding: 0 14px;
                border-radius: 999px;
                background: var(--accent-soft);
                color: var(--accent);
                font-weight: 700;
              }

              .metric-card,
              .catalog-card {
                padding: 22px;
                border-radius: var(--radius-lg);
              }

              .metric-card-link {
                display: block;
                text-decoration: none;
                color: inherit;
                transition: transform 180ms ease, border-color 180ms ease, box-shadow 180ms ease;
              }

              .metric-card-link:hover {
                transform: translateY(-2px);
                border-color: rgba(42, 92, 255, 0.26);
                box-shadow: 0 28px 60px rgba(22, 32, 51, 0.12);
              }

              .metric-card-link:focus-visible {
                outline: 3px solid rgba(42, 92, 255, 0.24);
                outline-offset: 3px;
              }

              .metric-label {
                margin: 0;
                color: var(--muted);
                text-transform: uppercase;
                letter-spacing: 0.12em;
                font-size: 12px;
                font-weight: 700;
              }

              .metric-value {
                margin: 14px 0 0;
                font-size: clamp(28px, 4vw, 42px);
                line-height: 1;
                letter-spacing: -0.05em;
              }

              .metric-foot {
                margin-top: 10px;
                font-size: 14px;
              }

              .metric-link-copy {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                margin-top: 14px;
                color: var(--accent);
                font-size: 13px;
                font-weight: 700;
              }

              .catalog-copy {
                margin-top: 8px;
                color: var(--muted);
                line-height: 1.6;
              }

              .table-wrap {
                margin-top: 18px;
                overflow-x: auto;
                border: 1px solid var(--border);
                border-radius: 18px;
                background: var(--surface-strong);
              }

              table {
                width: 100%;
                border-collapse: collapse;
              }

              th,
              td {
                padding: 14px 16px;
                text-align: left;
                border-bottom: 1px solid var(--border);
                vertical-align: middle;
                font-size: 14px;
              }

              th {
                color: var(--muted);
                text-transform: uppercase;
                letter-spacing: 0.08em;
                font-size: 12px;
                font-weight: 700;
                background: rgba(42, 92, 255, 0.03);
              }

              tr:last-child td {
                border-bottom: 0;
              }

              .row-actions {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
              }

              .inline-button {
                min-height: 34px;
                padding: 0 12px;
                font-size: 13px;
              }

              .section-title {
                margin-bottom: 18px;
              }

              .hidden {
                display: none;
              }

              @media (max-width: 980px) {
                .login-grid,
                .catalog-grid,
                .metrics-grid {
                  grid-template-columns: 1fr;
                }

                .hero {
                  flex-direction: column;
                }
              }
            </style>
          </head>
          <body>
            <main class="page">
              <section class="hero">
                <div class="hero-copy">
                  <p class="eyebrow">ClosetSocial Admin</p>
                  <h1>Panel interno para operaciones y catalogos.</h1>
                  <p>
                    MVP servido desde Vapor con HTML, CSS y JavaScript vanilla. Permite iniciar
                    sesion como admin, revisar metricas y gestionar datos maestros sin tocar
                    todavia el modelo actual de prendas.
                  </p>
                </div>

                <div class="hero-actions">
                  <button id="refreshButton" class="button-primary hidden" type="button">Recargar panel</button>
                  <button id="logoutButton" class="button-secondary hidden" type="button">Cerrar sesion</button>
                </div>
              </section>

              <div id="statusMessage" class="status" role="status" aria-live="polite"></div>

              <section id="loginPanel" class="panel">
                <div class="panel-head">
                  <div>
                    <p class="eyebrow">Acceso</p>
                    <h2>Entrar como administrador</h2>
                    <p class="panel-copy">
                      El token se guarda en <code>localStorage</code> solo para este MVP de desarrollo.
                    </p>
                  </div>
                </div>

                <div class="login-grid">
                  <div class="stack">
                    <div class="form-row">
                      <div>
                        <label for="emailInput">Email</label>
                        <input id="emailInput" type="email" autocomplete="username" placeholder="pablo@closetsocial.app">
                      </div>
                      <div>
                        <label for="passwordInput">Contrasena</label>
                        <input id="passwordInput" type="password" autocomplete="current-password" placeholder="password123">
                      </div>
                    </div>

                    <div class="login-actions">
                      <button id="loginButton" class="button-primary" type="button">Entrar con credenciales</button>
                    </div>
                  </div>

                  <div class="stack">
                    <div>
                      <label for="tokenInput">Bearer token manual</label>
                      <textarea id="tokenInput" placeholder="Pega aqui un token ya emitido por /auth/login"></textarea>
                      <p class="hint">Puedes pegar el token con o sin el prefijo <code>Bearer </code>.</p>
                    </div>

                    <div class="login-actions">
                      <button id="useTokenButton" class="button-secondary" type="button">Usar token pegado</button>
                    </div>
                  </div>
                </div>
              </section>

              <section id="adminApp" class="hidden">
                <section class="panel">
                  <div class="dashboard-head">
                    <div>
                      <p class="eyebrow">Dashboard</p>
                      <h2>Metricas generales</h2>
                      <p class="panel-copy">Datos agregados consumidos desde <code>GET /admin/dashboard</code>.</p>
                    </div>
                    <span class="badge">Admin conectado</span>
                  </div>

                  <div class="metrics-grid">
                    <a class="metric-card metric-card-link" href="/debug/users">
                      <p class="metric-label">Usuarios</p>
                      <p class="metric-value" data-metric="totalUsers">-</p>
                      <p class="metric-foot">Usuarios registrados</p>
                      <span class="metric-link-copy">Abrir listado →</span>
                    </a>
                    <a class="metric-card metric-card-link" href="/debug/garments">
                      <p class="metric-label">Prendas</p>
                      <p class="metric-value" data-metric="totalGarments">-</p>
                      <p class="metric-foot">Items de armario</p>
                      <span class="metric-link-copy">Abrir listado →</span>
                    </a>
                    <a class="metric-card metric-card-link" href="/debug/outfits">
                      <p class="metric-label">Outfits</p>
                      <p class="metric-value" data-metric="totalOutfits">-</p>
                      <p class="metric-foot">Looks creados</p>
                      <span class="metric-link-copy">Abrir listado →</span>
                    </a>
                    <a class="metric-card metric-card-link" href="/debug/posts">
                      <p class="metric-label">Posts</p>
                      <p class="metric-value" data-metric="totalPosts">-</p>
                      <p class="metric-foot">Publicaciones</p>
                      <span class="metric-link-copy">Abrir listado →</span>
                    </a>
                    <article class="metric-card">
                      <p class="metric-label">Likes</p>
                      <p class="metric-value" data-metric="totalLikes">-</p>
                      <p class="metric-foot">Interacciones positivas</p>
                    </article>
                    <article class="metric-card">
                      <p class="metric-label">Comentarios</p>
                      <p class="metric-value" data-metric="totalComments">-</p>
                      <p class="metric-foot">Mensajes publicados</p>
                    </article>
                  </div>
                </section>

                <section class="panel">
                  <div class="section-title">
                    <p class="eyebrow">Catalogos</p>
                    <h2>Datos maestros administrables</h2>
                    <p class="panel-copy">
                      Primer paso antes de migrar el modelo actual de prendas para depender de estas tablas.
                    </p>
                  </div>

                  <div class="catalog-grid">
                    <article class="catalog-card">
                      <div class="catalog-card-head">
                        <div>
                          <h3>Tipos de prenda</h3>
                          <p class="catalog-copy">Gestiona las categorias maestras disponibles para futuras migraciones.</p>
                        </div>
                        <span class="badge" id="garmentTypesCount">0</span>
                      </div>

                      <form id="garmentTypeForm" class="catalog-form">
                        <input id="garmentTypeNameInput" type="text" placeholder="Nuevo tipo de prenda">
                        <button class="button-primary" type="submit">Crear</button>
                      </form>

                      <div class="table-wrap">
                        <table>
                          <thead>
                            <tr>
                              <th>Nombre</th>
                              <th>Creado</th>
                              <th>Actualizado</th>
                              <th>Acciones</th>
                            </tr>
                          </thead>
                          <tbody id="garmentTypesBody"></tbody>
                        </table>
                      </div>
                    </article>

                    <article class="catalog-card">
                      <div class="catalog-card-head">
                        <div>
                          <h3>Marcas</h3>
                          <p class="catalog-copy">Gestiona marcas maestras para reutilizarlas mas adelante en el dominio.</p>
                        </div>
                        <span class="badge" id="brandsCount">0</span>
                      </div>

                      <form id="brandForm" class="catalog-form">
                        <input id="brandNameInput" type="text" placeholder="Nueva marca">
                        <button class="button-primary" type="submit">Crear</button>
                      </form>

                      <div class="table-wrap">
                        <table>
                          <thead>
                            <tr>
                              <th>Nombre</th>
                              <th>Creado</th>
                              <th>Actualizado</th>
                              <th>Acciones</th>
                            </tr>
                          </thead>
                          <tbody id="brandsBody"></tbody>
                        </table>
                      </div>
                    </article>
                  </div>
                </section>
              </section>
            </main>

            <script>
              const storageKey = "closetsocial.admin.token";
              const loginPanel = document.querySelector("#loginPanel");
              const adminApp = document.querySelector("#adminApp");
              const statusMessage = document.querySelector("#statusMessage");
              const emailInput = document.querySelector("#emailInput");
              const passwordInput = document.querySelector("#passwordInput");
              const tokenInput = document.querySelector("#tokenInput");
              const loginButton = document.querySelector("#loginButton");
              const useTokenButton = document.querySelector("#useTokenButton");
              const refreshButton = document.querySelector("#refreshButton");
              const logoutButton = document.querySelector("#logoutButton");
              const metricNodes = [...document.querySelectorAll("[data-metric]")];
              const garmentTypesBody = document.querySelector("#garmentTypesBody");
              const brandsBody = document.querySelector("#brandsBody");
              const garmentTypesCount = document.querySelector("#garmentTypesCount");
              const brandsCount = document.querySelector("#brandsCount");
              const garmentTypeForm = document.querySelector("#garmentTypeForm");
              const brandForm = document.querySelector("#brandForm");
              const garmentTypeNameInput = document.querySelector("#garmentTypeNameInput");
              const brandNameInput = document.querySelector("#brandNameInput");

              const catalogConfig = {
                garmentType: {
                  path: "/admin/garment-types",
                  body: garmentTypesBody,
                  count: garmentTypesCount,
                  input: garmentTypeNameInput,
                  emptyLabel: "Todavia no hay tipos de prenda."
                },
                brand: {
                  path: "/admin/brands",
                  body: brandsBody,
                  count: brandsCount,
                  input: brandNameInput,
                  emptyLabel: "Todavia no hay marcas."
                }
              };

              function setStatus(message, tone) {
                if (!message) {
                  statusMessage.textContent = "";
                  statusMessage.className = "status";
                  return;
                }

                statusMessage.textContent = message;
                statusMessage.className = "status is-visible";
                if (tone === "error") {
                  statusMessage.classList.add("is-error");
                }
                if (tone === "success") {
                  statusMessage.classList.add("is-success");
                }
              }

              function normalizeToken(rawValue) {
                return rawValue.replace(/^Bearer\\s+/i, "").trim();
              }

              function storeToken(token) {
                localStorage.setItem(storageKey, token);
              }

              function clearToken() {
                localStorage.removeItem(storageKey);
              }

              function getStoredToken() {
                return normalizeToken(localStorage.getItem(storageKey) ?? "");
              }

              function showLogin(message, tone) {
                loginPanel.classList.remove("hidden");
                adminApp.classList.add("hidden");
                refreshButton.classList.add("hidden");
                logoutButton.classList.add("hidden");
                setStatus(message ?? "", tone);
              }

              function showAdminApp(message, tone) {
                loginPanel.classList.add("hidden");
                adminApp.classList.remove("hidden");
                refreshButton.classList.remove("hidden");
                logoutButton.classList.remove("hidden");
                setStatus(message ?? "", tone);
              }

              function formatDate(value) {
                if (!value) {
                  return "—";
                }

                const date = new Date(value);
                if (Number.isNaN(date.getTime())) {
                  return "—";
                }

                return new Intl.DateTimeFormat("es-ES", {
                  dateStyle: "short",
                  timeStyle: "short"
                }).format(date);
              }

              async function requestJSON(path, token, options = {}) {
                const response = await fetch(path, {
                  method: options.method ?? "GET",
                  headers: {
                    "Authorization": "Bearer " + token,
                    ...(options.body ? { "Content-Type": "application/json" } : {})
                  },
                  body: options.body ? JSON.stringify(options.body) : undefined
                });

                if (response.status === 401) {
                  clearToken();
                  throw new Error("La sesion ya no es valida. Vuelve a iniciar sesion.");
                }

                if (response.status === 403) {
                  clearToken();
                  throw new Error("Tu usuario no tiene permisos de administrador.");
                }

                if (response.status === 204) {
                  return null;
                }

                if (!response.ok) {
                  let message = "No se pudo completar la operacion.";
                  try {
                    const payload = await response.json();
                    if (typeof payload.reason === "string" && payload.reason) {
                      message = payload.reason;
                    }
                  } catch {
                    // ignore body parsing for non-json errors
                  }
                  throw new Error(message);
                }

                return response.json();
              }

              function renderDashboard(stats) {
                metricNodes.forEach((node) => {
                  const key = node.dataset.metric;
                  node.textContent = String(stats[key] ?? 0);
                });
              }

              function renderCatalog(kind, items) {
                const config = catalogConfig[kind];
                config.count.textContent = String(items.length);

                if (items.length === 0) {
                  config.body.innerHTML = "<tr><td class=\\"empty-state\\" colspan=\\"4\\">" + config.emptyLabel + "</td></tr>";
                  return;
                }

                config.body.innerHTML = items.map((item) => {
                  const safeName = item.name
                    .replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;")
                    .replace(/\\"/g, "&quot;");

                  return [
                    "<tr>",
                    "<td><strong>" + safeName + "</strong></td>",
                    "<td class=\\"muted\\">" + formatDate(item.createdAt) + "</td>",
                    "<td class=\\"muted\\">" + formatDate(item.updatedAt) + "</td>",
                    "<td>",
                    "<div class=\\"row-actions\\">",
                    "<button class=\\"button-secondary inline-button\\" type=\\"button\\" data-catalog-action=\\"edit\\" data-catalog-kind=\\"" + kind + "\\" data-catalog-id=\\"" + item.id + "\\" data-catalog-name=\\"" + safeName + "\\">Editar</button>",
                    "<button class=\\"button-danger inline-button\\" type=\\"button\\" data-catalog-action=\\"delete\\" data-catalog-kind=\\"" + kind + "\\" data-catalog-id=\\"" + item.id + "\\" data-catalog-name=\\"" + safeName + "\\">Eliminar</button>",
                    "</div>",
                    "</td>",
                    "</tr>"
                  ].join("");
                }).join("");
              }

              async function loadAdminData(token, successMessage) {
                try {
                  const [stats, garmentTypes, brands] = await Promise.all([
                    requestJSON("/admin/dashboard", token),
                    requestJSON("/admin/garment-types", token),
                    requestJSON("/admin/brands", token)
                  ]);

                  renderDashboard(stats);
                  renderCatalog("garmentType", garmentTypes);
                  renderCatalog("brand", brands);
                  showAdminApp(successMessage ?? "", successMessage ? "success" : "");
                } catch (error) {
                  showLogin(error.message, "error");
                }
              }

              async function loginWithCredentials() {
                const email = emailInput.value.trim();
                const password = passwordInput.value;

                if (!email || !password) {
                  setStatus("Introduce email y contrasena para iniciar sesion.", "error");
                  return;
                }

                setStatus("Iniciando sesion...", "success");

                const response = await fetch("/auth/login", {
                  method: "POST",
                  headers: {
                    "Content-Type": "application/json"
                  },
                  body: JSON.stringify({ email, password })
                });

                if (response.status === 401) {
                  setStatus("Credenciales invalidas.", "error");
                  return;
                }

                if (!response.ok) {
                  setStatus("No se pudo iniciar sesion en este momento.", "error");
                  return;
                }

                const payload = await response.json();
                const token = normalizeToken(payload.token ?? "");

                if (!token) {
                  setStatus("La respuesta de login no incluye token.", "error");
                  return;
                }

                storeToken(token);
                await loadAdminData(token, "Sesion iniciada correctamente.");
              }

              async function useManualToken() {
                const token = normalizeToken(tokenInput.value);

                if (!token) {
                  setStatus("Pega un token valido para continuar.", "error");
                  return;
                }

                storeToken(token);
                await loadAdminData(token, "Token cargado correctamente.");
              }

              async function createCatalogItem(kind) {
                const token = getStoredToken();
                const config = catalogConfig[kind];
                const name = config.input.value.trim();

                if (!token) {
                  showLogin("No hay token guardado. Vuelve a iniciar sesion.", "error");
                  return;
                }

                if (!name) {
                  setStatus("Introduce un nombre antes de crear el elemento.", "error");
                  return;
                }

                try {
                  await requestJSON(config.path, token, {
                    method: "POST",
                    body: { name }
                  });
                  config.input.value = "";
                  await loadAdminData(token, "Catalogo actualizado correctamente.");
                } catch (error) {
                  setStatus(error.message, "error");
                }
              }

              async function editCatalogItem(kind, id, currentName) {
                const token = getStoredToken();
                if (!token) {
                  showLogin("No hay token guardado. Vuelve a iniciar sesion.", "error");
                  return;
                }

                const nextName = window.prompt("Nuevo nombre", currentName);
                if (nextName === null) {
                  return;
                }

                if (!nextName.trim()) {
                  setStatus("El nombre no puede estar vacio.", "error");
                  return;
                }

                try {
                  await requestJSON(catalogConfig[kind].path + "/" + id, token, {
                    method: "PATCH",
                    body: { name: nextName }
                  });
                  await loadAdminData(token, "Elemento actualizado correctamente.");
                } catch (error) {
                  setStatus(error.message, "error");
                }
              }

              async function deleteCatalogItem(kind, id, currentName) {
                const token = getStoredToken();
                if (!token) {
                  showLogin("No hay token guardado. Vuelve a iniciar sesion.", "error");
                  return;
                }

                const confirmed = window.confirm("Eliminar '" + currentName + "'?");
                if (!confirmed) {
                  return;
                }

                try {
                  await requestJSON(catalogConfig[kind].path + "/" + id, token, {
                    method: "DELETE"
                  });
                  await loadAdminData(token, "Elemento eliminado correctamente.");
                } catch (error) {
                  setStatus(error.message, "error");
                }
              }

              function logout() {
                clearToken();
                showLogin("Sesion local eliminada.", "success");
              }

              loginButton.addEventListener("click", () => {
                void loginWithCredentials();
              });

              useTokenButton.addEventListener("click", () => {
                void useManualToken();
              });

              refreshButton.addEventListener("click", () => {
                const token = getStoredToken();
                if (!token) {
                  showLogin("No hay token guardado. Vuelve a iniciar sesion.", "error");
                  return;
                }
                void loadAdminData(token, "Panel actualizado.");
              });

              logoutButton.addEventListener("click", logout);

              garmentTypeForm.addEventListener("submit", (event) => {
                event.preventDefault();
                void createCatalogItem("garmentType");
              });

              brandForm.addEventListener("submit", (event) => {
                event.preventDefault();
                void createCatalogItem("brand");
              });

              document.addEventListener("click", (event) => {
                const target = event.target;
                if (!(target instanceof HTMLElement)) {
                  return;
                }

                const button = target.closest("[data-catalog-action]");
                if (!(button instanceof HTMLElement)) {
                  return;
                }

                const action = button.dataset.catalogAction;
                const kind = button.dataset.catalogKind;
                const id = button.dataset.catalogId;
                const name = button.dataset.catalogName ?? "";

                if (!action || !kind || !id) {
                  return;
                }

                if (action === "edit") {
                  void editCatalogItem(kind, id, name);
                }

                if (action === "delete") {
                  void deleteCatalogItem(kind, id, name);
                }
              });

              window.addEventListener("load", () => {
                const token = getStoredToken();
                if (!token) {
                  showLogin();
                  return;
                }
                void loadAdminData(token);
              });
            </script>
          </body>
        </html>
        """

        var headers = HTTPHeaders()
        headers.contentType = .html
        return Response(status: .ok, headers: headers, body: .init(string: html))
    }
}
