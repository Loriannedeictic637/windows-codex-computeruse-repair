# repair-codex-computer-use

Unofficial community repair skill and scripts for a narrow set of Windows
Codex Desktop Computer Use and Chrome plugin loading issues.

This is not a general "enable Computer Use for every account or region" tool.
It is meant for users who already have Windows Codex Desktop installed, but the
local plugin/runtime wiring is broken.

This repository does not contain or redistribute OpenAI Codex, OpenAI bundled
plugins, `@oai/sky`, or any runtime files. It only contains diagnostics,
instructions, and minimal patch scripts that operate on files already present
on the user's own machine.

## Beginner Quick Start

You do not need to know Git.

1. Open the GitHub page.
2. Click `Code` -> `Download ZIP`.
3. Unzip the file.
4. Open the unzipped folder in PowerShell.
5. Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-skill.ps1
```

6. Restart Codex Desktop, or open a new Codex chat.
7. Ask Codex:

```text
Use repair-codex-computer-use to diagnose my Windows Computer Use plugin.
```

This only installs the helper skill. It does not silently change Codex runtime
files. The repair scripts still diagnose first, create backups, and require an
explicit `-Apply` when a file-changing repair is needed.

## One Sentence Summary

This tool helps when Windows Codex Desktop cannot load Computer Use because
`openai-bundled` is missing or because `@oai/sky@0.4.10` blocks a known internal
Computer Use import through package `exports`.

## Exact Problem This Targets

Use this project when at least one of these is true:

1. `openai-bundled` is missing from `codex plugin marketplace list`, so
   `chrome@openai-bundled` and `computer-use@openai-bundled` are unavailable.
2. Computer Use is installed but fails with a Node package exports error like:

```text
Package subpath ... is not defined by "exports"
```

The known runtime mismatch is:

```text
@oai/sky@0.4.10
```

where the file exists:

```text
dist/project/cua/sky_js/src/targets/windows/internal/computer_use_client_base.js
```

but the same subpath is not exported from `@oai/sky/package.json`.

The successful repair should make `codex plugin list` show:

```text
chrome@openai-bundled        installed, enabled
computer-use@openai-bundled  installed, enabled
```

and the `WindowsComputerUseClientBase` import test should print:

```text
function
```

## What This Does Not Fix

This project does not claim to fix every "Computer Use unavailable" message.
It probably will not help if the root cause is:

- The user's account, plan, region, or feature flag does not have Computer Use.
- The Codex Desktop version no longer includes the same bundled plugin/runtime
  layout.
- The installed `@oai/sky` version is not the known affected shape and needs a
  different official update.
- Windows accessibility, antivirus, endpoint management, or enterprise policy
  blocks desktop control.
- The native Computer Use service/pipe fails after imports already work.
- The only error is sandbox process creation, for example:

```text
CreateProcessAsUserW failed: 5
```

For sandbox errors, keep elevated sandbox as the preferred mode, allow workspace
write access first, and use `unelevated` only as a compatibility fallback.

## Decision Tree

Run:

```powershell
.\repair-codex-computer-use\scripts\diagnose.ps1
```

Then choose the smallest matching fix:

1. If `openai-bundled` is absent from the marketplace list, run
   `register-openai-bundled.ps1 -Apply -InstallPlugins`.
2. If `computer-use@openai-bundled` is installed but import fails with
   `Package subpath ... is not defined by "exports"`, run
   `patch-sky-exports.ps1 -Apply`.
3. If both checks already pass, this repository is probably not the right fix;
   look at sandbox, OS policy, feature availability, or a newer Codex bug.

## Safety Model

- Read-only diagnosis comes first.
- Scripts default to dry-run where they can modify files.
- Modifying commands require `-Apply`.
- Scripts create backups before changing user config or package metadata.
- Scripts do not modify `WindowsApps` permissions or ownership.
- Scripts do not delete the user's `.codex` directory.
- Scripts do not automatically change Codex sandbox mode.

## Manual Script Usage

Use this if you do not want to install the Codex skill.

Open PowerShell in this repository folder on Windows.

Run read-only diagnosis:

```powershell
.\repair-codex-computer-use\scripts\diagnose.ps1
```

If `openai-bundled` is missing, register the bundled marketplace copied from
the local Codex install:

```powershell
.\repair-codex-computer-use\scripts\register-openai-bundled.ps1 -Apply -InstallPlugins
```

If Computer Use fails with `Package subpath ... is not defined by "exports"`,
patch `@oai/sky/package.json`:

```powershell
.\repair-codex-computer-use\scripts\patch-sky-exports.ps1 -Apply
```

Restart Codex Desktop or start a new Codex thread after installation or patching.

## Verified Case

This project was built from a verified Windows repair where:

- `openai-bundled` was missing from local Codex marketplaces.
- After registering it, `chrome@openai-bundled` and
  `computer-use@openai-bundled` became installed and enabled.
- Computer Use then hit an `@oai/sky@0.4.10` package exports mismatch.
- Adding the single missing export for
  `computer_use_client_base.js` fixed the import.
- The real Computer Use runtime could call `sky.list_apps()` and return
  Windows applications.

## Manual Skill Install

The beginner install script above is recommended. To install manually, copy the
inner skill folder into your Codex skills directory:

```powershell
Copy-Item -Recurse `
  -LiteralPath .\repair-codex-computer-use `
  -Destination "$HOME\.codex\skills\repair-codex-computer-use"
```

Then ask Codex:

```text
Use repair-codex-computer-use to diagnose my Windows Computer Use plugin.
```

## Sandbox Notes

OpenAI's elevated Windows sandbox is the preferred mode because it provides
stronger isolation. If Computer Use is installed and imports correctly but
launching the desktop control process fails with:

```text
CreateProcessAsUserW failed: 5
```

first allow workspace write access in Codex settings. If elevated sandboxing
still fails or the user does not have the required local privileges, switching
Windows sandbox mode to `unelevated` is a compatibility fallback. It is weaker
isolation, not automatically unsafe.

## Files

```text
install-skill.ps1
repair-codex-computer-use/
  SKILL.md
  scripts/
    diagnose.ps1
    register-openai-bundled.ps1
    patch-sky-exports.ps1
```

## Publishing Notes

If you publish this repository:

- Make clear it is unofficial community tooling.
- Do not include copied `openai-bundled` plugin files.
- Do not include copied `@oai/sky` runtime files.
- Do not include user-specific paths, tokens, logs, or screenshots containing
  private data.
- Keep scripts conservative and easy to audit.

## License

MIT for the files in this repository only. OpenAI Codex, OpenAI bundled
plugins, `@oai/sky`, and other runtime files remain under their own licenses.
