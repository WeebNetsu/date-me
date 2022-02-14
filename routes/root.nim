import prologue, strformat, options, allographer/query_builder, strutils, strtabs
import ./generalUse

from ../db/db import rdb

proc index(ctx: Context) {. async, gcsafe .} =
    # currently the index page shows the users own data instead of other users data
    # todo: move displaying user data to profile page, replace below with data of other users
    if ctx.request.reqMethod == HttpGet:
        try:
            # try to get user in DB, if their userID does not exist in the session a KeyError will be thrown
            # and they will be redirected to the login page
            let userDetails = await rdb.table("users").find(parseInt(ctx.session["userId"]), "id")

            # check if the db returned anything, if not, return to login page
            if not isSome(userDetails):
                resp redirect(generateRedirect("/login", [("error", "Could not find your user... Try logging in again")]))
                return

            let
                user = parseJson($get(userDetails)) # get user
                likes: seq[string] = getStr(user["likes"]).split(',') # get user likes and convert it to an sequence
                likeColors: array[5, string] = ["primary", "success", "info", "danger", "warning"]

            var hasDong: string
            
            if getStr(user["hasDong"]) == "no": 
                hasDong = "No Dong"
            elif getStr(user["hasDong"]) == "yes":
                hasDong = "Has Dong"
            else:
                hasDong = "Unknown"

            var badges = ""
            for index, like in likes:
                # only 5 likes/hobbies are allowed at a time
                if index >= 5:
                    break

                badges &= &"""<span class="badge badge-pill badge-{likeColors[index]}">{like}</span> """
            
            let pageHTML: string = &"""
                <div class="row">
                    <div class="row">
                        <div class="col-md-6">
                            <img
                                src="{getStr(user["profilePicture"])}"
                                alt="{getStr(user["fullName"])}"
                                class="rounded img-fluid"
                            />
                        </div>
                        <div class="col-md-6">
                            <div class="row">
                                <h2>{getStr(user["fullName"])}</h2>
                                <p><span class="badge badge-secondary">{hasDong}</span></p>
                                <div class="badges">
                                    {badges}
                                </div>
                                <p>
                                    {getStr(user["description"])}
                                </p>
                            </div>

                            <div class="row">
                                <div class="col">
                                    <a href="/"
                                        ><button class="btn btn-success btn-block">I like</button>
                                    </a>
                                </div>
                                <div class="col">
                                    <a href="/"
                                        ><button class="btn btn-danger btn-block">Skip</button>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            """

            let data: HTMLPage = HTMLPage(
                title: "Love",
                desc: "Find your true love!",
                content: pageHTML,
            )

            resp generateHTML(ctx, data)
        except KeyError:
            # this error can be triggered by a lot of item in the above code
            resp redirect(generateRedirect("/login", [("error", "Please log in to start dating")]))
            return
        except:
            resp redirect(generateRedirect("/login", [("error", "Unknown error occured, please log in again")]))
            return
    elif ctx.request.reqMethod == HttpPost:
        let frmEmail: Option[string] = ctx.getFormItem("email")
        let frmPassword: Option[string] = ctx.getFormItem("password")

        if not (isSome(frmEmail) and isSome(frmPassword)):
            resp redirect(generateRedirect("/login", [("error", "Login details are incorrect")]))
            return

        let userDetails = await rdb.table("users").find(get(frmEmail), "email")
        if not isSome(userDetails):
            resp redirect(generateRedirect("/login", [("error", "Login details are incorrect")]))
            return

        let user = parseJson($get(userDetails))
        if get(frmPassword) != user["password"].getStr():
            resp redirect(generateRedirect("/login", [("error", "Login details are incorrect")]))
            return

        ctx.session["userId"] = $(user["id"].getInt())
        resp redirect(generateRedirect("/", []))
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
                # get queries passed in (eg. ?error=some+error)
                queries: ctx.request.queryParams,
                content: pageHTML,
            )

        resp generateHTML(ctx, data)
    elif ctx.request.reqMethod == HttpPost: # if post method, then the user is busy signing up
        # get form data
        let frmUserName: Option[string] = ctx.getFormItem("name")
        let frmEmail: Option[string] = ctx.getFormItem("email")
        let frmPassword: Option[string] = ctx.getFormItem("password")

        # if they somehow submitted the form without filling out all the fields, return to signup
        if not (isSome(frmUserName) and isSome(frmEmail) and isSome(frmPassword)):
            resp redirect(generateRedirect("/signup", [("error", "Could not get form data")]))
            return

        let userExits = await rdb.table("users").find(get(frmEmail), "email")

        # check if user account already exists
        if isSome(userExits):
            resp redirect(generateRedirect("/signup", [("error", "Email already exits")]))
            return

        try:
            # add user to database
            await rdb.table("users").insert(%*{
                "fullName": get(frmUserName),
                "email": get(frmEmail),
                "password": get(frmPassword),
                "hasDong": "unknown",
            })
        except Exception as e:
            echo e.msg
            resp redirect(generateRedirect("/signup", [("error", "Could not create account")]))
            return

        resp redirect(generateRedirect("/login", [("success", "Account created! Login to find your true love")]))
    else:
        resp "<h1>404! (Unknown request)!</h1>"

proc signup(ctx: Context) {. async, gcsafe .} =
    if ctx.request.reqMethod == HttpGet:
        let data: HTMLPage = HTMLPage(
                title: "Signup",
                desc: "Signup to find your true love!",
                queries: ctx.request.queryParams,
                content: &"""
                    <form action="/login" method="post">
                        <div class="form-group">
                            <label for="name">Full name (cannot be changed later):</label>
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

        resp generateHTML(ctx, data)
    else:
        resp "<h1>404! (Unknown request)!</h1>"

const routes* = @[
    pattern("", index, @[HttpGet, HttpPost]),
    pattern("login", login, @[HttpGet, HttpPost]),
    pattern("signup", signup, @[HttpGet]),
]
