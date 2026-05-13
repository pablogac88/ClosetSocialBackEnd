import Fluent
import Vapor

struct DebugController: Sendable {
    func index(_ req: Request) async throws -> Response {
        htmlResponse(
            title: "ClosetSocial Debug",
            body: """
            <div class="hero">
              <h1>ClosetSocial Debug</h1>
              <p>Accesos rápidos para inspeccionar la base de datos local mientras desarrollamos.</p>
            </div>
            <div class="card-grid">
              <a class="card-link" href="/debug/users">
                <strong>Usuarios</strong>
                <span>Ver la tabla <code>users</code></span>
              </a>
              <a class="card-link" href="/debug/garments">
                <strong>Prendas</strong>
                <span>Ver la tabla <code>garments</code></span>
              </a>
            </div>
            """
        )
    }

    func users(_ req: Request) async throws -> Response {
        let users = try await UserModel.query(on: req.db)
            .sort(\.$createdAt, .descending)
            .all()

        let rows = users.map { user in
            """
            <tr>
              <td><code>\((user.id?.uuidString ?? "—").htmlEscaped)</code></td>
              <td>\(user.username.htmlEscaped)</td>
              <td>\(user.displayName.htmlEscaped)</td>
              <td>\(user.email.htmlEscaped)</td>
              <td>\(user.role.rawValue.htmlEscaped)</td>
              <td>\((user.avatarURL ?? "—").htmlEscaped)</td>
              <td>\(user.createdAt?.ISO8601Format().htmlEscaped ?? "—")</td>
            </tr>
            """
        }.joined()

        return htmlResponse(
            title: "Usuarios",
            body: """
            \(header(title: "Usuarios", count: users.count))
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Username</th>
                  <th>Display name</th>
                  <th>Email</th>
                  <th>Role</th>
                  <th>Avatar URL</th>
                  <th>Creado</th>
                </tr>
              </thead>
              <tbody>
                \(rows)
              </tbody>
            </table>
            """
        )
    }

    func garments(_ req: Request) async throws -> Response {
        let garments = try await GarmentModel.query(on: req.db)
            .with(\.$user)
            .sort(\.$createdAt, .descending)
            .all()

        let rows = garments.map { garment in
            """
            <tr>
              <td><code>\((garment.id?.uuidString ?? "—").htmlEscaped)</code></td>
              <td>\(garment.name.htmlEscaped)</td>
              <td>\(garment.brand.htmlEscaped)</td>
              <td>\(garment.category.htmlEscaped)</td>
              <td>\(garment.color.htmlEscaped)</td>
              <td>\((garment.user.id?.uuidString ?? "—").htmlEscaped)</td>
              <td>\(garment.user.username.htmlEscaped)</td>
              <td>\(garment.createdAt?.ISO8601Format().htmlEscaped ?? "—")</td>
            </tr>
            """
        }.joined()

        return htmlResponse(
            title: "Prendas",
            body: """
            \(header(title: "Prendas", count: garments.count))
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Nombre</th>
                  <th>Marca</th>
                  <th>Categoría</th>
                  <th>Color</th>
                  <th>User ID</th>
                  <th>Username</th>
                  <th>Creado</th>
                </tr>
              </thead>
              <tbody>
                \(rows)
              </tbody>
            </table>
            """
        )
    }

    private func header(title: String, count: Int) -> String {
        """
        <div class="hero">
          <div class="hero-top">
            <h1>\(title.htmlEscaped)</h1>
            <span class="badge">\(count)</span>
          </div>
          <div class="nav">
            <a href="/debug">Inicio</a>
            <a href="/debug/users">Usuarios</a>
            <a href="/debug/garments">Prendas</a>
          </div>
        </div>
        """
    }

    private func htmlResponse(title: String, body: String) -> Response {
        let document = """
        <!doctype html>
        <html lang="es">
          <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>\(title.htmlEscaped)</title>
            <style>
              :root {
                color-scheme: light;
                --bg: #f5f7fb;
                --card: rgba(255,255,255,0.92);
                --text: #162033;
                --muted: #5d6a81;
                --border: #d9e1ef;
                --accent: #4a8bff;
                --accent-soft: rgba(74, 139, 255, 0.12);
              }
              * { box-sizing: border-box; }
              body {
                margin: 0;
                font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Segoe UI", sans-serif;
                background:
                  radial-gradient(circle at top left, rgba(74, 139, 255, 0.15), transparent 30%),
                  radial-gradient(circle at top right, rgba(130, 198, 255, 0.18), transparent 24%),
                  var(--bg);
                color: var(--text);
              }
              .page {
                width: min(1200px, calc(100vw - 32px));
                margin: 32px auto;
              }
              .hero {
                background: var(--card);
                border: 1px solid var(--border);
                border-radius: 24px;
                padding: 24px;
                backdrop-filter: blur(14px);
                box-shadow: 0 18px 45px rgba(22, 32, 51, 0.08);
                margin-bottom: 20px;
              }
              .hero h1 {
                margin: 0 0 8px;
                font-size: 30px;
              }
              .hero p {
                margin: 0;
                color: var(--muted);
                line-height: 1.5;
              }
              .hero-top {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 16px;
                margin-bottom: 14px;
              }
              .badge {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                min-width: 42px;
                height: 42px;
                padding: 0 14px;
                border-radius: 999px;
                background: var(--accent-soft);
                color: var(--accent);
                font-weight: 700;
              }
              .nav {
                display: flex;
                gap: 12px;
                flex-wrap: wrap;
              }
              .nav a, .card-link {
                text-decoration: none;
                color: var(--text);
              }
              .nav a {
                padding: 10px 14px;
                border-radius: 999px;
                background: #fff;
                border: 1px solid var(--border);
              }
              .card-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                gap: 16px;
                margin-top: 18px;
              }
              .card-link {
                display: flex;
                flex-direction: column;
                gap: 6px;
                padding: 18px;
                background: #fff;
                border: 1px solid var(--border);
                border-radius: 18px;
                box-shadow: 0 12px 30px rgba(22, 32, 51, 0.06);
              }
              .card-link span {
                color: var(--muted);
              }
              table {
                width: 100%;
                border-collapse: collapse;
                background: var(--card);
                border: 1px solid var(--border);
                border-radius: 24px;
                overflow: hidden;
                box-shadow: 0 18px 45px rgba(22, 32, 51, 0.08);
              }
              th, td {
                padding: 14px 16px;
                text-align: left;
                border-bottom: 1px solid var(--border);
                vertical-align: top;
                font-size: 14px;
              }
              th {
                background: rgba(255,255,255,0.92);
                color: var(--muted);
                font-weight: 700;
                position: sticky;
                top: 0;
              }
              tr:last-child td { border-bottom: none; }
              code {
                font-size: 12px;
                white-space: nowrap;
              }
            </style>
          </head>
          <body>
            <main class="page">
              \(body)
            </main>
          </body>
        </html>
        """

        var headers = HTTPHeaders()
        headers.contentType = .html
        return Response(status: .ok, headers: headers, body: .init(string: document))
    }
}

private extension String {
    var htmlEscaped: String {
        replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
