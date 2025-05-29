package application

import (
	"github.com/labstack/echo/v4"
	"github.com/stratocraft/stratocraft.dev/internal/views/components/pages"
)

func (a *Application) About(c echo.Context) error {
	return pages.About().Render(c.Request().Context(), c.Response().Writer)
}
