package application

import (
	"github.com/labstack/echo/v4"
	"github.com/stratocraft/stratocraft.dev/internal/views/components/pages"
)

func (a *Application) Contact(c echo.Context) error {
	return pages.Contact().Render(c.Request().Context(), c.Response().Writer)
}
