{
  description = "rcc-sync — explicit, non-destructive local <-> OneDrive sync tool, built for Rogue Community College";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: import nixpkgs { inherit system; };

      # rsync + diffutils are required; newt provides whiptail for the
      # nicer --tui mode (rcc-sync falls back to a plain menu without it).
      # Wrapped in either way so the package is self-contained.
      runtimeDepsFor = pkgs: with pkgs; [ rsync diffutils newt ];
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          runtimeDeps = runtimeDepsFor pkgs;
        in
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "rcc-sync";
            version = "0.1";

            src = ./rcc-sync;
            dontUnpack = true;

            nativeBuildInputs = [ pkgs.makeWrapper ];

            installPhase = ''
              runHook preInstall
              install -Dm755 "$src" "$out/bin/rcc-sync"
              wrapProgram "$out/bin/rcc-sync" \
                --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Explicit, non-destructive local <-> OneDrive sync tool for Rogue Community College";
              license = licenses.mit;
              platforms = platforms.linux;
              mainProgram = "rcc-sync";
            };
          };
        });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/rcc-sync";
        };
      });

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = (runtimeDepsFor pkgs) ++ [ pkgs.shellcheck ];
          };
        });

      checks = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          shellcheck = pkgs.runCommand "rcc-sync-shellcheck"
            { nativeBuildInputs = [ pkgs.shellcheck ]; }
            ''
              shellcheck ${./rcc-sync}
              touch $out
            '';
        });
    };
}
