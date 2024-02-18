{
  description = "Template config using Kalix.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kalix = {
      url = "./..";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs: with inputs;
  let
    specialArgs = { inherit inputs self; };
    system = "x86_64-linux";
  in
  {
    nixosConfigurations = {
      "test" = nixpkgs.lib.nixosSystem {
        inherit specialArgs system;
        modules = [
          ./configuration.nix
          kalix.nixosModule
        ];
      };
    };

    homeConfigurations = {
      "sus@test" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = specialArgs;
          modules = [
            ./home.nix
            kalix.homeManagerModule
          ];
      };
    };
  };
}