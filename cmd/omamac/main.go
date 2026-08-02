// Command omamac bootstraps and configures a complete macOS development
// environment. See https://omamac.dev for documentation.
package main

import (
	"os"

	"github.com/omamac/omamac/internal/cli"
)

func main() {
	os.Exit(cli.Execute())
}
