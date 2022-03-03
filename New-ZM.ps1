<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

$Name = $VMName = "Test"
$MemoryStartupBytes = 512MB
$SwitchName = "External Virtual Switch"
$Path = "D:\Hyper-Z"
$Version = "10.0"
$Generation = 2
New-VM -Name $Name -MemoryStartupBytes $MemoryStartupBytes -NoVHD -SwitchName $SwitchName -Path $Path -Version $Version -Generation $Generation

$Count = 4
$ExposeVirtualizationExtensions = $true
Set-VMProcessor -VMName $VMName -Count $Count -ExposeVirtualizationExtensions $ExposeVirtualizationExtensions

$SizeBytes = 512GB
New-VHD -Path $Path\$Name\$Name.vhdx -SizeBytes $SizeBytes -Dynamic

Add-VMHardDiskDrive -VMName $VMName -Path $Path\$Name\$Name.vhdx

$ISOPath = "C:\Users\AdrianHale\OneDrive - Breache\Documents\ISOs\windows_10_evaluation.iso"
Add-VMDvdDrive -VMName $VMName -Path $ISOPath

$VlanId = 4094
Set-VMNetworkAdapterVlan -VMName $VMName -Access -VlanId $VlanId

$vmDVDDrive = Get-VMDvdDrive -VMName $VMName
$vmVMNetworkAdapter = Get-VMNetworkAdapter -VMName $VMName
$vmHardDiskDrive = Get-VMHardDiskDrive -VMName $VMName
$EnableSecureBoot = "On"
$SecureBootTemplate = "MicrosoftWindows"
Set-VMFirmware -VMName $VMName -BootOrder $vmDVDDrive, $vmVMNetworkAdapter, $vmHardDiskDrive -EnableSecureBoot $EnableSecureBoot -SecureBootTemplate $SecureBootTemplate

Set-VMKeyProtector -VMName $VMName -NewLocalKeyProtector

Enable-VMTPM -VMName $VMName

$EnableVMIntegrationService = "Guest Service Interface","Heartbeat","Key-Value Pair Exchange","Shutdown","VSS"
Enable-VMIntegrationService -Name $EnableVMIntegrationService -VMName $VMName

$DisableVMIntegrationService = "Time Synchronization"
Disable-VMIntegrationService -Name $DisableVMIntegrationService -VMName $VMName

$MemoryMinimumBytes = 512MB
$MemoryMaximumBytes = 8GB
$MemoryStartupBytes = 2GB
$AutomaticStartAction = "Nothing"
$AutomaticStopAction = "Shutdown"
$AutomaticCheckpointsEnabled = $false
$SnapshotFileLocation = "$Path\$VMName\Checkpoints"
$CheckpointType = "Production"
Set-VM -Name $Name -DynamicMemory -MemoryMinimumBytes $MemoryMinimumBytes -MemoryMaximumBytes $MemoryMaximumBytes -MemoryStartupBytes $MemoryStartupBytes -AutomaticStartAction $AutomaticStartAction -AutomaticStopAction $AutomaticStopAction -AutomaticCheckpointsEnabled $AutomaticCheckpointsEnabled -SnapshotFileLocation $SnapshotFileLocation -CheckpointType $CheckpointType

$HorizontalResolution = 1920
$VerticalResolution = 1080
Set-VMVideo -VMName $VMName -HorizontalResolution $HorizontalResolution -VerticalResolution $VerticalResolution

#$SnapshotName = "Initial"
#Checkpoint-VM -Name $Name -SnapshotName $SnapshotName

#Start-VM -Name $Name

#VMConnect.exe localhost $VMName