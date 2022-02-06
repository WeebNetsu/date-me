import strformat, options, prologue, uri

type
    AlertType* = enum NONE, ERROR, INFO, SUCCESS
    HTMLAlert* = tuple
        alert: AlertType
        msg: string
    HTMLPage* = object
        title*: string
        desc*: string
        content*: string
        alert*: HTMLAlert

#[ generateHTML
    [description]
        Will generate HTML code with required boilerplate
    [parameters]
        data* <HTMLPage> -> Contains HTML content to add to HTML boilerplate
    [example]
        generateHTML(
                title: "Hello World",
                desc: "This page has a description,
                alert: (alert: AlertType.SUCCESS, msg: "Account created! Login to find your true love"),
                content: "<p>I am very cool</p>",
            )
 ]#
proc generateHTML*(ctx: Context, data: HTMLPage): string =
    var 
        alert: string
        alertVer: string = "danger"
        alertCondition: string = "Error"
        navbar: string = ""

    let alertType = data.alert.alert

    if alertType == AlertType.ERROR:
        alertVer = "danger"
        alertCondition = "ERROR"
    elif  alertType == AlertType.INFO:
        alertVer = "info"
        alertCondition = "NOTE"
    elif  alertType == AlertType.SUCCESS:
        alertVer = "success"
        alertCondition = "SUCCESS"

    let login = true
    if login:
        navbar = """
            <div class="row">
				<div class="col">
					<nav class="navbar navbar-expand-sm bg-dark navbar-dark justify-content-center">
						<ul class="navbar-nav">
							<li class="nav-item">
								<a class="nav-link" href="/">Home</a>
							</li>
							<li class="nav-item">
								<a class="nav-link" href="/user/profile">Profile</a>
							</li>
							<li class="nav-item">
								<a class="nav-link" href="/logout">Logout</a>
							</li>
						</ul>
					</nav>
				</div>
			</div>
            <br />
        """

    if alertType != AlertType.NONE:
        alert = &"""
            <div class="alert alert-{alertVer}">
                <strong>{alertCondition}!</strong> {data.alert.msg}.
            </div>
        """
    
    return &"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8" />
            <meta http-equiv="X-UA-Compatible" content="IE=edge" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />

            <!-- Add site description -->
            <meta name="description" content="{data.desc}" />

            <!-- Bootstrap -->
            <link
            rel="stylesheet"
            href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css"
            />
            <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
            <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

            <title>{data.title} - Date Me</title>

            <link rel="shortcut icon" href="icon.png" type="image/x-icon" />
        </head>
            <body>
                <div class="container">
                    {navbar}

                    {alert}

                    {data.content}
                </div>
            </body>
        </html>
    """

#[ getFormItem
    [description]
        Will get data from input on a form
    [parameters]
        ctx* <Context> -> Context to get passed in data
        item <string> -> Field to get
    [example]
        getFormItem(ctx, "email")
        ->
        some("mike@gmail.com")
 ]#
proc getFormItem*(ctx: Context, item: string): Option[string] =
    try:
        let data: string = ctx.request.formParams.data[item].body
        return some(data)
    except KeyError:
        return none(string)

#[ generateRedirect
    [description]
        Will generate a string to redirect the user to an url
    [parameters]
        where* <string> -> Where to redirect to
        params <openArray[(string, string)]> -> Parameters to be passed into url
    [example]
        generateRedirect("/signup", [("name", "Jack"), ("error", "Could not connect to server))])
        ->
        "/signup?name=Jack&error=Could+not+connect+to+server"
 ]#
proc generateRedirect*(where: string, params: openArray[(string, string)]): string =
    return $(parseUri(where) ? params)