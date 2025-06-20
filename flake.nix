{
  description = "Tonnam nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nix-homebrew,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {
          nixpkgs.config.allowUnfree = true;

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.vim
            pkgs.nixfmt-rfc-style
            pkgs.android-tools
            pkgs.wireshark
            pkgs.arc-browser
            pkgs.discord
            pkgs.go
            pkgs.vscode
            pkgs.kubectl
            pkgs.kubernetes-helm
            pkgs.android-tools
            pkgs.nmap
            pkgs.pulumi
            pkgs.pulumictl
            pkgs.cloudflared
            pkgs.python314
            pkgs.nodejs_23
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Update the system environment.
          programs.zsh.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # Homebrew
          homebrew = {
            enable = true;
            taps = [
              "derailed/k9s"
              "leoafarias/fvm"
            ];
            brews = [
              "derailed/k9s/k9s"
              "leoafarias/fvm/fvm"
            ];
            casks = [
              "warp"
            ];
            masApps = {
              "LINE" = 539883307;
              "Amphetamine" = 937984704;
            };
            onActivation.cleanup = "zap";
          };

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Tonnams-MacBook-Pro
      darwinConfigurations."Tonnams-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # User owning the Homebrew prefix
              user = "sirateek";

              # Automatically migrate existing Homebrew installations
              autoMigrate = true;
            };
          }
        ];
      };
    };
}
