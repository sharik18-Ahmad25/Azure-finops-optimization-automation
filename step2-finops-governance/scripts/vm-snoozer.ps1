<#
.SYNOPSIS
    Azure Automation Runbook - Dev VMs ko auto-stop karne ke liye.
.DESCRIPTION
    Yeh script Managed Identity ka use karke Azure se connect karegi aur 'Environment=Dev' tag wali VMs ko stop karegi.
#>

Write-Output "Connecting to Azure via Managed Identity..."
Connect-AzAccount -Identity

$ResourceGroupName = "rg-appx-existing-prod"

# Saari VMs ko fetch karo
$vms = Get-AzVM -ResourceGroupName $ResourceGroupName

foreach ($vm in $vms) {
    $tags = $vm.Tags
    # Check karo agar VM par Dev tag laga hai
    if ($tags -and $tags['Environment'] -eq 'Dev') {
        Write-Output "Found Dev VM: $($vm.Name). Checking status..."
        
        $vmStatus = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vm.Name -Status
        $powerState = ($vmStatus.Statuses | Where-Object { $_.Code -like "PowerState/*" }).DisplayStatus

        if ($powerState -eq "VM running") {
            Write-Output "VM is running. Stopping VM to save compute costs..."
            Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $vm.Name -Force -NoWait
            Write-Output "Deallocation command sent for $($vm.Name)."
        } else {
            Write-Output "VM $($vm.Name) is already stopped ($powerState). Skipping."
        }
    }
}