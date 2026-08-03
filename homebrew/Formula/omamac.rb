# Homebrew tap formula for omamac.
# Released automatically by GitHub Actions via goreleaser.
# Docs: https://docs.brew.sh/Formula-Cookbook

class Omamac < Formula
  desc "Opinionated macOS developer workstation bootstrapper inspired by Omakub"
  homepage "https://github.com/irfancode/omamac"
  version "0.1.0"

  if Hardware::CPU.arm?
    url "https://github.com/irfancode/omamac/releases/download/v0.1.0/omamac_0.1.0_darwin_arm64.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  else
    url "https://github.com/irfancode/omamac/releases/download/v0.1.0/omamac_0.1.0_darwin_amd64.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  end

  depends_on :macos

  def install
    bin.install "omamac"
  end

  test do
    system "#{bin}/omamac", "version"
  end
end
