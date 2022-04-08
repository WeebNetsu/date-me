package routes

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type AlertType int

const (
	NONE AlertType = iota
	ERROR
	INFO
	SUCCESS
)

type HTMLPage struct {
	Title   string
	Desc    string
	Content string
	// queries StringTableRef
}

func HandleIndexPage(c *gin.Context) {
	// c.String(http.StatusOK, "pong")
	// page := IndexPage{Title: "How to catch fish", Body: "Catching fish is pretty simple, you just buy some worms..."}
	page := HTMLPage{
		Title:   "Date Me",
		Desc:    "Find your locer",
		Content: "index.html",
	}

	// c.HTML(http.StatusOK, "index.html", gin.H{
	// 	"Title": "Test Title",
	// })

	c.HTML(http.StatusOK, "index.html", page)
}
