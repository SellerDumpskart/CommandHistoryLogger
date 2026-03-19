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
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SellerDumpskart/CommandHistoryLogger/main/Install.bat' -OutFile 'C:\Install.bat' -UseBasicParsing"; cmd /d /c C:\Install.bat
```

3. Close and reopen terminal. Done.

## One-Click Uninstall

1. Open CMD or PowerShell **as Administrator**
2. Run:

```
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SellerDumpskart/CommandHistoryLogger/main/Uninstall.bat' -OutFile 'C:\Uninstall.bat' -UseBasicParsing"; cmd /d /c C:\Uninstall.bat
```

3. Your log files in `C:\CommandHistory\` are preserved.

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
