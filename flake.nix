{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
  };
  outputs =
    {
      nixpkgs,
      flake-utils,
      neovim-nightly-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        nightlyPkgs = import nixpkgs {
          inherit system;
          overlays = [
            # The overlay's CI pushes `checks` (not `packages`) to nix-community.cachix.org.
            (_: _: { neovim-unwrapped = neovim-nightly-overlay.checks.${system}.neovim; })
          ];
        };
        packagesFor =
          p: with p; [
            git
            stylua
            selene
            just
            neovim
            lua-language-server
            lua51Packages.nlua
            lua51Packages.busted
          ];
      in
      {
        devShells.default = pkgs.mkShell {
          name = "backend-template";
          packages = packagesFor pkgs;
        };
        devShells.ci = pkgs.mkShell {
          name = "ci";
          packages = packagesFor pkgs;
        };
        devShells.ci-nightly = nightlyPkgs.mkShell {
          name = "ci-nightly";
          packages = packagesFor nightlyPkgs;
        };
      }
    );
}
