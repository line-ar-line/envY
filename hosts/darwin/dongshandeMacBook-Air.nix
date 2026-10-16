{ ... }:

{
  imports = [ ../default.nix ];

  # `envy config refine` writes non-sensitive machine values here.
  # Add machine-specific envy.* overrides here.

  # BEGIN ENVY MANAGED CONFIG
  # `envy config` updates only this block. Other machine policy stays intact.

  # --- BASE CONFIG ---
  envy.user.name = "linearline";
  envy.user.home = "/Users/linearline";

  # --- DARWIN_SERVICES CONFIG ---
  envy.darwin.services.mihomo.mode = "none";
  envy.darwin.services.mihomo.tun = false;
  envy.darwin.services.openssh.mode = "manual";

  # --- ENV CONFIG ---
  envy.repository.path = "/Users/linearline/.envy";

  # --- GIT CONFIG ---
  envy.git.name = "line-ar-line";
  envy.git.email = "linearline@dongshandeMacBook-Air.local";

  # --- HABITS CONFIG ---
  envy.habits.terminalScratchpad.gesture = "F12";
  envy.habits.globalLauncher.gesture = "Option+Space";

  # --- MIRRORS CONFIG ---
  envy.mirrors.mode = "china";

  # --- VSCODE CONFIG ---
  envy.vscode.mode = "remote";
  # END ENVY MANAGED CONFIG

}
