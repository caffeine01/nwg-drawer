{
  description = "Development environment and package for nwg-drawer";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
  };
  outputs = { self, nixpkgs, systems }: let
    inherit (nixpkgs) lib;
    gitCommitHash = self.rev or "dirty";
    eachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    packages = eachSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.buildGoModule {
        pname = "nwg-drawer";
        version = gitCommitHash;
        src = ./.;
        
        vendorHash = "sha256-Q+2CXpPvfy6QYjP+AZeJL/l00/Z+C56c+FfGcyIdQ4M=";
        
        nativeBuildInputs = with pkgs; [
          gobject-introspection
          pkg-config
          wrapGAppsHook3
        ];

        buildInputs = with pkgs; [
          cairo
          gtk-layer-shell
          gtk3
        ];

        doCheck = false;

        preInstall = ''
          mkdir -p $out/share/nwg-drawer
          cp -r desktop-directories drawer.css $out/share/nwg-drawer
        '';

        preFixup = ''
          # make xdg-open overrideable at runtime
          gappsWrapperArgs+=(
           --suffix PATH : ${pkgs.xdg-utils}/bin
           --prefix XDG_DATA_DIRS : $out/share
          )
        '';

        meta = with lib; {
          description = "Application drawer for wlroots-based Wayland compositors";
          homepage = "https://github.com/nwg-piotr/nwg-drawer";
          license = with lib.licenses; [ mit ];
          mainProgram = "nwg-drawer";
          platforms = with lib.platforms; linux;
        };
      };
    });
    
    devShells = eachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          go
          cairo
          gtk-layer-shell
          gtk3
          gobject-introspection
          pkg-config
          wrapGAppsHook3
        ];
      };
    });
  };
}
