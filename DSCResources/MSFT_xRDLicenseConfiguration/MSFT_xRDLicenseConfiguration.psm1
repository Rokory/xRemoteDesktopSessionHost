if ([System.Environment]::OSVersion.Version -lt "6.2.9200.0") { Throw "The minimum OS requirement was not met."}

Import-Module RemoteDesktop


#######################################################################
# The Get-TargetResource cmdlet.
#######################################################################
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (    
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ConnectionBroker,
        
        [string[]] $LicenseServer,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("PerUser", "PerDevice", "NotConfigured")]
        [string] $Mode
    )

    $result = $null

    write-verbose "Getting RD License server configuration from broker '$ConnectionBroker'..."    
    
    $config = Get-RDLicenseConfiguration -ConnectionBroker $ConnectionBroker -ea SilentlyContinue

    if ($config)   # Microsoft.RemoteDesktopServices.Management.LicensingSetting
    {
        write-verbose "configuration retrieved successfully:"
    }
    else 
    {
        Write-Verbose "Failed to retrieve RD License configuration from broker '$ConnectionBroker'."
        throw ("Failed to retrieve RD License configuration from broker '$ConnectionBroker'.")
    }

    $result = 
    @{
        "ConnectionBroker" = $ConnectionBroker
        "LicenseServer" = $config.LicenseServer          
        "Mode" = $config.Mode.ToString()  # Microsoft.RemoteDesktopServices.Management.LicensingMode  .ToString()
    }

    write-verbose ">> RD License mode:     $($result.Mode)"
    write-verbose ">> RD License servers:  $($result.LicenseServer -join '; ')"
 
    $result
}


######################################################################## 
# The Set-TargetResource cmdlet.
########################################################################
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (    
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ConnectionBroker,
        
        [string[]] $LicenseServer,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("PerUser", "PerDevice", "NotConfigured")]
        [string] $Mode
    )
    
    write-verbose "Starting RD License server configuration..."
    write-verbose ">> RD Connection Broker:  $($ConnectionBroker.ToLower())"

    Set-RDLicenseConfiguration @PSBoundParameters -Force

    write-verbose "Set-RDLicenseConfiguration done."
}


#######################################################################
# The Test-TargetResource cmdlet.
#######################################################################
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (    
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ConnectionBroker,
        
        [string[]] $LicenseServer,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("PerUser", "PerDevice", "NotConfigured")]
        [string] $Mode
    )

    $config = Get-TargetResource @PSBoundParameters
    
    if ($config)
    {
        $result = $true

        write-verbose "verifying RD Licensing mode..."
        if ($config.Mode -ne $Mode) {
            Write-Verbose "Current license mode $($config.Mode) not equal to desired license mode $Mode"
            $result = $false
        }

        Write-Verbose "verifying license servers..."

        $LicenseServer | ForEach-Object {
            if ($config.LicenseServer -notcontains $PSItem) {
                Write-Verbose "$PSItem not configured as license server"
                $result = $false
            }
        }

        $config.LicenseServer | ForEach-Object {
            if ($LicenseServer -notcontains $PSItem) {
                Write-Verbose "$PSitem is a license server, but should not be"
                $result = $false
            }
        }
    }
    else
    {
        write-verbose "Failed to retrieve RD License server configuration from broker '$ConnectionBroker'."
        $result = $false
    }

    write-verbose "Test-TargetResource returning:  $result"
    return $result
}


Export-ModuleMember -Function *-TargetResource
