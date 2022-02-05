import prologue

import routes/root as rootRoutes

let
    env = loadPrologueEnv(".env")
    settings = newSettings(
        appName = env.getOrDefault("appName", "SteveStudies"),
        debug = env.getOrDefault("debug", true),
        port = Port(env.getOrDefault("port", 8080)),
        secretKey = env.getOrDefault("secretKey", "bob")
    )

var app = newApp(settings = settings)

app.addRoute(rootRoutes.routes, "/")

app.run()
