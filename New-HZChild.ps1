function New-HZChild {

<#
.SYNOPSIS
    Creates a child virtual machine
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

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        #New-VM
        [string]$Name,

        [Parameter(Mandatory=$false)]
        #New-VM
        [boolean]$NoVHD                          = $true,
        [string]$SwitchName                      = "External Virtual Switch",
        [string]$Path                            = "D:\Hyper-Z",
        [version]$Version                        = "10.0",
        [int16]$Generation                       = 2,

        #Set-VMProcessor
        [int64]$Count                            = 4,
        [boolean]$ExposeVirtualizationExtensions = $true,

        #Copy-Item
        #[string]$ParentVHD                       = "D:\VHDs\windows_10_21h2.vhdx",
        #[string]$ParentVHD                       = "D:\VHDs\windows_10_21h2_eval.vhdx",
        #[string]$ParentVHD                       = "D:\VHDs\windows_11_eval.vhdx",
        #[string]$ParentVHD                       = "D:\VHDs\windows_server_2019_eval.vhdx",
        [string]$ParentVHD                       = "D:\VHDs\windows_server_2022_core_eval.vhdx",
        #[string]$ParentVHD                       = "D:\VHDs\windows_server_2022_eval.vhdx",

        #Set-VMNetworkAdapterVlan
        [boolean]$Access                         = $true,
        [int32]$VlanId                           = 2471,

        #Set-VMFirmware
        [string]$EnableSecureBoot                = "On",
        [string]$SecureBootTemplate              = "MicrosoftWindows",

        #Set-VMKeyProtector
        [boolean]$NewLocalKeyProtector           = $true,

        #Enable-VMTPM

        #Enable-VMIntegrationService
        [string[]]$EnableVMIntegrationServiceName,

        #Disable-VMIntegrationService
        [string]$DisableVMIntegrationServiceName = "Time Synchronization",

        #Set-VM
        [int64]$MemoryMinimumBytes               = 128MB,
        [int64]$MemoryMaximumBytes               = 8GB,
        [int64]$MemoryStartupBytes               = 2GB,
        [string]$AutomaticStartAction            = "Nothing",
        [string]$AutomaticStopAction             = "Shutdown",
        [boolean]$AutomaticCheckpointsEnabled    = $false,
        [string]$SnapshotFileLocation            = "$Path\$Name\Checkpoints",
        [string]$CheckpointType                  = "Production",

        #Set-VMVideo
        [uint16]$HorizontalResolution            = 1920,
        [uint16]$VerticalResolution              = 1080  
    )
    
    begin {
        Write-Host 'Begin'
    }
    
    process {
        foreach ($VM in $Name) {
            try {
                Write-Host 'Process - Try'



                $NewVM = @{
                    Name       = $Name
                    NoVHD      = $NoVHD
                    SwitchName = $SwitchName
                    Path       = $Path
                    Version    = $Version
                    Generation = $Generation
                }
                New-VM @NewVM

                $CopyItem = @{
                    Path = $ParentVHD
                    Destination = "$Path\$Name\$Name.vhdx"
                }
                Copy-Item @CopyItem

                $AddVMHardDiskDrive = @{
                    VMName = $Name
                    Path = "$Path\$Name\$Name.vhdx"
                }
                Add-VMHardDiskDrive @AddVMHardDiskDrive

                $SetVMProcessor = @{
                    VMName                         = $Name
                    Count                          = $Count
                    ExposeVirtualizationExtensions = $ExposeVirtualizationExtensions
                }
                Set-VMProcessor @SetVMProcessor
                
                $SetVMNetworkAdapterVlan = @{
                    VMName = $Name
                    Access = $Access
                    VlanId = $VlanId
                }
                Set-VMNetworkAdapterVlan @SetVMNetworkAdapterVlan
                
                #$vmDVDDrive       = Get-VMDvdDrive -VMName $Name
                $vmNetworkAdapter = Get-VMNetworkAdapter -VMName $Name
                $vmHardDiskDrive  = Get-VMHardDiskDrive -VMName $Name
                $SetVMFirmware = @{
                    VMName              = $Name
                    BootOrder           = $vmNetworkAdapter, $vmHardDiskDrive
                    EnableSecureBoot    = $EnableSecureBoot
                    SecureBootTemplate  = $SecureBootTemplate
                }
                Set-VMFirmware @SetVMFirmware
                
                $SetVMKeyProtector = @{
                    VMName               = $Name
                    NewLocalKeyProtector = $NewLocalKeyProtector
                }
                Set-VMKeyProtector @SetVMKeyProtector
                
                $EnableVMTPM = @{
                    VMName = $Name
                }
                Enable-VMTPM @EnableVMTPM
                
                $EnableVMIntegrationService = @{
                   Name   = "Guest Service Interface", "Heartbeat", "Key-Value Pair Exchange", "Shutdown", "VSS"
                   VMName = $Name
                }
                Enable-VMIntegrationService @EnableVMIntegrationService
                
                $DisableVMIntegrationService = @{
                    Name   = $DisableVMIntegrationServiceName
                    VMName = $Name
                }
                Disable-VMIntegrationService @DisableVMIntegrationService
                
                $SetVM = @{
                    Name                        = $Name
                    DynamicMemory               = $DynamicMemory
                    MemoryMinimumBytes          = $MemoryMinimumBytes
                    MemoryMaximumBytes          = $MemoryMaximumBytes
                    MemoryStartupBytes          = $MemoryStartupBytes
                    AutomaticStartAction        = $AutomaticStartAction
                    AutomaticStopAction         = $AutomaticStopAction
                    AutomaticCheckpointsEnabled = $AutomaticCheckpointsEnabled
                    SnapshotFileLocation        = $SnapshotFileLocation
                    CheckpointType              = $CheckpointType
                }
                Set-VM @SetVM
                
                $SetVMVideo = @{
                    VMName               = $Name
                    HorizontalResolution = $HorizontalResolution
                    VerticalResolution   = $VerticalResolution
                }
                Set-VMVideo @SetVMVideo
            }
            catch {
                Write-Host 'Process - Catch'
                Write-Host "An error occurred:"
                Write-Host $_
                Write-Error -ErrorRecord $_ 
            }
            finally {
                Write-Host 'Process - Finally'
            }
        }
    }
    
    end {
        Write-Host 'End'
    }
}

New-HZChild