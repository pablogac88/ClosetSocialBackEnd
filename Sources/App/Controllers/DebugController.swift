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
              <a class="card-link" href="/debug/outfits">
                <strong>Outfits</strong>
                <span>Ver la tabla <code>outfits</code></span>
              </a>
              <a class="card-link" href="/debug/posts">
                <strong>Posts</strong>
                <span>Ver la tabla <code>posts</code></span>
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
            let id = user.id?.uuidString ?? "—"
            let username = detailLink(path: "/debug/users/\(id)", label: user.username)
            return tableRow([
                codeLinkCell(path: "/debug/users/\(id)", code: id),
                cell(username),
                cell(user.displayName.htmlEscaped),
                cell(user.email.htmlEscaped),
                cell(user.role.rawValue.htmlEscaped),
                cell((user.avatarURL ?? "—").htmlEscaped),
                cell((user.bio ?? "—").htmlEscaped),
                cell(user.createdAt?.ISO8601Format().htmlEscaped ?? "—")
            ])
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
                  <th>Bio</th>
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

    func userDetail(_ req: Request) async throws -> Response {
        let id = try uuidParameter(named: "id", in: req)
        guard let user = try await UserModel.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Usuario no encontrado.")
        }

        let garments = try await GarmentModel.query(on: req.db)
            .filter(\.$user.$id == id)
            .sort(\.$createdAt, .descending)
            .limit(12)
            .all()

        let outfits = try await OutfitModel.query(on: req.db)
            .filter(\.$user.$id == id)
            .sort(\.$createdAt, .descending)
            .limit(12)
            .all()

        let posts = try await PostModel.query(on: req.db)
            .filter(\.$user.$id == id)
            .sort(\.$createdAt, .descending)
            .limit(12)
            .all()

        let garmentsList = linkedList(
            garments,
            emptyMessage: "Este usuario no tiene prendas todavía."
        ) { garment in
            detailLink(
                path: "/debug/garments/\((garment.id?.uuidString ?? "").htmlEscaped)",
                label: garment.name
            )
        }

        let outfitsList = linkedList(
            outfits,
            emptyMessage: "Este usuario no tiene outfits todavía."
        ) { outfit in
            detailLink(
                path: "/debug/outfits/\((outfit.id?.uuidString ?? "").htmlEscaped)",
                label: outfit.title ?? "Outfit sin título"
            )
        }

        let postsList = linkedList(
            posts,
            emptyMessage: "Este usuario no tiene posts todavía."
        ) { post in
            detailLink(
                path: "/debug/posts/\((post.id?.uuidString ?? "").htmlEscaped)",
                label: post.caption.isEmpty ? "Post sin caption" : post.caption
            )
        }

        return htmlResponse(
            title: "Usuario · \(user.username)",
            body: """
            \(header(title: "Usuario", count: nil))
            \(detailCard(
                title: user.displayName,
                subtitle: "@\(user.username)",
                content: """
                \(keyValueGrid(rows: [
                    ("ID", "<code>\((user.id?.uuidString ?? "—").htmlEscaped)</code>"),
                    ("Email", user.email.htmlEscaped),
                    ("Rol", user.role.rawValue.htmlEscaped),
                    ("Avatar URL", (user.avatarURL ?? "—").htmlEscaped),
                    ("Bio", (user.bio ?? "—").htmlEscaped),
                    ("Creado", user.createdAt?.ISO8601Format().htmlEscaped ?? "—")
                ]))
                """
            ))
            <div class="detail-grid">
              \(detailCard(title: "Prendas", subtitle: "\(garments.count)", content: garmentsList))
              \(detailCard(title: "Outfits", subtitle: "\(outfits.count)", content: outfitsList))
              \(detailCard(title: "Posts", subtitle: "\(posts.count)", content: postsList))
            </div>
            """
        )
    }

    func garments(_ req: Request) async throws -> Response {
        let garments = try await GarmentModel.query(on: req.db)
            .with(\.$user)
            .sort(\.$createdAt, .descending)
            .all()

        let rows = garments.map { garment in
            let id = garment.id?.uuidString ?? "—"
            let userID = garment.user.id?.uuidString ?? "—"
            return tableRow([
                codeLinkCell(path: "/debug/garments/\(id)", code: id),
                cell(detailLink(path: "/debug/garments/\(id)", label: garment.name)),
                cell(garment.brand.htmlEscaped),
                cell(garment.category.htmlEscaped),
                cell(garment.color.htmlEscaped),
                cell((garment.imageURL ?? "—").htmlEscaped),
                codeLinkCell(path: "/debug/users/\(userID)", code: userID),
                cell(detailLink(path: "/debug/users/\(userID)", label: garment.user.username)),
                cell(garment.createdAt?.ISO8601Format().htmlEscaped ?? "—")
            ])
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
                  <th>Image URL</th>
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

    func garmentDetail(_ req: Request) async throws -> Response {
        let id = try uuidParameter(named: "id", in: req)
        guard let garment = try await GarmentModel.query(on: req.db)
            .filter(\.$id == id)
            .with(\.$user)
            .first()
        else {
            throw Abort(.notFound, reason: "Prenda no encontrada.")
        }

        let outfitItems = try await OutfitItemModel.query(on: req.db)
            .filter(\.$garment.$id == id)
            .with(\.$outfit) { outfit in
                outfit.with(\.$user)
            }
            .sort(\.$position, .ascending)
            .all()

        let usedInOutfits = linkedList(
            outfitItems,
            emptyMessage: "Esta prenda no está usada en ningún outfit."
        ) { item in
            let outfitID = item.outfit.id?.uuidString ?? ""
            let title = item.outfit.title ?? "Outfit sin título"
            return "\(detailLink(path: "/debug/outfits/\(outfitID)", label: title)) · posición \(item.position)"
        }

        return htmlResponse(
            title: "Prenda · \(garment.name)",
            body: """
            \(header(title: "Prenda", count: nil))
            \(detailCard(
                title: garment.name,
                subtitle: garment.brand,
                content: """
                \(keyValueGrid(rows: [
                    ("ID", "<code>\((garment.id?.uuidString ?? "—").htmlEscaped)</code>"),
                    ("Marca", garment.brand.htmlEscaped),
                    ("Categoría", garment.category.htmlEscaped),
                    ("Color", garment.color.htmlEscaped),
                    ("Image URL", (garment.imageURL ?? "—").htmlEscaped),
                    ("Owner", detailLink(
                        path: "/debug/users/\((garment.user.id?.uuidString ?? "").htmlEscaped)",
                        label: garment.user.username
                    )),
                    ("Creado", garment.createdAt?.ISO8601Format().htmlEscaped ?? "—")
                ]))
                """
            ))
            \(detailCard(title: "Usada en outfits", subtitle: "\(outfitItems.count)", content: usedInOutfits))
            """
        )
    }

    func outfits(_ req: Request) async throws -> Response {
        let outfits = try await OutfitModel.query(on: req.db)
            .with(\.$user)
            .with(\.$items)
            .sort(\.$createdAt, .descending)
            .all()

        let rows = outfits.map { outfit in
            let id = outfit.id?.uuidString ?? "—"
            let userID = outfit.user.id?.uuidString ?? "—"
            return tableRow([
                codeLinkCell(path: "/debug/outfits/\(id)", code: id),
                cell(detailLink(path: "/debug/outfits/\(id)", label: outfit.title ?? "Outfit sin título")),
                cell((outfit.note ?? "—").htmlEscaped),
                cell(String(outfit.items.count)),
                cell(detailLink(path: "/debug/users/\(userID)", label: outfit.user.username)),
                cell(outfit.createdAt?.ISO8601Format().htmlEscaped ?? "—")
            ])
        }.joined()

        return htmlResponse(
            title: "Outfits",
            body: """
            \(header(title: "Outfits", count: outfits.count))
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Título</th>
                  <th>Nota</th>
                  <th>Prendas</th>
                  <th>Usuario</th>
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

    func outfitDetail(_ req: Request) async throws -> Response {
        let id = try uuidParameter(named: "id", in: req)
        let outfitQuery = OutfitModel.query(on: req.db)
            .filter(\.$id == id)
            .with(\.$user)
            .with(\.$items) {
                $0.with(\.$garment)
            }
        guard let outfit = try await outfitQuery.first()
        else {
            throw Abort(.notFound, reason: "Outfit no encontrado.")
        }

        let itemsRows = outfit.items.sorted { $0.position < $1.position }.map { item in
            let garmentID = item.garment.id?.uuidString ?? "—"
            return tableRow([
                cell(String(item.position)),
                cell(detailLink(path: "/debug/garments/\(garmentID)", label: item.garment.name)),
                cell(item.garment.brand.htmlEscaped),
                cell(item.garment.category.htmlEscaped),
                cell(item.garment.color.htmlEscaped)
            ])
        }.joined()

        let itemsContent: String
        if outfit.items.isEmpty {
            itemsContent = emptyState("Este outfit no tiene prendas asociadas.")
        } else {
            itemsContent = """
            <table>
              <thead>
                <tr>
                  <th>Posición</th>
                  <th>Prenda</th>
                  <th>Marca</th>
                  <th>Categoría</th>
                  <th>Color</th>
                </tr>
              </thead>
              <tbody>
                \(itemsRows)
              </tbody>
            </table>
            """
        }

        return htmlResponse(
            title: "Outfit · \(outfit.title ?? "Sin título")",
            body: """
            \(header(title: "Outfit", count: nil))
            \(detailCard(
                title: outfit.title ?? "Outfit sin título",
                subtitle: outfit.note ?? "Sin nota",
                content: """
                \(keyValueGrid(rows: [
                    ("ID", "<code>\((outfit.id?.uuidString ?? "—").htmlEscaped)</code>"),
                    ("Usuario", detailLink(
                        path: "/debug/users/\((outfit.user.id?.uuidString ?? "").htmlEscaped)",
                        label: outfit.user.username
                    )),
                    ("Prendas", "\(outfit.items.count)"),
                    ("Creado", outfit.createdAt?.ISO8601Format().htmlEscaped ?? "—")
                ]))
                \(outfit.layoutJSON.map { "<h3>layoutJSON</h3><pre>\($0.htmlEscaped)</pre>" } ?? "")
                """
            ))
            \(detailCard(title: "Prendas del outfit", subtitle: "\(outfit.items.count)", content: itemsContent))
            """
        )
    }

    func posts(_ req: Request) async throws -> Response {
        let posts = try await PostModel.query(on: req.db)
            .with(\.$user)
            .sort(\.$createdAt, .descending)
            .all()

        let outfitIDs = Array(Set(posts.compactMap { $0.$outfit.id }))
        let garmentIDs = Array(Set(posts.compactMap { $0.$garment.id }))

        let outfits = try await OutfitModel.query(on: req.db)
            .filter(\.$id ~~ outfitIDs)
            .all()
        let garments = try await GarmentModel.query(on: req.db)
            .filter(\.$id ~~ garmentIDs)
            .all()

        let outfitsByID: [UUID: OutfitModel] = Dictionary(uniqueKeysWithValues: outfits.compactMap { outfit in
            guard let id = outfit.id else { return nil }
            return (id, outfit)
        })
        let garmentsByID: [UUID: GarmentModel] = Dictionary(uniqueKeysWithValues: garments.compactMap { garment in
            guard let id = garment.id else { return nil }
            return (id, garment)
        })

        let rows = posts.map { post in
            let id = post.id?.uuidString ?? "—"
            let userID = post.user.id?.uuidString ?? "—"
            let relatedOutfit = post.$outfit.id.flatMap { outfitID in
                outfitsByID[outfitID].map {
                    detailLink(path: "/debug/outfits/\(outfitID.uuidString)", label: $0.title ?? "Outfit sin título")
                }
            } ?? "—"
            let relatedGarment = post.$garment.id.flatMap { garmentID in
                garmentsByID[garmentID].map {
                    detailLink(path: "/debug/garments/\(garmentID.uuidString)", label: $0.name)
                }
            } ?? "—"

            return tableRow([
                codeLinkCell(path: "/debug/posts/\(id)", code: id),
                cell(detailLink(path: "/debug/posts/\(id)", label: post.caption.isEmpty ? "Post sin caption" : post.caption)),
                cell(detailLink(path: "/debug/users/\(userID)", label: post.user.username)),
                cell(relatedGarment),
                cell(relatedOutfit),
                cell(String(post.imageURLs.count)),
                cell(post.createdAt?.ISO8601Format().htmlEscaped ?? "—")
            ])
        }.joined()

        return htmlResponse(
            title: "Posts",
            body: """
            \(header(title: "Posts", count: posts.count))
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Caption</th>
                  <th>Usuario</th>
                  <th>Prenda</th>
                  <th>Outfit</th>
                  <th>Imágenes</th>
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

    func postDetail(_ req: Request) async throws -> Response {
        let id = try uuidParameter(named: "id", in: req)
        guard let post = try await PostModel.query(on: req.db)
            .filter(\.$id == id)
            .with(\.$user)
            .first()
        else {
            throw Abort(.notFound, reason: "Post no encontrado.")
        }

        let outfit: OutfitModel? = if let outfitID = post.$outfit.id {
            try await OutfitModel.find(outfitID, on: req.db)
        } else {
            nil
        }

        let garment: GarmentModel? = if let garmentID = post.$garment.id {
            try await GarmentModel.find(garmentID, on: req.db)
        } else {
            nil
        }

        let imageList = linkedList(
            post.imageURLs,
            emptyMessage: "Este post no tiene imágenes."
        ) { imageURL in
            "<a href=\"\(imageURL.htmlEscaped)\" target=\"_blank\" rel=\"noreferrer\">\(imageURL.htmlEscaped)</a>"
        }

        return htmlResponse(
            title: "Post",
            body: """
            \(header(title: "Post", count: nil))
            \(detailCard(
                title: "Post de @\(post.user.username)",
                subtitle: post.caption.isEmpty ? "Sin caption" : post.caption,
                content: """
                \(keyValueGrid(rows: [
                    ("ID", "<code>\((post.id?.uuidString ?? "—").htmlEscaped)</code>"),
                    ("Usuario", detailLink(
                        path: "/debug/users/\((post.user.id?.uuidString ?? "").htmlEscaped)",
                        label: post.user.username
                    )),
                    ("Prenda", garment.map {
                        detailLink(path: "/debug/garments/\(($0.id?.uuidString ?? "").htmlEscaped)", label: $0.name)
                    } ?? "—"),
                    ("Outfit", outfit.map {
                        detailLink(path: "/debug/outfits/\(($0.id?.uuidString ?? "").htmlEscaped)", label: $0.title ?? "Outfit sin título")
                    } ?? "—"),
                    ("Imágenes", "\(post.imageURLs.count)"),
                    ("Creado", post.createdAt?.ISO8601Format().htmlEscaped ?? "—")
                ]))
                """
            ))
            \(detailCard(title: "Image URLs", subtitle: "\(post.imageURLs.count)", content: imageList))
            """
        )
    }

    private func header(title: String, count: Int?) -> String {
        let countHTML = count.map { "<span class=\"badge\">\($0)</span>" } ?? ""
        return """
        <div class="hero">
          <div class="hero-top">
            <h1>\(title.htmlEscaped)</h1>
            \(countHTML)
          </div>
          <div class="nav">
            <a href="/debug">Inicio</a>
            <a href="/debug/users">Usuarios</a>
            <a href="/debug/garments">Prendas</a>
            <a href="/debug/outfits">Outfits</a>
            <a href="/debug/posts">Posts</a>
          </div>
        </div>
        """
    }

    private func uuidParameter(named name: String, in req: Request) throws -> UUID {
        guard let id = req.parameters.get(name, as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID inválido.")
        }
        return id
    }

    private func detailLink(path: String, label: String) -> String {
        "<a href=\"\(path.htmlEscaped)\">\(label.htmlEscaped)</a>"
    }

    private func cell(_ value: String) -> String {
        "<td>" + value + "</td>"
    }

    private func codeLinkCell(path: String, code: String) -> String {
        "<td><a href=\"" + path.htmlEscaped + "\"><code>" + code.htmlEscaped + "</code></a></td>"
    }

    private func tableRow(_ cells: [String]) -> String {
        "<tr>" + cells.joined() + "</tr>"
    }

    private func detailCard(title: String, subtitle: String, content: String) -> String {
        """
        <section class="detail-card">
          <div class="detail-card-header">
            <div>
              <h2>\(title.htmlEscaped)</h2>
              <p>\(subtitle.htmlEscaped)</p>
            </div>
          </div>
          <div class="detail-card-content">
            \(content)
          </div>
        </section>
        """
    }

    private func keyValueGrid(rows: [(String, String)]) -> String {
        let items = rows.map { key, value in
            """
            <div class="kv-item">
              <span class="kv-key">\(key.htmlEscaped)</span>
              <div class="kv-value">\(value)</div>
            </div>
            """
        }.joined()

        return "<div class=\"kv-grid\">\(items)</div>"
    }

    private func linkedList<T>(
        _ items: [T],
        emptyMessage: String,
        row: (T) -> String
    ) -> String {
        guard items.isEmpty == false else {
            return emptyState(emptyMessage)
        }

        let rows = items.map { item in
            "<li>\(row(item))</li>"
        }.joined()

        return "<ul class=\"linked-list\">\(rows)</ul>"
    }

    private func emptyState(_ message: String) -> String {
        "<div class=\"empty-state\">\(message.htmlEscaped)</div>"
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
              a:hover {
                color: var(--accent);
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
              .detail-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 16px;
              }
              .detail-card {
                background: var(--card);
                border: 1px solid var(--border);
                border-radius: 24px;
                box-shadow: 0 18px 45px rgba(22, 32, 51, 0.08);
                overflow: hidden;
                margin-bottom: 20px;
              }
              .detail-card-header {
                padding: 20px 22px 0;
              }
              .detail-card-header h2 {
                margin: 0 0 6px;
                font-size: 22px;
              }
              .detail-card-header p {
                margin: 0;
                color: var(--muted);
              }
              .detail-card-content {
                padding: 20px 22px 22px;
              }
              .kv-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                gap: 14px;
              }
              .kv-item {
                padding: 14px 16px;
                border-radius: 16px;
                background: rgba(255,255,255,0.85);
                border: 1px solid var(--border);
              }
              .kv-key {
                display: block;
                margin-bottom: 6px;
                font-size: 12px;
                font-weight: 700;
                color: var(--muted);
                text-transform: uppercase;
                letter-spacing: 0.04em;
              }
              .kv-value {
                line-height: 1.5;
                word-break: break-word;
              }
              .linked-list {
                margin: 0;
                padding-left: 18px;
                line-height: 1.7;
              }
              .linked-list li + li {
                margin-top: 6px;
              }
              .empty-state {
                padding: 18px;
                border-radius: 16px;
                background: rgba(255,255,255,0.85);
                border: 1px dashed var(--border);
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
              tbody tr:hover {
                background: rgba(74, 139, 255, 0.04);
              }
              tr:last-child td { border-bottom: none; }
              code {
                font-size: 12px;
                white-space: nowrap;
              }
              pre {
                margin: 18px 0 0;
                padding: 16px;
                border-radius: 18px;
                background: #101826;
                color: #f5f7fb;
                overflow-x: auto;
                white-space: pre-wrap;
                word-break: break-word;
                font-size: 12px;
                line-height: 1.5;
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
