# CommandHistory Logger v3 — Complete Reference

## GitHub Repo
**URL:** `https://github.com/SellerDumpskart/CommandHistoryLogger`

---

## Quick Commands (Copy-Paste Ready)

### Install (Admin CMD on any laptop)
```
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SellerDumpskart/CommandHistoryLogger/main/Install.bat' -OutFile 'C:\Install.bat' -UseBasicParsing"; cmd /d /c C:\Install.bat
```

### Uninstall (Admin CMD on any laptop)
```
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SellerDumpskart/CommandHistoryLogger/main/Uninstall.bat' -OutFile 'C:\Uninstall.bat' -UseBasicParsing"; cmd /d /c C:\Uninstall.bat
```

---

## What Gets Installed

| Item | Location |
|------|----------|
| Logger script | `C:\CommandHistory\_system\CommandLogger.ps1` |
| PowerShell profile | `C:\WINDOWS\System32\WindowsPowerShell\v1.0\profile.ps1` |
| Registry key | `HKLM\Software\Microsoft\Command Processor\AutoRun` |
| Log folders | `C:\CommandHistory\TXT\`, `HTML\`, `CSV\` |

---

## What the Installer Does (Step by Step)

1. Checks for admin rights
2. Sets temporary CMD AutoRun (powershell.exe -NoLogo -NoProfile)
3. Sets execution policy (RemoteSigned)
4. Downloads `Setup.ps1` and `CommandLogger.ps1` from GitHub
5. Runs `Setup.ps1` which:
   - Creates folder structure (`C:\CommandHistory\_system`, `TXT`, `HTML`, `CSV`)
   - Copies `CommandLogger.ps1` to `C:\CommandHistory\_system\`
   - Adds logger block to PowerShell system profile
   - Adds PSReadLine white colors to profile
   - Sets permanent CMD AutoRun → `CommandLogger.ps1`
6. Verifies registry and core file exist
7. Cleans up temp files
8. Deletes `C:\Install.bat`

---

## What the Uninstaller Does

1. Checks for admin rights
2. Asks confirmation (Y/N)
3. Asks whether to delete log files (Y/N)
4. Removes CMD AutoRun registry key
5. Cleans PowerShell profile (removes logger block + PSReadLine colors)
6. Removes `C:\CommandHistory\_system\` folder
7. If requested, deletes `C:\CommandHistory\` entirely
8. Deletes `C:\Uninstall.bat`

---

## Features

- **Multi-format logging** — TXT, HTML (styled table), CSV
- **Day-wise folders** — `C:\CommandHistory\TXT\2026-03-19\`
- **Session detection** — DWAgent, MeshCentral, SSH, RDP, CMD, PowerShell
- **CMD support** — Auto-launches PowerShell via registry AutoRun
- **cd without quotes** — `cd program files` works
- **Light terminal colors** — PSReadLine all white
- **Clean prompt** — `C:\path>` (no PS prefix)
- **No duplicate logging** — Single prompt-based logger only
- **Correct exit codes** — 0 for success, 1 for error
- **Self-cleanup** — .bat files delete themselves after running

---

## Log File Locations

```
C:\CommandHistory\
├── _system\
│   └── CommandLogger.ps1
├── TXT\
│   └── 2026-03-19\
│       └── COMPUTERNAME_USER_SESSION.txt
├── HTML\
│   └── 2026-03-19\
│       └── COMPUTERNAME_USER_SESSION.html
└── CSV\
    └── 2026-03-19\
        └── COMPUTERNAME_USER_SESSION.csv
```

---

## Session Types Detected

| Session | Trigger |
|---------|---------|
| Remote-DWAgent | dwagent, dwservice, dwrcs, windowssecurityservice |
| Remote-MeshCentral | meshagent, meshcentral |
| Remote-SSH | sshd, openssh |
| Remote-RDP | rdpclip, mstsc |
| Local-CMD-via-PS | cmd |
| Local-PowerShell | default |

---

## GitHub Repo Structure

```
CommandHistoryLogger/
├── Install.bat              # One-click installer (downloads from GitHub)
├── Uninstall.bat            # One-click uninstaller
├── Setup.ps1                # PowerShell setup script
├── system/
│   └── CommandLogger.ps1    # Core logger script
├── README.md
└── .gitignore
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| .bat file doesn't run | Use `cmd /d /c C:\file.bat` |
| Execution policy warning | Already suppressed with try/catch |
| cd still fails with spaces | Check `Get-Command cd` — should be Function not Alias |
| Duplicate logging | Ensure using v3 (PSReadLine handler removed) |
| Wrong exit codes | Ensure using v3 (prompt-based logger only) |
| AutoRun not set | Run `reg query "HKLM\Software\Microsoft\Command Processor" /v AutoRun` |

---

## Registry AutoRun Value (After Install)

```
powershell.exe -NoLogo -ExecutionPolicy Bypass -NoExit -File "C:\CommandHistory\_system\CommandLogger.ps1"
```

---

## Version History

| Version | Changes |
|---------|---------|
| v1 | Basic logger |
| v2 | Session detection, HTML/CSV output |
| v3 | Fixed duplicate logging, correct exit codes, cd without quotes, PSReadLine colors, custom prompt, one-click GitHub installer/uninstaller, self-cleanup |
