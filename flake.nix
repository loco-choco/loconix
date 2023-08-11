{
  description = "A Nix flake for some Windows apps";

  inputs.erosanix.url = "github:emmanuelrosa/erosanix";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";

  outputs = { self, nixpkgs, erosanix }: {

    packages.x86_64-linux = let
      pkgs = import "${nixpkgs}" {
        system = "x86_64-linux";
      };

    in with (pkgs // erosanix.packages.x86_64-linux // erosanix.lib.x86_64-linux); {
      default = self.packages.x86_64-linux.ltspice;

       ucenter = callPackage ./ucenter/default.nix {
        inherit mkWindowsApp makeDesktopIcon copyDesktopIcons;
        wine = wineWowPackages.full;
      };    

      ltspice = callPackage ./ltspice/default.nix {
        inherit mkWindowsApp makeDesktopIcon copyDesktopIcons;
        wine = wineWowPackages.full;
      };
    };

    apps.x86_64-linux.ltspice = {
      type = "app";
      program = "${self.packages.x86_64-linux.ltspice}/bin/ltspice";
    };

    apps.x86_64-linux.ucenter = {
      type = "app";
      program = "${self.packages.x86_64-linux.ucenter}/bin/ucenter";
    };

    apps.x86_64-linux.default = self.apps.x86_64-linux.ltspice;
  };
}
