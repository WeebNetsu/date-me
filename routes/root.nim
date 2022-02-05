import prologue, strformat, options, uri

import ./generalUse

proc index(ctx: Context) {. async, gcsafe .} =
    if ctx.request.reqMethod == HttpGet:
        let name = "sdasda"
        resp &"""
            <body>
                <h1>Hello {name}!</h1>
            </body>
        """
    else:
        resp "<h1>404! (Unknown request)!</h1>"


proc login(ctx: Context) {. async, gcsafe .} =
    let frmUserName: Option[string] = ctx.getFormItem("name")

    if not isSome(frmUserName):
        let redirectUrl = parseUri("/signup") ? {"error": "Could not get username"}
        resp redirect($redirectUrl)
        return

    if ctx.request.reqMethod == HttpGet:
        let data: HTMLPage = HTMLPage(
                title: "Login",
                desc: "Login to find your true love!",
                content: &"""
                    <form action="/" method="post">
                        <div class="form-group">
                            <label for="email">Email:</label>
                            <input
                                type="email"
                                name="email"
                                placeholder="jack@gmail.com"
                                id="email"
                                required  class="form-control"
                            />
                        </div>
                        <div class="form-group">
                            <label for="passwd">Password:</label>
                            <input type="password" name="password" id="passwd" required  class="form-control" />
                        </div>
                        <button type="submit" class="btn btn-primary">Login</button>
                    </form>
                """,
            )

        resp generateHTML(data)
    elif ctx.request.reqMethod == HttpPost:
        resp "<h1>TODO</h1>"
    else:
        resp "<h1>404! (Unknown request)!</h1>"

proc signup(ctx: Context) {. async, gcsafe .} =
    let queries: StringTableRef = ctx.request.queryParams
    var err: string
    var alertType = AlertType.NONE

    if queries.contains("error"):
        err = queries["error"]
        alertType = AlertType.ERROR

    if ctx.request.reqMethod == HttpGet:
        let data: HTMLPage = HTMLPage(
                title: "Signup",
                desc: "Signup to find your true love!",
                alert: (alertType, err),
                content: &"""
                    <form action="/login" method="post">
                        <div class="form-group">
                            <label for="name">Full name:</label>
                            <input
                                type="text"
                                name="name"
                                placeholder="Mike Kabumba"
                                id="name"
                                required
                                class="form-control"
                            />
                        </div>
                        <div class="form-group">
                            <label for="email">Email:</label>
                            <input
                                type="email"
                                name="email"
                                placeholder="jack@gmail.com"
                                id="email"
                                required
                                class="form-control"
                            />
                        </div>
                        <div class="form-group">
                            <label for="passwd">Password:</label>
                            <input
                                type="password"
                                name="password"
                                id="passwd"
                                required
                                class="form-control"
                    minlength="8"
                            />
                        </div>
                        <button type="submit" class="btn btn-primary">Signup</button>
                    </form>
                """,
            )

        resp generateHTML(data)
    else:
        resp "<h1>404! (Unknown request)!</h1>"

const routes* = @[
    # NOTE: routes has to be GC-safe!
    pattern("", index, @[HttpGet]),
    pattern("login", login, @[HttpGet, HttpPost]),
    pattern("signup", signup, @[HttpGet]),
]
