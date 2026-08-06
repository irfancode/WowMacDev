package cli

import (
	"github.com/irfancode/omamac/internal/module"
	aimodule "github.com/irfancode/omamac/modules/ai"
	appsmodule "github.com/irfancode/omamac/modules/apps"
	cleanmodule "github.com/irfancode/omamac/modules/cleanup"
	dockermodule "github.com/irfancode/omamac/modules/docker"
	dotfilesmodule "github.com/irfancode/omamac/modules/dotfiles"
	fontsmodule "github.com/irfancode/omamac/modules/fonts"
	gitmodule "github.com/irfancode/omamac/modules/git"
	golangmodule "github.com/irfancode/omamac/modules/golang"
	homebrewmodule "github.com/irfancode/omamac/modules/homebrew"
	javamodule "github.com/irfancode/omamac/modules/java"
	macosmodule "github.com/irfancode/omamac/modules/macos"
	nodemodule "github.com/irfancode/omamac/modules/node"
	productivitymodule "github.com/irfancode/omamac/modules/productivity"
	pythonmodule "github.com/irfancode/omamac/modules/python"
	rustmodule "github.com/irfancode/omamac/modules/rust"
	shellmodule "github.com/irfancode/omamac/modules/shell"
	terminalmodule "github.com/irfancode/omamac/modules/terminal"
	toolsmodule "github.com/irfancode/omamac/modules/tools"
	vscodemodule "github.com/irfancode/omamac/modules/vscode"
)

// registerModules registers every built-in module. Built-ins are compiled in
// (typed, testable); third-party capabilities are loaded as plugins at
// runtime. New modules are added here as they land.
func registerModules(reg *module.Registry) {
	reg.RegisterAll(
		&homebrewmodule.Module{},
		&shellmodule.Module{},
		&toolsmodule.Module{},
		&gitmodule.Module{},
		&fontsmodule.Module{},
		&appsmodule.Module{},
		&productivitymodule.Module{},
		&terminalmodule.Module{},
		&vscodemodule.Module{},
		&aimodule.Module{},
		&nodemodule.Module{},
		&pythonmodule.Module{},
		&golangmodule.Module{},
		&rustmodule.Module{},
		&javamodule.Module{},
		&dockermodule.Module{},
		&dotfilesmodule.Module{},
		&macosmodule.Module{},
		&cleanmodule.Module{},
	)
}
