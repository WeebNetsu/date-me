package routes

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

type AlertType int
type Dong int

const (
	NONE AlertType = iota
	ERROR
	INFO
	SUCCESS
)

const (
	HAS_DONG Dong = iota
	NO_DONG
	NEITHER
)

type UserModel struct {
	ID             string `json:"_id"`
	FullName       string `json:"fullName"`
	Password       string `json:"password"`
	Email          string `json:"email"`
	ProfilePicture string `json:"profilePicture"`
	Description    string `json:"description"`
	Likes          string `json:"likes"`
	HasDong        Dong   `json:"hasDong"`
}

type ProfileModal struct {
	FullName       string
	ProfilePicture string
	Description    string
	Likes          []string
	HasDong        string
	Colors         [5]string
}

type HTMLPage struct {
	Title   string
	Desc    string
	Content string
	Data    ProfileModal
	// queries StringTableRef
}

var db []UserModel

func HandleIndexPage(c *gin.Context) {
	db = append(db, UserModel{
		ID:             "2dasdas",
		FullName:       "Jack Mike",
		Password:       "password",
		Email:          "jack@gmail.com",
		ProfilePicture: "",
		Description:    "I am cool",
		Likes:          "food,games,tv",
		HasDong:        NO_DONG,
	})

	dong := "Neither"
	likes := strings.Split(db[0].Likes, ",") // todo: limit to only 5

	if db[0].HasDong == NO_DONG {
		dong = "No"
	} else if db[0].HasDong == HAS_DONG {
		dong = "Yes"
	}

	user := ProfileModal{
		FullName:       db[0].FullName,
		ProfilePicture: db[0].ProfilePicture,
		Description:    db[0].Description,
		Likes:          likes,
		HasDong:        dong,
		Colors:         [5]string{"primary", "success", "info", "danger", "warning"},
	}

	page := HTMLPage{
		Title:   "Date Me",
		Desc:    "Find your locer",
		Content: "index.html",
		Data:    user,
	}

	if c.Request.Method == "GET" {
		// c.HTML(http.StatusOK, "index.html", gin.H{
		// 	"Title": "Test Title",
		// })

		// user := db[0]

		c.HTML(http.StatusOK, "index.html", page)
	} else if c.Request.Method == "POST" {

	} else {
		c.String(401, "Request not allowed")
	}
	/* if ctx.request.reqMethod == HttpGet:
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
	       resp "<h1>404! (Unknown request)!</h1>" */

	// c.String(http.StatusOK, "pong")
	// page := IndexPage{Title: "How to catch fish", Body: "Catching fish is pretty simple, you just buy some worms..."}

}
