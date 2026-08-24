Clear-Host
$global:RetentionDays = 7

While ($true) {
    Write-Host "--- Windows 11 Basic Cleanup Panel ---" -ForegroundColor Cyan
    Write-Host "1. Clear Temporary Files and System Caches"
    Write-Host "2. Purge Delivery Optimization Cache & Disable Sharing"
    Write-Host "3. Clear Windows Store App Cache"
    Write-Host "4. Run Windows Component Cleanup (DISM)"
    Write-Host "5. Exit Application"
    Write-Host "--------------------------------------"
    
    $selection = Read-Host "`nSelect an option (1-5)"
    
    Switch ($selection) {
        "1" {
            Write-Host "`nCleaning temporary files and system caches..."
            @("$Env:windir\Temp\*", "$Env:USERPROFILE\AppData\Local\Temp\*", "C:\ProgramData\Microsoft\Windows\WER\*", "$Env:USERPROFILE\AppData\Local\Microsoft\Windows\WER\*", "$Env:USERPROFILE\AppData\Local\Microsoft\Windows\Explorer\*.etl", "$Env:USERPROFILE\AppData\Local\Microsoft\Windows\Explorer\*.db") | ForEach-Object { Remove-Item $_ -Force -Recurse -ErrorAction SilentlyContinue }
            Write-Host "Temporary files cleanup complete!" -ForegroundColor Green
        }
        "2" {
            Write-Host "`nPurging Delivery Optimization updates cache..."
            Delete-DeliveryOptimizationCache -Force -IncludePinnedFiles -ErrorAction SilentlyContinue
            Write-Host "Disabling peer-to-peer update sharing feature..."
            If (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization")) { New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "DeliveryOptimization" -Force | Out-Null }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Value 0 -Force -ErrorAction SilentlyContinue
            Write-Host "Delivery Optimization feature handled!" -ForegroundColor Green
        }
        "3" {
            Write-Host "`nRefreshing Windows Store cache (background task)..."
            Start-Process "wsreset.exe" -NoNewWindow
            Write-Host "Windows Store reset triggered!" -ForegroundColor Green
        }
        "4" {
            Write-Host "`nRunning Windows Component Cleanup (this takes a few minutes)..."
            dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
            Write-Host "Component cleanup complete!" -ForegroundColor Green
        }
        "5" {
            Write-Host "`nExiting tool. Goodbye!" -ForegroundColor Yellow
            break
        }
        Default {
            Write-Host "`n[!] Invalid selection. Please enter a number from 1 to 5." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Clear-Host
            continue
        }
    }
    
    Write-Host "`nPress any key to return to the selection panel..."
    $null = [Console]::ReadKey($true)
    Clear-Host
}
