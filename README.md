# CommandHistory Logger v3

Logs every command typed in any terminal (CMD, PowerShell, remote sessions) into day-wise TXT, HTML, and CSV files.

## Features

- **Multi-format logging** — TXT, HTML (styled table), CSV
- **Day-wise folders** — `C:\CommandHistory\TXT\2026-03-19\`, etc.
- **Session detection** — DWAgent, MeshCentral, SSH, RDP, CMD, PowerShell
- **CMD support** — Auto-launches PowerShell via registry AutoRun
- **cd without quotes** — `cd program files` just works
- **Light terminal colors** — PSReadLine colors set to white
- **Clean prompt** — No `PS` prefix, just `C:\path>`

## One-Click Install

1. Open CMD or PowerShell **as Administrator**
2. Run:

```
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/CommandHistoryLogger/main/Install.bat' -OutFile 'C:\Install.bat' -UseBasicParsing"; C:\Install.bat
```

3. Close and reopen terminal. Done.

## Manual Install

1. Clone or download this repo
2. Right-click `Install.bat` → **Run as administrator**
3. Close and reopen terminal

## Uninstall

1. Right-click `Uninstall.bat` → **Run as administrator**
2. Your log files are preserved in `C:\CommandHistory\`

## Log Locations

```
C:\CommandHistory\
├── TXT\2026-03-19\COMPUTERNAME_USER_SESSION.txt
├── HTML\2026-03-19\COMPUTERNAME_USER_SESSION.html
└── CSV\2026-03-19\COMPUTERNAME_USER_SESSION.csv
```

## File Structure

```
CommandHistoryLogger/
├── Install.bat              # One-click installer (downloads from GitHub)
├── Uninstall.bat            # One-click uninstaller
├── Setup.ps1                # PowerShell setup script
├── system/
│   └── CommandLogger.ps1    # Core logger script
└── README.md
```

## How It Works

1. **CMD AutoRun** — Registry key makes CMD auto-launch PowerShell with the logger
2. **PowerShell Profile** — Dot-sources `CommandLogger.ps1` on every PS session
3. **Prompt Logger** — Captures every command via a custom `prompt` function
4. **Session Detection** — Walks the process tree to identify remote tools (DWAgent, MeshCentral, SSH, RDP)

## After Install

Update `Install.bat` line 18 with your GitHub username:

```
set "REPO=YOUR_GITHUB_USERNAME/CommandHistoryLogger"
```
