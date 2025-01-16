{
  description = "Development environment and package for nwg-drawer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = { self, nixpkgs, systems, ... }@inputs: let
    inherit (nixpkgs) lib;

    gitCommitHash = self.rev or "dirty";

    eachSystem = lib.genAttrs (import systems);
    pkgsFor = eachSystem (system:
      import nixpkgs {
        system = system;
        overlays = [];
      });
    in {
      packages = eachSystem (system: {
        default = pkgsFor.${system}.buildGoModule {
          pname = "nwg-drawer";
          version = gitCommitHash;

          vendorHash = "sha256-Q+2CXpPvfy6QYjP+AZeJL/l00/Z+C56c+FfGcyIdQ4M=";

          src = ./.;

          allowGoReference = true;

        nativeBuildInputs = with pkgsFor.${system}; [
          pkg-config
          gobject-introspection
          makeWrapper
        ];

        buildInputs = with pkgsFor.${system}; [
          gtk3
          gtk-layer-shell
          librsvg
        ];

        preBuild = ''
          export PKG_CONFIG_PATH="${pkgsFor.${system}.pkg-config}/lib/pkgconfig:$PKG_CONFIG_PATH"
          export LD_LIBRARY_PATH="${pkgsFor.${system}.gtk3}/lib:${pkgsFor.${system}.gtk-layer-shell}/lib:$LD_LIBRARY_PATH"
          export GI_TYPELIB_PATH="${pkgsFor.${system}.gtk3}/lib/girepository-1.0:${pkgsFor.${system}.gtk-layer-shell}/lib/girepository-1.0:$GI_TYPELIB_PATH"
          export GOPATH="$PWD/.go"
          export PATH="$GOPATH/bin:$PATH"
          mkdir -p "$GOPATH"
        '';

        postInstall = ''
          wrapProgram $out/bin/nwg-drawer \
            --prefix LD_LIBRARY_PATH : "${pkgsFor.${system}.gtk3}/lib:${pkgsFor.${system}.gtk-layer-shell}/lib"
        '';

          meta = with lib; {
            description = "Application drawer for wlroots-based Wayland compositors";
            license = licenses.mit;
            platforms = platforms.linux;
          };
        };
      });

      devShells = eachSystem (system: {
        default = pkgsFor.${system}.mkShell {
          name = "nwg-drawer shell";
          buildInputs = with pkgsFor.${system}; [
            go
            gopls
            go-tools
            golangci-lint
            delve
            gtk3
            gtk3-x11
            pkg-config
            gobject-introspection
            cairo
            glib
            gtk-layer-shell
            librsvg
          ];

          shellHook = ''
            export PKG_CONFIG_PATH="${pkgsFor.${system}.pkg-config}/lib/pkgconfig:$PKG_CONFIG_PATH"
            export LD_LIBRARY_PATH="${pkgsFor.${system}.gtk3}/lib:${pkgsFor.${system}.gtk-layer-shell}/lib:$LD_LIBRARY_PATH"
            export GI_TYPELIB_PATH="${pkgsFor.${system}.gtk3}/lib/girepository-1.0:${pkgsFor.${system}.gtk-layer-shell}/lib/girepository-1.0:$GI_TYPELIB_PATH"
            export GOPATH="$PWD/.go"
            export PATH="$GOPATH/bin:$PATH"
            mkdir -p "$GOPATH"
          '';
        };
      });
    };
}


