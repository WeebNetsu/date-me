import strformat, options, prologue

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

proc generateHTML*(data: HTMLPage): string =
    var alert: string
    var alertVer: string = "danger"
    let alertType = data.alert.alert

    if alertType == AlertType.ERROR:
        alertVer = "danger"
    elif  alertType == AlertType.INFO:
        alertVer = "info"
    elif  alertType == AlertType.SUCCESS:
        alertVer = "success"

    if alertType != AlertType.NONE:
        alert = &"""
            <div class="alert alert-{alertVer}">
                <strong>Error!</strong> {data.alert.msg}.
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
                    {alert}

                    {data.content}
                </div>
            </body>
        </html>
    """

proc getFormItem*(ctx: Context, item: string): Option[string] =
    try:
        let data: string = ctx.request.formParams.data[item].body
        return some(data)
    except KeyError:
        return none(string)

proc getQueryFromUrl*(ctx: Context, query: string): Option[string] or Option[int] =
    try:
        let data: string = ctx.request.queryParams[query]
        return some(data)
    except KeyError:
        return none(string)