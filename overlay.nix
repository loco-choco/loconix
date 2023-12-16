final: prev: {
  ltspice = final.pkgs.callPackage ./ltspice {
    inherit final.pkgs.mkWindowsApp final.pkgs.makeDesktopIcon final.pkgs.copyDesktopIcons;
    wine = final.pkgs.wineWowPackages.full;
  };
  ucenter = final.pkgs.callPackage ./ucenter {
    inherit final.pkgs.mkWindowsApp final.pkgs.makeDesktopIcon final.pkgs.copyDesktopIcons;
    wine = final.pkgs.wineWowPackages.full;
  };
}
