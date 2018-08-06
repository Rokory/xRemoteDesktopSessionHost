Import-Module -Name "$PSScriptRoot\..\..\xRemoteDesktopSessionHostCommon.psm1"
if (!(Test-xRemoteDesktopSessionHostOsRequirement)) { Throw "The minimum OS requirement was not met."}

# The switch -Global is required, because otherwise
# the module is not available in called module scripts.

Import-Module RemoteDesktop -Global

#######################################################################
# The Get-TargetResource cmdlet.
#######################################################################
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $ClientAccessName,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker,
        [Parameter(Mandatory = $true)]
        [string] $DatabaseConnectionString
    )

    write-verbose `
        "Getting high availability configuration from broker '$ConnectionBroker'..."

    $config = Get-RDConnectionBrokerHighAvailability `
        -ConnectionBroker $this.ConnectionBroker `
        -ErrorAction SilentlyContinue

    if ($config) {
        write-verbose "configuration retrieved successfully:"

        @{
            "ClientAccessName" = $config.ClientAccessName
            "ConnectionBroker" = $ConnectionBroker
            "DatabaseConnectionString" = $config.DatabaseConnectionString
        }
    }
    else {
        write-verbose "Failed to retrieve high availability configuration from broker '$ConnectionBroker'."
    }
}


########################################################################
# The Set-TargetResource cmdlet.
########################################################################
function Set-TargetResource

{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "global:DSCMachineStatus")]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $ClientAccessName,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker,
        [Parameter(Mandatory = $true)]
        [string] $DatabaseConnectionString
    )

    write-verbose "Starting high availability configuration..."
    write-verbose ">> RD Connection Broker:  $($ConnectionBroker.ToLower())"

    Write-Verbose "calling Set-RDConnectionBrokerHighAvailability cmdlet..."
    Set-RDConnectionBrokerHighAvailability `
        -ConnectionBroker $ConnectionBroker `
        -ClientAccessName $ClientAccessName `
        -DatabaseConnectionString $DatabaseConnectionString
    Write-Verbose "Set-RDConnectionBrokerHighAvailability done."
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
        [Parameter(Mandatory = $true)]
        [string] $ClientAccessName,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker,
        [Parameter(Mandatory = $true)]
        [string] $DatabaseConnectionString
    )
    $config = Get-TargetResource @PSBoundParameters
    
    if ($config)
    {
        write-verbose "verifying client access name..."

        $result = ($config.ClientAccessName -eq $ClientAccessName)

        write-verbose "verifying database connection string..."
        
        $result = $result -and `
            ($config.DatabaseConnectionString -eq $DatabaseConnectionString)
    }
    else
    {
        write-verbose "Failed to retrieve RD connection broker high availability configuration from broker '$ConnectionBroker'."
        $result = $false
    }

    write-verbose "Test-TargetResource returning:  $result"
    return $result

}


Export-ModuleMember -Function *-TargetResource

