{
  description = "A Nix flake for some Windows apps";
  inputs = {
    erosanix.url = "github:emmanuelrosa/erosanix";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };
  outputs = { self, flake-utils, flake-compat, erosanix, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
      erosanix-lib-overlay = final: prev: {
        mkWindowsApp = erosanix.lib.${system}.mkWindowsApp;
        makeDesktopIcon = erosanix.lib.${system}.makeDesktopIcon;
        copyDesktopIcons = erosanix.lib.${system}.copyDesktopIcons;
      };
        pkgs = (import nixpkgs) {
          inherit system;
	  overlays = [ self.overlay.wineApps erosanix-lib-overlay];
	};
      in rec {
        packages = rec {
          ltspice = pkgs.ltspice;
          ucenter = pkgs.ucenter;
	  default = pkgs.ltspice;
	};
      }
    ) // {
      overlay.wineApps = import ./overlay.nix;
    };
}
