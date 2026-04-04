$Global:CHL_Root="C:\CommandHistory"
$Global:CHL_Computer=$env:COMPUTERNAME
$Global:CHL_User=$env:USERNAME
$Global:CHL_Today=(Get-Date -Format "yyyy-MM-dd")
$Global:CHL_Session=""

function Get-SessionType {
    $s="Local-PowerShell"
    try {
        $p1=(Get-CimInstance Win32_Process -Filter "ProcessId=$PID").ParentProcessId
        $pr1=Get-CimInstance Win32_Process -Filter "ProcessId=$p1" -EA SilentlyContinue
        $n1=if($pr1){$pr1.Name.ToLower()}else{""}
        $pr2=Get-CimInstance Win32_Process -Filter "ProcessId=$($pr1.ParentProcessId)" -EA SilentlyContinue
        $n2=if($pr2){$pr2.Name.ToLower()}else{""}
        $pr3=Get-CimInstance Win32_Process -Filter "ProcessId=$($pr2.ParentProcessId)" -EA SilentlyContinue
        $n3=if($pr3){$pr3.Name.ToLower()}else{""}
        $all="$n1|$n2|$n3"
        if($all -match "dwagent|dwservice|dwrcs|windowssecurityservice"){$s="Remote-DWAgent"}
        elseif($all -match "meshagent|meshcentral"){$s="Remote-MeshCentral"}
        elseif($all -match "sshd|openssh"){$s="Remote-SSH"}
        elseif($all -match "rdpclip|mstsc"){$s="Remote-RDP"}
        elseif($all -match "cmd"){$s="Local-CMD-via-PS"}
    } catch {}
    return $s
}

function Initialize-LogFolders {
    @("$Global:CHL_Root\TXT\$Global:CHL_Today","$Global:CHL_Root\HTML\$Global:CHL_Today","$Global:CHL_Root\CSV\$Global:CHL_Today") | ForEach-Object {
        if(-not(Test-Path $_)){New-Item -ItemType Directory -Path $_ -Force|Out-Null}
    }
}

function Get-LogPaths {
    $tag="$Global:CHL_Computer`_$Global:CHL_User`_$Global:CHL_Session"
    return @{
        TXT="$Global:CHL_Root\TXT\$Global:CHL_Today\$tag.txt"
        HTML="$Global:CHL_Root\HTML\$Global:CHL_Today\$tag.html"
        CSV="$Global:CHL_Root\CSV\$Global:CHL_Today\$tag.csv"
    }
}

function Write-CommandLog {
    param([string]$Command,[int]$ExitCode=0)
    $ts=Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $p=Get-LogPaths
    $c=$Command.Trim()
    if([string]::IsNullOrWhiteSpace($c)){return}
    Add-Content -Path $p.TXT -Value "[$ts] [$Global:CHL_Session] [$Global:CHL_User@$Global:CHL_Computer] $c" -Encoding UTF8
    [PSCustomObject]@{DateTime=$ts;Computer=$Global:CHL_Computer;User=$Global:CHL_User;SessionType=$Global:CHL_Session;PID=$PID;Command=$c;ExitCode=$ExitCode} | Export-Csv -Path $p.CSV -Append -NoTypeInformation -Encoding UTF8
    $ec=$c -replace "&","&amp;" -replace "<","&lt;" -replace ">","&gt;" -replace "'","&#39;" -replace '"',"&quot;"
    $rc=if($ExitCode -ne 0){"error"}else{"ok"}
    $hr="<tr class=""$rc""><td>$ts</td><td>$Global:CHL_Session</td><td>$Global:CHL_User</td><td>$Global:CHL_Computer</td><td class=""cmd"">$ec</td><td>$ExitCode</td></tr>"
    if(-not(Test-Path $p.HTML)){
        $hh="<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Command History</title><style>body{font-family:Consolas,monospace;background:#0f0f0f;color:#e0e0e0;padding:20px}table{width:100%;border-collapse:collapse;font-size:13px}th{background:#1a1a2e;color:#00bcd4;padding:8px;text-align:left}td{padding:6px 8px;border-bottom:1px solid #222}tr.ok:hover{background:#1a1a1a}tr.error{background:#2a0a0a}.cmd{color:#80ff80}tr.error .cmd{color:#ff6b6b}</style></head><body><h2 style='color:#00bcd4'>Command History $Global:CHL_Today $Global:CHL_Computer</h2><table><thead><tr><th>DateTime</th><th>Session</th><th>User</th><th>Computer</th><th>Command</th><th>Exit</th></tr></thead><tbody>"
        Set-Content -Path $p.HTML -Value $hh -Encoding UTF8
    }
    Add-Content -Path $p.HTML -Value $hr -Encoding UTF8
}

function Write-SessionBanner {
    $p=Get-LogPaths
    $ts=Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $p.TXT -Value "========================================`r`n SESSION START: $ts`r`n User: $Global:CHL_User`r`n Machine: $Global:CHL_Computer`r`n Session: $Global:CHL_Session`r`n PID: $PID`r`n========================================" -Encoding UTF8
}

function Close-HtmlLog {
    $p=Get-LogPaths
    if(Test-Path $p.HTML){Add-Content -Path $p.HTML -Value "</tbody></table></body></html>" -Encoding UTF8}
}

function Register-PromptLogger {
    function global:prompt {
        $ls=$?
        try {
            $lc=(Get-History -Count 1 -EA SilentlyContinue)
            if($lc -and $lc.Id -ne $Global:CHL_LastHistId){
                $Global:CHL_LastHistId=$lc.Id
                Write-CommandLog -Command $lc.CommandLine -ExitCode $(if($ls){0}else{1})
            }
        } catch {}
        "$((Get-Location).Path)> "
    }
}

function Start-CommandLogger {
    $Global:CHL_Session=Get-SessionType
    $Global:CHL_Today=(Get-Date -Format "yyyy-MM-dd")
    $Global:CHL_LastHistId=0
    Initialize-LogFolders
    Write-SessionBanner
    Register-PromptLogger
    Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action{Close-HtmlLog}|Out-Null
}

Start-CommandLogger

# -- Custom cd (handles spaces without quotes) --
Remove-Item Alias:cd -Force -ErrorAction SilentlyContinue
function global:cd {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Path
    )
    if ($Path.Count -gt 1) {
        Set-Location ($Path -join " ")
    } elseif ($Path.Count -eq 1) {
        Set-Location $Path[0]
    } else {
        Set-Location $HOME
    }
}
