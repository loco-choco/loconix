This repo contains a random assortment of nix packaged apps.

To run an app run `nix run github:loco-choco/loconix#APPNAME`. The default app is ltspice.

## Garbage Collecting the wine based apps

To garbage collect the wine based apps you need to first run `nix-collect-garbage` and then `nix run github:emmanuelrosa/erosanix#mkwindowsapp-tools`.

## LTSpice

The ltspice version packaged is LTSpice XVII. When run for the first time, an install window will appear, 
just press "accept", don't change the instalation path and keep it at 64 bits. Then it will automatically open a ltspice window,
that window appears because of how the installer was coded, and won't have any configurations/models you separated,
so ignore it and close it. Then a new windows will open, from now on new instances of ltspice will have the correct configs.

The configs can be located at `~/.config/ltspice`. For now only the `lib` folder is available, which is where you should add your custom component models.

## u-center

For some reason you need to have `unzip` on your system to get this installed (even with the derivation having `unzip` in the build inputs), so before running the run command, if you don't have `unzip` on your system, run `nix-shell -p unzip`.
