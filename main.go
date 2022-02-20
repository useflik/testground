package main

import (
	"net/http"

	"testground/config"

	"github.com/gin-gonic/gin"
)

func main() {

	conf := config.GetConfig()

	router := gin.Default()
	router.LoadHTMLGlob("templates/*")
	router.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.tmpl", gin.H{
			"PageTitle": conf.PageTitle,
			"PageDesc":  conf.PageDesc,
			"PageEnv":   conf.AppEnv,
		})
	})

	router.Run(":8080")
}
