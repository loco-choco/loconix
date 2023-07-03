{ stdenv
, lib
, mkWindowsApp
, wine
, fetchurl
, makeDesktopItem
, makeDesktopIcon   # This comes with erosanix. It's a handy way to generate desktop icons.
, copyDesktopItems
, copyDesktopIcons  # This comes with erosanix. It's a handy way to generate desktop icons.
}: let
  # The default settings used if user doesn't already have a settings file.
  # Tabs are disabled because they lead to UI issues when using Wine.
  #defaultSettings = ./SumatraPDF-settings.txt;

  # This registry file sets winebrowser (xdg-open) as the default handler for
  # text files, instead of Wine's notepad.
  # Selecting "Settings -> Advanced Options" should then use xdg-open to open the SumatraPDF config file.
  #txtReg = ./txt.reg;
  hideDocuments = ''
    rm $WINEPREFIX/drive_c/users/$USER/Documents
    mkdir $WINEPREFIX/drive_c/users/$USER/Documents
  '';
  hideDesktop = ''
    rm $WINEPREFIX/drive_c/users/$USER/Desktop
    mkdir $WINEPREFIX/drive_c/users/$USER/Desktop
  '';
in mkWindowsApp rec {
  inherit wine;

  pname = "ltspice";
  version = "XVII";

  src = fetchurl {
    url = "https://ltspice.analog.com/software/LTspice64.exe";
    sha256 = "sha256-UwbfmJiedUydlfNlTbG/Z1rWeqVhvnXmapIvwLCZe1M=";
  };

  # In most cases, you'll either be using an .exe or .zip as the src.
  # Even in the case of a .zip, you probably want to unpack with the launcher script.
  dontUnpack = true;

  # You need to set the WINEARCH, which can be either "win32" or "win64".
  # Note that the wine package you choose must be compatible with the Wine architecture.
  wineArch = "win64";

  # Sometimes it can take a while to install an application to generate an app layer.
  # `enableInstallNotification`, which is set to true by default, uses notify-send
  # to generate a system notification so that the user is aware that something is happening.
  # There are two notifications: one before the app installation and one after.
  # The notification will attempt to use the app's icon, if it can find it. And will fallback
  # to hard-coded icons if needed.
  # If an app installs quickly, these notifications can actually be distracting.
  # In such a case, it's better to set this option to false.
  # This package doesn't benefit from the notifications, but I've explicitly enabled them
  # for demonstration purposes.
  enableInstallNotification = true;

  # `fileMap` can be used to set up automatic symlinks to files which need to be persisted.
  # The attribute name is the source path and the value is the path within the $WINEPREFIX.
  # But note that you must ommit $WINEPREFIX from the path.
  # To figure out what needs to be persisted, take at look at $(dirname $WINEPREFIX)/upper,
  # while the app is running.
  fileMap = { "$HOME/.config/${pname}/lib" = "drive_c/users/$USER/Documents/LTspiceXVII/lib"; };

  # By default, `fileMap` is applied right before running the app and is cleaned up after the app terminates. If the following option is set to "true", then `fileMap` is also applied prior to `winAppInstall`. This is set to "false" by default.
  fileMapDuringAppInstall = false;

  # By default `mkWindowsApp` doesn't persist registry changes made during runtime. Therefore, if an app uses the registry then set this to "true". The registry files are saved to `$HOME/.local/share/mkWindowsApp/$pname/`.
  persistRegistry = false;

  # By default mkWindowsApp creates ephemeral (temporary) WINEPREFIX(es). 
  # Setting persistRuntimeLayer to true causes mkWindowsApp to retain the WINEPREFIX, for the short term. 
  # This option is designed for apps which can't have their automatic updates disabled.
  # It allows package maintainers to not have to constantly update their mkWindowsApp packages.
  # It is NOT meant for long-term persistance; If the Windows or App layers change, the Runtime layer will be discarded.
  persistRuntimeLayer = false;

  # The method used to calculate the input hashes for the layers.
  # This should be set to "store-path", which is the strictest and most reproduceable method. But it results in many rebuilds of the layers since the slightest change to the package inputs will change the input hashes.
  # An alternative is "version" which is a relaxed method and results in fewer rebuilds but is less reproduceable. If you are considering using "version", contact me first. There may be a better way.
  inputHashMethod = "store-path";

  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  # This code will become part of the launcher script.
  # It will execute if the application needs to be installed,
  # which would happen either if the needed app layer doesn't exist,
  # or for some reason the needed Windows layer is missing, which would
  # invalidate the app layer.
  # WINEPREFIX, WINEARCH, AND WINEDLLOVERRIDES are set
  # and wine, winetricks, and cabextract are in the environment.
  winAppInstall = ''
    ${hideDocuments}
    ${hideDesktop}
    $WINE ${src}
  '';


  # This code runs before winAppRun, but only for the first instance.
  # Therefore, if the app is already running, winAppRun will not execute.
  # Use this to do any setup prior to running the app.
  winAppPreRun = ''
  '';

  # This code will become part of the launcher script.
  # It will execute after winAppInstall and winAppPreRun (if needed),
  # to run the application.
  # WINEPREFIX, WINEARCH, AND WINEDLLOVERRIDES are set
  # and wine, winetricks, and cabextract are in the environment.
  # Command line arguments are in $ARGS, not $@
  # DO NOT BLOCK. For example, don't run: wineserver -w
  winAppRun = ''
    $WINE "$WINEPREFIX/drive_c/Program Files/LTC/LTspiceXVII/XVIIx64.exe"
  '';

  # This code will run after winAppRun, but only for the first instance.
  # Therefore, if the app was already running, winAppPostRun will not execute.
  # In other words, winAppPostRun is only executed if winAppPreRun is executed.
  # Use this to do any cleanup after the app has terminated
  winAppPostRun = "";

  # This is a normal mkDerivation installPhase, with some caveats.
  # The launcher script will be installed at $out/bin/.launcher
  # DO NOT DELETE OR RENAME the launcher. Instead, link to it as shown.
  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/${pname}

    runHook postInstall
  '';

  desktopItems = let
    mimeTypes = [ ];
  in [
    (makeDesktopItem {
      inherit mimeTypes;

      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "LTspice XVII";
      genericName = "SPICE Simulator";
      categories = ["Simulation"];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = "ltspicexvii";
    src = ./ltspice-icon.png;
  };

  meta = with lib; {
    description = "SPICE simulator software from Analog Devices.";
    homepage = "https://www.analog.com/en/design-center/design-tools-and-calculators/ltspice-simulator.html";
    license = licenses.unfree;
    maintainers = with maintainers; [ loco-choco ];
    platforms = [ "x86_64-linux" ];
  };
}


