{
  inputs = {
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.3-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, lix-module, ... }: {
    nixosConfigurations.heartpunk = nixpkgs.lib.nixosSystem {
      system = "x86-64-linux";
      modules = [
        ./configuration.nix
        # stop using lix until it builds!
        # lix-module.nixosModules.default
      ];
    };
  };
}
