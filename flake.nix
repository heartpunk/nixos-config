{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.3-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # claude-squad PR branch until it merges
    nixpkgs-claude-squad = {
      url = "github:benjaminkitt/nixpkgs?ref=add-claude-squad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, lix-module, nixpkgs-claude-squad, ... }:
    let
      system = "x86_64-linux";

      # Overlay that adds claude-squad or throws if already in nixpkgs
      overlay = final: prev:
        if builtins.hasAttr "claude-squad" prev
        then builtins.throw ''
               ❌  claude-squad is now in upstream nixpkgs.
                   Delete the nixpkgs-claude-squad input + this overlay.
             ''
        else {
          claude-squad = nixpkgs-claude-squad.legacyPackages.${system}.claude-squad;
        };

      pkgs = import nixpkgs { inherit system; overlays = [ overlay ]; };
    in
    {
      nixosConfigurations.heartpunk = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          # stop using lix until it builds!
          # lix-module.nixosModules.default

          # Apply the overlay to the system
          ({ ... }: {
            nixpkgs.overlays = [ overlay ];
          })
        ];
      };
    };
}
