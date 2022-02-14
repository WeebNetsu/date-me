import prologue, strformat, options, allographer/query_builder, strutils
import ./generalUse

from ../db/db import rdb

proc profile(ctx: Context) {. async, gcsafe .} =
    const PROFILE_URL: string = "/user/profile"

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
                likePlaceholders: array[5, string] = ["anime", "sports", "movies", "gaming", "drinking"]
                hasDong: string = getStr(user["hasDong"])

            var 
                hasDongOptions = {"hasDong": (if hasDong == "yes": "selected" else: ""), "noDong": (if hasDong == "no": "selected" else: ""), "unknown": (if hasDong == "unknown": "selected" else: "")}.toTable()
                badges: string

            for index in 0 .. 4:
                try:
                    badges &= &"""
                        <div class="col">
                            <input
                                type="text"
                                class="form-control"
                                minlength="3"
                                maxlength="10"
                                placeholder="{likePlaceholders[index]}"
                                value="{likes[index]}"
                                name="like{index}"
                            />
                        </div>
                    """
                except KeyError:
                    badges &= &"""
                        <div class="col">
                            <input
                                type="text"
                                class="form-control"
                                minlength="3"
                                maxlength="10"
                                placeholder="Fishing"
                                name="like{index}"
                            />
                        </div>
                    """
            
            let pageHTML: string = &"""
                <form method="post">
                    <div class="row">
                        <div class="col-lg">
                            <h2>{getStr(user["fullName"])}</h2>
                        </div>

                        <div class="col-lg">
                             <div class="form-group">
                                <select class="form-control" name="hasDong">
                                    <option value="yes" {hasDongOptions["hasDong"]}>Has Dong</option>
                                    <option value="no" {hasDongOptions["noDong"]}>No Dong</option>
                                    <option value="unknown" {hasDongOptions["unknown"]}>Not Specifying</option>
                                </select>
                            </div>
                        </div>

                        <div class="col-lg">
                            <button type="submit" class="btn btn-outline-primary float-right">Save</button>
                        </div>
                    </div>

                    <div class="row">
                        <label>Your 5 Hobbies</label>
                        <div class="row">
                            {badges}
                        </div>
                    </div>

                    <br />

                    <div class="row">
                        <div class="col-md-6">
                            <label>Your Profile Photo</label>
                            <img
                                src="{getStr(user["profilePicture"])}"
                                alt="Your profile image could not be loaded."
                                class="rounded img-fluid"
                            />
                        </div>
                        <div class="col-md-6">
                            <label for="userDescription">Your description</label>
                            <textarea
                                class="form-control"
                                name="userDescription"
                                id="userdescription"
                                style="width: 100%; height: 100%"
                                maxlength="500"
                                placeholder="I like to fish, and you'll find no one else quite like me..."
                            >{getStr(user["description"])}</textarea>
                        </div>
                    </div>
                </form>
            """

            let data: HTMLPage = HTMLPage(
                title: "Profile",
                desc: "Your profile",
                content: pageHTML,
                queries: ctx.request.queryParams,
            )

            resp generateHTML(ctx, data)
        except KeyError:
            # this error can be triggered by a lot of item in the above code
            resp redirect(generateRedirect("/login", [("error", "Account not found. Please log in to start dating")]))
            return
        except:
            resp redirect(generateRedirect("/login", [("error", "Unknown error occured, please log in again")]))
            return
    elif ctx.request.reqMethod == HttpPost:
        let frmHasDong: Option[string] = ctx.getFormItem("hasDong")
        let frmDescription: Option[string] = ctx.getFormItem("userDescription")
        let frmLikes: array[5, string] = [get(ctx.getFormItem("like0")), get(ctx.getFormItem("like1")), get(ctx.getFormItem("like2")), get(ctx.getFormItem("like3")), get(ctx.getFormItem("like4"))]


        # this should always contain a value!
        if not isSome(frmHasDong):
            resp redirect(generateRedirect(PROFILE_URL, [("error", "Could not get all form data")]))
            return

        try:
            await rdb.table("users").update(%*{
                "hasDong": get(frmHasDong),
                "description": get(frmDescription),
                "likes": frmLikes.join(",")
            })
        except Exception as e:
            echo e.msg
            resp redirect(generateRedirect(PROFILE_URL, [("error", "Could not update account")]))
            return
        
        resp redirect(generateRedirect(PROFILE_URL, [("success", "Profile updated")]))
    else:
        resp redirect(generateRedirect("/login", [("error", "Request not understood")]))

const routes* = @[
    pattern("profile", profile, @[HttpGet, HttpPost]),
]
