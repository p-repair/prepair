{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  inherit (lib) optional optionals;
  gitflow = gitAndTools.gitflow;
in

mkShell {
  buildInputs = [ elixir_1_14 git gitflow postgresql_15 flyctl ]
    ++ optional stdenv.isLinux libnotify # For ExUnit Notifier on Linux.
    ++ optional stdenv.isLinux inotify-tools # For file_system on Linux.
    ++ optional stdenv.isDarwin terminal-notifier # For ExUnit Notifier on macOS.
    ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
    # For file_system on macOS.
    CoreFoundation
    CoreServices
  ]);

  shellHook = ''
    export PGDATA="$PWD/db"
  '';
}
