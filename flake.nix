{
  description = "Automatic tiling window manager for macOS à la xmonad.";

  outputs = { self, nixpkgs, flake-utils, ... }:

  let

    lib = nixpkgs.lib;

    systems = with flake-utils.lib.system; [
      x86_64-darwin
    ];

  in flake-utils.lib.eachSystem systems (system:
    let

      pkgs = import nixpkgs {
        config = { };
        localSystem = system;
        overlays = [ ];
      };

      apple_sdk = pkgs.darwin.apple_sdk_11_0;
      stdenv = apple_sdk.stdenv;
      frameworks = apple_sdk.frameworks;

    in {

      devShells.default = pkgs.mkShell.override { inherit stdenv; } {
        packages = with pkgs; [
          cocoapods
          (ruby.withPackages (ps: with ps; [ xcodeproj ]))
          frameworks.Cocoa
        ];
        shellHook = ''
          unset LD
          ${lib.getBin pkgs.cocoapods}/bin/pod install
          echo xcodebuild -workspace Amethyst.xcworkspace -scheme Amethyst -sdk macosx -arch x86_64 -configuration Debug -derivedDataPath ./build clean build  COMPILER_INDEX_STORE_ENABLE=NO
        '';
      };
    }
  );
}
