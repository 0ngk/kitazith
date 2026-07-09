{
  description = "Development environment for kitazith";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    pkgsFor = system:
      import nixpkgs {
        inherit system;
      };
  in {
    devShells = forAllSystems (system: let
      pkgs = pkgsFor system;

      ci-check = pkgs.writeShellApplication {
        name = "ci-check";
        runtimeInputs = [
          pkgs.bash
          pkgs.coreutils
          pkgs.findutils
          pkgs.git
          pkgs.gleam
          pkgs.beamPackages.erlang
          pkgs.rebar3
          pkgs.nodejs_22
        ];
        text = ''
          bash ./scripts/validate_packages.sh
        '';
      };
    in {
      default = pkgs.mkShell {
        packages = [
          pkgs.bash
          pkgs.coreutils
          pkgs.findutils
          pkgs.git

          pkgs.gleam
          pkgs.beamPackages.erlang
          pkgs.rebar3

          pkgs.nodejs_22

          ci-check
        ];

        shellHook = ''
          echo "kitazith dev shell"
          echo "Commands:"
          echo "  gleam build"
          echo "  gleam test"
          echo "  ci-check"
        '';
      };
    });
  };
}
