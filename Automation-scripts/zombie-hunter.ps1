<#
.SYNOPSIS
    Zombie Resource Hunter - Unattached Disks aur Public IPs ko delete karne ke liye.
#>

Write-Output "Authenticating to Azure..."
Connect-AzAccount -Identity

$ResourceGroupName = "rg-appx-existing-prod"

Write-Output "--------------------------------------------------------"
Write-Output "HUNTING ZOMBIE DISKS..."
Write-Output "--------------------------------------------------------"

# 1. Unattached Managed Disks ko scan karo
$disks = Get-AzDisk -ResourceGroupName $ResourceGroupName
foreach ($disk in $disks) {
    if ($disk.DiskState -eq "Unattached") {
        Write-Output "ALERT: Found Unattached Zombie Disk: $($disk.Name). Deleting..."
        Remove-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $disk.Name -Force
        Write-Output "Successfully deleted orphaned disk: $($disk.Name)"
    }
}

Write-Output "--------------------------------------------------------"
Write-Output "HUNTING UNASSOCIATED PUBLIC IPs..."
Write-Output "--------------------------------------------------------"

# 2. Unused Public IPs ko scan karo
$publicIps = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName
foreach ($ip in $publicIps) {
    if ($null -eq $ip.IpConfiguration) {
        Write-Output "ALERT: Found Unassociated Idle Public IP: $($ip.Name). Deleting..."
        Remove-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $ip.Name -Force
        Write-Output "Successfully deleted idle Public IP: $($ip.Name)"
    }
}