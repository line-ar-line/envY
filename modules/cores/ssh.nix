{ config, pkgs, lib, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
        "*" = {
            Compression = true;
        };

        "github.com" = {
            HostName = "ssh.github.com";
            Port = 443;
            User = "git";
        };

        "my-linux" = {
            HostName = "162.105.227.61";
            Port = 22;
            User = "linearline";
            IdentityFile = "~/.ssh/id_ed25519";
            IdentitiesOnly = true;
        };
    };
  };

  home.activation.generateSSHKey = lib.hm.dag.entryAfter ["userBoundary"] ''
    _LOG_CTX="generateSSHKey"
    ssh_key="$HOME/.ssh/id_ed25519"
    email="${config.programs.git.settings.user.email}"

    if [ ! -f "$ssh_key" ]; then
      log_info "Generating SSH Key for $email..."
      $DRY_RUN_CMD mkdir -p "$HOME/.ssh"
      $DRY_RUN_CMD chmod 700 "$HOME/.ssh"
      $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "$email" -f "$ssh_key" -N ""
      log_info "SSH Key generated at $ssh_key"
    fi
  '';
}
