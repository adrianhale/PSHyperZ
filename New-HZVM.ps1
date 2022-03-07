function New-HZVM {

    <#
.SYNOPSIS
    Creates a new virtual machine.
.DESCRIPTION
    Creates a new virtual machine by booting from attached ISO. Recommended for creating a new golden image.
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
        #New-VM
        [string]$Name                            = "Test",
        [boolean]$NoVHD                          = $true,
        [string]$SwitchName                      = "External Virtual Switch",
        [string]$Path                            = "D:\Hyper-Z",
        [version]$Version                        = "10.0",
        [int16]$Generation                       = 2,

        #Set-VMProcessor
        [string]$VMName                          = "Test",
        [int64]$Count                            = 4,
        [boolean]$ExposeVirtualizationExtensions = $true,

        #New-VHD
        [uint64]$SizeBytes                       = 512GB,
        [boolean]$Dynamic                        = $true,

        #Add-VMDvdDrive
        [string]$ISOPath                         = "D:\ISOs\windows_server_2012_r2_evaluation.iso",

        #Set-VMNetworkAdapterVlan
        [boolean]$Access                         = $true,
        [int32]$VlanId                           = 4094,

        #Set-VMFirmware
        [string]$EnableSecureBoot                = "On",
        [string]$SecureBootTemplate              = "MicrosoftWindows",

        #Set-VMKeyProtector
        [boolean]$NewLocalKeyProtector           = $true,

        #Enable-VMTPM

        #Enable-VMIntegrationService
        [string]$EnableVMIntegrationServiceName  = "Guest Service Interface",

        #Disable-VMIntegrationService
        [string]$DisableVMIntegrationServiceName = "Time Synchronization",

        #Set-VM
        [int64]$MemoryMinimumBytes               = 512MB,
        [int64]$MemoryMaximumBytes               = 8GB,
        [int64]$MemoryStartupBytes               = 4GB,
        [string]$AutomaticStartAction            = "Nothing",
        [string]$AutomaticStopAction             = "Shutdown",
        [boolean]$AutomaticCheckpointsEnabled    = $false,
        [string]$SnapshotFileLocation            = "$Path\$VMName\Checkpoints",
        [string]$CheckpointType                  = "Production",

        #Set-VMVideo
        [uint16]$HorizontalResolution            = 1920,
        [uint16]$VerticalResolution              = 1080
    )
    
    begin {

    }

    process {
        foreach ($VM in $VMName) {
            try {
                $NewVM = @{
                    Name       = $Name
                    NoVHD      = $NoVHD
                    SwitchName = $SwitchName
                    Path       = $Path
                    Version    = $Version
                    Generation = $Generation
                }
                New-VM @NewVM

                $SetVMProcessor = @{
                    VMName                         = $VMName
                    Count                          = $Count
                    ExposeVirtualizationExtensions = $ExposeVirtualizationExtensions
                }
                Set-VMProcessor @SetVMProcessor

                $NewVHD = @{
                    Path      = "$Path\$Name\$Name.vhdx"
                    SizeBytes = $SizeBytes
                    Dynamic   = $Dynamic
                }
                New-VHD @NewVHD
                
                $AddVMHardDiskDrive = @{
                    VMName = $VMName
                    Path   = "$Path\$Name\$Name.vhdx"
                }
                Add-VMHardDiskDrive @AddVMHardDiskDrive

                $AddVMDvdDrive = @{
                    VMName = $VMName
                    Path   = $ISOPath
                }
                Add-VMDvdDrive @AddVMDvdDrive
                
                $SetVMNetworkAdapterVlan = @{
                    VMName = $VMName
                    Access = $Access
                    VlanId = $VlanId
                }
                Set-VMNetworkAdapterVlan @SetVMNetworkAdapterVlan
                
                $vmDVDDrive       = Get-VMDvdDrive -VMName $VMName
                $vmNetworkAdapter = Get-VMNetworkAdapter -VMName $VMName
                $vmHardDiskDrive  = Get-VMHardDiskDrive -VMName $VMName
                $SetVMFirmware = @{
                    VMName              = $VMName
                    BootOrder           = $vmDVDDrive, $vmNetworkAdapter, $vmHardDiskDrive
                    EnableSecureBoot    = $EnableSecureBoot
                    SecureBootTemplate  = $SecureBootTemplate
                }
                Set-VMFirmware @SetVMFirmware
                
                $SetVMKeyProtector = @{
                    VMName               = $VMName
                    NewLocalKeyProtector = $NewLocalKeyProtector
                }
                Set-VMKeyProtector @SetVMKeyProtector
                
                $EnableVMTPM = @{
                    VMName = $VMName
                }
                Enable-VMTPM @EnableVMTPM
                
                $EnableVMIntegrationService = @{
                   Name   = $EnableVMIntegrationServiceName
                   VMName = $VMName
                }
                Enable-VMIntegrationService @EnableVMIntegrationService
                
                $DisableVMIntegrationService = @{
                    Name   = $DisableVMIntegrationServiceName
                    VMName = $VMName
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
                    VMName               = $VMName
                    HorizontalResolution = $HorizontalResolution
                    VerticalResolution   = $VerticalResolution
                }
                Set-VMVideo @SetVMVideo
            }
            catch {
                Write-Host "An error occurred:"
                Write-Host $_
                Write-Error -ErrorRecord $_ 
            }
            finally {
                Write-Host "Success"
            }
        }
    }

    end {
        Write-Host "Completed"
    }
}

New-HZVM