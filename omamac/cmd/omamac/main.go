// Command omamac bootstraps and configures a complete macOS development
// environment. See https://github.com/irfancode/omamac for documentation.
package main

import (
	"os"

	"github.com/irfancode/omamac/internal/cli"
)

func main() {
	os.Exit(cli.Execute())
}
