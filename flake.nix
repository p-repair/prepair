{
  description = "(p)repair";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Build toolchain.
            beam.packages.erlang_26.elixir_1_15

            # Project dependencies.
            postgresql_15

            # Development dependencies.
            inotify-tools
            libnotify

            # Tools.
            flyctl
            git
            gitAndTools.gitflow
          ];

          shellHook = ''
            export PGDATA="$PWD/db"
          '';
        };
      });
}
