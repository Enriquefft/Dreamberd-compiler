{
  description = "Zig flake for the Dreamberd compiler project.";

  inputs = {

    flakelight.url = "github:nix-community/flakelight";

  };

  outputs = { flakelight, nixpkgs, ... }:
    flakelight ./. {
      inputs.nixpkgs = nixpkgs;
      devShell = pkgs: {

        stdenv = pkgs.llvmPackages_latest.stdenv;

        packages = with pkgs;
          [

            zig

          ];
      };
    };

}
