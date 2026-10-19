{ config, lib, machinePlatform, pkgs, ... }:

let
  agentConfig = config.envy.agents.codex;
  prompts = import ./prompts.nix { inherit lib pkgs; };
  endpoint = if agentConfig.endpoint == null
    || !(builtins.hasAttr agentConfig.endpoint config.envy.llm.endpoints) then null
    else config.envy.llm.endpoints.${agentConfig.endpoint};
  credentialName = if agentConfig.credential == null then null
    else "llm-credential-${agentConfig.credential}";
  credential = if credentialName == null || !(builtins.hasAttr credentialName config.sops.placeholder) then ""
    else builtins.getAttr credentialName config.sops.placeholder;
  templateName = "envy-agent-codex";
  authTemplateName = "envy-agent-codex-auth";
  codexExecutable = if machinePlatform == "linux" then lib.getExe pkgs.codex else null;
  codex = pkgs.writeShellApplication {
    name = "codex";
    text = ''
      if [ -f "${config.sops.templates.${templateName}.path}" ]; then
        # shellcheck source=/dev/null
        source "${config.sops.templates.${templateName}.path}"
      fi
      if [ -f "${config.envy.user.home}/.config/envy/agent-runtime/codex.env" ]; then
        # shellcheck source=/dev/null
        source "${config.envy.user.home}/.config/envy/agent-runtime/codex.env"
      fi
      ${if codexExecutable != null then ''
      cmd=(${lib.escapeShellArg codexExecutable})
      '' else ''
      self_dir=$(CDPATH=; export CDPATH; cd -- "$(dirname -- "$0")" && pwd -P)
      codex_path=""
      old_ifs="$IFS"
      IFS=:
      for path_dir in $PATH; do
        candidate="$path_dir/codex"
        candidate_dir=$(CDPATH=; export CDPATH; cd -- "$path_dir" 2>/dev/null && pwd -P) || continue
        if [ "$candidate_dir/codex" != "$self_dir/codex" ] && [ -x "$candidate" ]; then
          codex_path="$candidate"
          break
        fi
      done
      IFS="$old_ifs"
      if [ -z "$codex_path" ]; then
        echo "envY: the Homebrew Codex executable was not found on PATH" >&2
        exit 127
      fi
      cmd=("$codex_path")
      ''}
      ${prompts.shellArgs "codex"}
      ${lib.concatMapStringsSep "\n" (arg: "cmd+=(${lib.escapeShellArg arg})") agentConfig.args}
      exec "''${cmd[@]}" "$@"
    '';
  };
in

{
  config = lib.mkMerge [
    { agents.settingsFiles.codex = {
      target = ".codex/config.toml";
      format = "toml";
    }; }
    {
    sops.templates.${templateName}.content = ''
      ${lib.optionalString (endpoint != null) ''
      export OPENAI_BASE_URL=${lib.escapeShellArg endpoint.baseUrl}
      ''}
      ${lib.optionalString (credentialName != null) ''
      export OPENAI_API_KEY=${lib.escapeShellArg credential}
      ''}
      ${lib.optionalString (agentConfig.model != null) ''
      export OPENAI_MODEL=${lib.escapeShellArg agentConfig.model}
      ''}
      export GPT_IMAGE_MODEL_NAME=gpt-image-2
    '';
    envy.software.nix.packages.include = [ codex ];
    envy.software.nix.packages.references.codex = "local:modules/agents/codex.nix#codex";

    envy.agents.codex.additionalSettings = {
      approval_policy = "never";
      disable_response_storage = true;
      include_apply_patch_tool = true;
      include_plan_tool = true;
      model = if agentConfig.model == null then "gpt-6-astra" else agentConfig.model;
      model_auto_compact_token_limit = 244800;
      model_context_window = 272000;
      model_max_output_tokens = 128000;
      model_provider = "custom";
      model_reasoning_effort = "max";
      model_reasoning_summary = "detailed";
      model_reasoning_summary_format = "experimental";
      model_verbosity = "medium";
      personality = "pragmatic";
      plan_mode_reasoning_effort = "xhigh";
      preferred_auth_method = "apikey";
      project_doc_fallback_filenames = [ "CLAUDE.md" "AGENTS.md" ];
      project_doc_max_bytes = 65536;
      sandbox_mode = "danger-full-access";
      service_tier = "fast";
      suppress_unstable_features_warning = true;
      web_search = "live";
      analytics.enabled = false;
      desktop = {
        "ambient-suggestions-enabled" = true;
        conversationDetailMode = "STEPS_COMMANDS";
        "dock-icon-preference" = "app-default";
        followUpQueueMode = "queue";
        preventSleepWhileRunning = true;
      };
      features = {
        apply_patch_freeform = true;
        js_repl = false;
        multi_agent = true;
        plan_tool = true;
        responses_websockets = true;
        shell_snapshot = true;
        unified_exec = true;
        view_image_tool = true;
      };
      model_providers.custom = {
        base_url = if endpoint == null then "https://api.openai.com/v1" else endpoint.baseUrl;
        name = "custom";
        requires_openai_auth = true;
        supports_websockets = true;
        wire_api = "responses";
      };
    };

    sops.templates.${authTemplateName}.content = builtins.toJSON {
      auth_mode = "apikey";
      OPENAI_API_KEY = config.sops.placeholder.${credentialName};
    };

    home.activation.installCodexAuth = lib.hm.dag.entryAfter [ "sopsDecrypt" "linkGeneration" ] ''
      _LOG_CTX="installCodexAuth"
      if [ -z "$DRY_RUN_CMD" ]; then
        mkdir -p "$HOME/.codex"
        install -m 600 "${config.sops.templates.${authTemplateName}.path}" "$HOME/.codex/auth.json"
      fi
    '';
    }
  ];
}
