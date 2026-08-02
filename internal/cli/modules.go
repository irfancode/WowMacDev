package cli

import (
	"github.com/omamac/omamac/internal/module"
	aimodule "github.com/omamac/omamac/modules/ai"
	appsmodule "github.com/omamac/omamac/modules/apps"
	cleanmodule "github.com/omamac/omamac/modules/cleanup"
	dockermodule "github.com/omamac/omamac/modules/docker"
	dotfilesmodule "github.com/omamac/omamac/modules/dotfiles"
	fontsmodule "github.com/omamac/omamac/modules/fonts"
	gitmodule "github.com/omamac/omamac/modules/git"
	golangmodule "github.com/omamac/omamac/modules/golang"
	homebrewmodule "github.com/omamac/omamac/modules/homebrew"
	javamodule "github.com/omamac/omamac/modules/java"
	macosmodule "github.com/omamac/omamac/modules/macos"
	nodemodule "github.com/omamac/omamac/modules/node"
	productivitymodule "github.com/omamac/omamac/modules/productivity"
	pythonmodule "github.com/omamac/omamac/modules/python"
	rustmodule "github.com/omamac/omamac/modules/rust"
	shellmodule "github.com/omamac/omamac/modules/shell"
	terminalmodule "github.com/omamac/omamac/modules/terminal"
	toolsmodule "github.com/omamac/omamac/modules/tools"
	vscodemodule "github.com/omamac/omamac/modules/vscode"
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
