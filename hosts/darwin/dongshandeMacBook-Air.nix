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

  # BEGIN ENVY MANAGED SOFTWARE
  # `envy setup` and `envy software` own only these machine-local selections.

  envy.darwin.software.homebrew.casks.exclude = [
    "microsoft-remote-desktop"
  ];
  # END ENVY MANAGED SOFTWARE

  # BEGIN ENVY MANAGED AGENTS
  # envY owns agent selections, endpoint metadata, and credential references here.

  # --- LLM CREDENTIALS ---
  envy.llm.credentials.deepseek.kind = "api-key";
  envy.llm.credentials.deepseek.secretPath = "llm/deepseek/apikey";
  envy.llm.credentials.stepfun.kind = "api-key";
  envy.llm.credentials.stepfun.secretPath = "llm/steps/apikey";

  # --- LLM ENDPOINTS ---
  envy.llm.endpoints.deepseek-openai.baseUrl = "https://api.deepseek.com";
  envy.llm.endpoints.deepseek-openai.protocol = "openai-compatible";
  envy.llm.endpoints.stepfun-anthropic.baseUrl = "https://stepfun.com";
  envy.llm.endpoints.stepfun-anthropic.protocol = "anthropic-compatible";
  envy.llm.endpoints.stepfun-openai.baseUrl = "https://stepfun.com/v1";
  envy.llm.endpoints.stepfun-openai.protocol = "openai-compatible";

  # --- AGENTS ---
  envy.agents.cc.adapter = "claude-code";
  envy.agents.cc.aliases = [ "ccli" ];
  envy.agents.cc.credential = "stepfun";
  envy.agents.cc.endpoint = "stepfun-anthropic";
  envy.agents.cc.model = "step-3.7-flash";
  envy.agents.codex.adapter = "codex";
  envy.agents.codex.credential = "stepfun";
  envy.agents.codex.endpoint = "stepfun-openai";
  envy.agents.codex.model = "step-3.7-flash";
  # END ENVY MANAGED AGENTS

}
