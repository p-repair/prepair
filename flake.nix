{
  description = "(p)repair";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devshell.flakeModule ];
      systems = [ "x86_64-linux" ];

      perSystem = { self', system, ... }:
        let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        in
        {
          devshells.default = {
            name = "(p)repair";

            motd = ''

              {202}🔨 Welcome to the (p)repair devshell!{reset}
              $(type -p menu &>/dev/null && menu)
            '';

            packages = with pkgs; [
              # Build toolchain.
              beam.packages.erlang_26.elixir_1_16
              gcc
              gnumake

              # Project dependencies.
              postgresql_15

              # Development dependencies.
              inotify-tools
              libnotify

              # IDE toolchain.
              nil
              nixpkgs-fmt

              # Tools.
              flyctl
              git
              gitAndTools.gitflow
            ];

            env = [
              { name = "PGDATA"; eval = "$PWD/db"; }
            ];

            commands = [
              {
                name = "gitsetup";
                help = "Configures git-flow in the local repo";
                command = builtins.readFile ./scripts/gitsetup;
              }

              {
                name = "setup";
                help = "Compiles the application, and sets the database up";
                command = builtins.readFile ./scripts/setup;
              }

              {
                name = "start-db";
                help = "Starts a local instance of PostgreSQL";
                command = builtins.readFile ./scripts/start-db;
              }

              {
                name = "stop-db";
                help = "Stops the local instance of PostgreSQL";
                command = builtins.readFile ./scripts/stop-db;
              }

              {
                name = "build-docker";
                help = "Builds the docker image";
                command = builtins.readFile ./scripts/build-docker;
              }

              {
                name = "run-docker";
                help = "Runs the docker image using the development DB";
                command = builtins.readFile ./scripts/run-docker;
              }
            ];
          };
        };
    };
}
