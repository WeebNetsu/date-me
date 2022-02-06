import prologue, strformat, options, allographer/query_builder
import ./generalUse

from ../db/db import rdb

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
    let 
        pageTitle: string = "Login"
        pageDesc: string = "Login to find your true love!"
        pageHTML: string = &"""
			<form action="/" method="post">
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
					/>
				</div>
				<div class="form-group">
					<button type="submit" class="btn btn-primary">Login</button>
				</div>
				<div class="form-group">
					<label>Don't have an account?</label>
					<button type="button" class="btn btn-link">
						<a href="/signup">Signup</a>
					</button>
				</div>
			</form>
        """

    if ctx.request.reqMethod == HttpGet:
        let data: HTMLPage = HTMLPage(
                title: pageTitle,
                desc: pageDesc,
                content: pageHTML,
            )

        resp generateHTML(data)
    elif ctx.request.reqMethod == HttpPost:
        let frmUserName: Option[string] = ctx.getFormItem("name")
        let frmEmail: Option[string] = ctx.getFormItem("email")
        let frmPassword: Option[string] = ctx.getFormItem("password")

        if not (isSome(frmUserName) and isSome(frmEmail) and isSome(frmPassword)):
            resp redirect(generateRedirect("/signup", [("error", "Could not get form data")]))
            return

        let userExits = await rdb.table("users").find(get(frmEmail), "email")

        if isSome(userExits):
            resp redirect(generateRedirect("/signup", [("error", "Email already exits")]))
            return

        try:
            await rdb.table("users").insert(%*{
                "fullName": get(frmUserName),
                "email": get(frmEmail),
                "password": get(frmPassword),
            })
        except Exception as e:
            echo e.msg
            resp redirect(generateRedirect("/signup", [("error", "Could not create account")]))
            return

        let data: HTMLPage = HTMLPage(
                title: pageTitle,
                desc: pageDesc,
                alert: (alert: AlertType.SUCCESS, msg: "Account created! Login to find your true love"),
                content: pageHTML,
            )

        resp generateHTML(data)
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
                                maxlength="99"
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
                        <div class="form-group">
                            <button type="submit" class="btn btn-primary">Signup</button>
                        </div>
                        <div class="form-group">
                            <label>Already have an account?</label>
                            <button type="button" class="btn btn-link"><a href="/login">Login</a></button>
                        </div>
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
