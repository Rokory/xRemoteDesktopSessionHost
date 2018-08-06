if ([System.Environment]::OSVersion.Version -lt "6.2.9200.0") { Throw "The minimum OS requirement was not met."}

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
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ConnectionBroker,
        
        [ValidateNotNullOrEmpty()]
        [string] $GatewayExternalFqdn,

        [ValidateSet("DoNotUse","Custom","Automatic")]
        [string] $GatewayMode,

        [ValidateSet("Password","Smartcard","AllowUserToSelectDuringConnection")]
        [string] $LogonMethod,

        [bool] $UseCachedCredentials,
        [bool] $BypassLocal
    )


    $result = $null

    write-verbose "Getting RD Gateway configuration from broker '$ConnectionBroker'..."    
    
    $config = Get-RDDeploymentGatewayConfiguration -ConnectionBroker $ConnectionBroker -ea SilentlyContinue

    if ($config)
    {
        write-verbose "configuration retrieved successfully:"

        write-verbose ">> RD Gateway mode:       $($config.GatewayMode)"

        $result = 
        @{
            "ConnectionBroker" = $ConnectionBroker
            "GatewayMode"      = $config.Gatewaymode.ToString()   # Microsoft.RemoteDesktopServices.Management.GatewayUsage  .ToString()
        }

        $result.GatewayExternalFqdn  = $config.GatewayExternalFqdn
        $result.LogonMethod          = $config.LogonMethod
        $result.UseCachedCredentials = $config.UseCachedCredentials
        $result.BypassLocal          = $config.BypassLocal

        write-verbose ">> GatewayExternalFqdn:   $($result.GatewayExternalFqdn)"
        write-verbose ">> LogonMethod:           $($result.LogonMethod)"
        write-verbose ">> UseCachedCredentials:  $($result.UseCachedCredentials)"
        write-verbose ">> BypassLocal:           $($result.BypassLocal)"
    }
    else
    {
        write-verbose "Failed to retrieve RD Gateway configuration from broker '$ConnectionBroker'."
    }

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
        
        [ValidateSet("DoNotUse","Custom","Automatic")]
        [string] $GatewayMode,

        [string] $GatewayExternalFqdn,

        [ValidateSet("Password","Smartcard","AllowUserToSelectDuringConnection")]
        [string] $LogonMethod,

        $UseCachedCredentials,
        $BypassLocal
    )

    write-verbose "Starting RD Gateway configuration for the RD deployment at broker '$ConnectionBroker'..."
    write-verbose "calling Set-RdDeploymentGatewayConfiguration cmdlet..."

    write-verbose ">> requested GatewayMode:  $GatewayMode"
    write-verbose ">> GatewayExternalFqdn:   '$ExternalFqdn'"
    write-verbose ">> LogonMethod:           '$LogonMethod'"
    write-verbose ">> UseCachedCredentials:  $UseCachedCredentials"
    write-verbose ">> BypassLocal:           $BypassLocal"
    Set-RdDeploymentGatewayConfiguration @PSBoundParameters -force

    write-verbose "Set-RdDeploymentGatewayConfiguration done."
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
        
        [ValidateNotNullOrEmpty()]
        [string] $GatewayExternalFqdn,

        [ValidateSet("DoNotUse","Custom","Automatic")]
        [string] $GatewayMode,

        [ValidateSet("Password","Smartcard","AllowUserToSelectDuringConnection")]
        [string] $LogonMethod,

        [bool] $UseCachedCredentials,
        [bool] $BypassLocal
    )


    $config = Get-TargetResource @PSBoundParameters
    
    if ($config)
    {
        write-verbose "verifying RD Gateway usage name..."
        $result =  ($config.GatewayMode -ieq $GatewayMode) `
            -and ($config.GatewayExternalFqdn -ieq $GatewayExternalFqdn) `
            -and ($config.LogonMethod -ieq $LogonMethod) `
            -and ($config.UseCachedCredentials -ieq $UseCachedCredentials) `
            -and ($config.BypassLocal -ieq $BypassLocal)
    }
    else
    {
        write-verbose "Failed to retrieve RD Gateway configuration."
        $result = $false
    }

    write-verbose "Test-TargetResource returning:  $result"
    return $result
}


Export-ModuleMember -Function *-TargetResource
