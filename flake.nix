{
  description = "Development environment for nwg-drawer";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: 
    let
      system = builtins.currentSystem;

      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Go development
          go
          gopls
          go-tools
          golangci-lint
          delve

          # GTK development
          gtk3
          gtk3-x11
          pkg-config
          gobject-introspection
          cairo
          glib

          # Additional dependencies
          gtk-layer-shell
          librsvg

          # Build tools
          gcc
          gnumake
        ];

        shellHook = ''
          export PKG_CONFIG_PATH="${pkgs.pkg-config}/lib/pkgconfig:$PKG_CONFIG_PATH"
          export LD_LIBRARY_PATH="${pkgs.gtk3}/lib:${pkgs.gtk-layer-shell}/lib:$LD_LIBRARY_PATH"
          export GI_TYPELIB_PATH="${pkgs.gtk3}/lib/girepository-1.0:${pkgs.gtk-layer-shell}/lib/girepository-1.0:$GI_TYPELIB_PATH"
          export GOPATH="$PWD/.go"
          export PATH="$GOPATH/bin:$PATH"
          mkdir -p "$GOPATH"
        '';

        GTK_DEBUG = "interactive";
        
        GOROOT = "${pkgs.go}/share/go";
      };
    };
}

