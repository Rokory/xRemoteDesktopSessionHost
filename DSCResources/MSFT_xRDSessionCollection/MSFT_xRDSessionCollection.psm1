Import-Module -Name "$PSScriptRoot\..\..\xRemoteDesktopSessionHostCommon.psm1"
if (!(Test-xRemoteDesktopSessionHostOsRequirement)) { Throw "The minimum OS requirement was not met."}

# The switch -Global is required, because otherwise
# the module is not available in called module scripts.

Import-Module RemoteDesktop -Global

$localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName

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
        [ValidateLength(1,15)]
        [string] $CollectionName,
        [Parameter(Mandatory = $true)]
        [string[]] $SessionHost,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter()]
        [string] $ConnectionBroker
    )
    Write-Verbose "Getting information about RDSH collection."
    $collection = Get-RDSessionCollection `
        -CollectionName $CollectionName `
        -ErrorAction SilentlyContinue
    
    if ($collection -ne $null) {
        $sessionHosts = (
            Get-RDSessionHost `
                -ConnectionBroker $ConnectionBroker `
                -CollectionName $CollectionName `
                -ErrorAction SilentlyContinue
        ).SessionHost
        $result = @{
            "CollectionName" = $collection.CollectionName;
            "CollectionDescription" = $collection.CollectionDescription
            "SessionHosts" = $sessionHosts
            "ConnectionBroker" = $ConnectionBroker
        }
    }

    return $result
}


######################################################################## 
# The Set-TargetResource cmdlet.
########################################################################
function Set-TargetResource

{
    [CmdletBinding()]
    param
    (    
        [Parameter(Mandatory = $true)]
        [ValidateLength(1,15)]
        [string] $CollectionName,
        [Parameter(Mandatory = $true)]
        [string[]] $SessionHost,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter()]
        [string] $ConnectionBroker
    )

    if ([string]::IsNullOrWhiteSpace($ConnectionBroker)) {
        $ConnectionBroker = $localhost
    }

    Write-Verbose "Checking for existence of RDSH collection."
    $config = Get-TargetResource @PSBoundParameters

    if ($config -eq $null -or $config.CollectionName -eq $null) {
        Write-Verbose "Creating new RDSH collection."
        New-RDSessionCollection @PSBoundParameters
    }
    else {
        Write-Verbose "Checking for session hosts to be added"
        foreach ($item in $SessionHost) {
            if ($config.SessionHosts -notcontains $item) {
                Write-Verbose "Adding $item as session host to session collection $CollectionName"
                Add-RDSessionHost `
                    -CollectionName $CollectionName `
                    -SessionHost $item `
                    -ConnectionBroker $ConnectionBroker
            }
        }
    }

    Write-Verbose "Checking for session hosts to be removed"
    foreach ($item in $config.SessionHosts) {
        if ($SessionHost -notcontains $item) {
            Write-Verbose "Removing $item as session host from session collection $CollectionName"
            Remove-RDsessionHost `
                -CollectionName $CollectionName `
                -SessionHost $item `
                -ConnectionBroker $ConnectionBroker
        }
    }

    if ($config.CollectionDescription -ne $CollectionDescription)
    {
        Set-RDSessionCollectionConfiguration `
            -ConnectionBroker $ConnectionBroker `
            -CollectionName $CollectionName `
            -CollectionDescription $CollectionDescription
    }
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
        [ValidateLength(1,15)]
        [string] $CollectionName,
        [Parameter(Mandatory = $true)]
        [string[]] $SessionHost,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter()]
        [string] $ConnectionBroker
    )

    $result = $false
    Write-Verbose "Checking for existence of RDSH collection."
    $config = Get-TargetResource @PSBoundParameters
    if ($config -and $config.CollectionName) {
        $result = $config.$CollectionDescription -eq $CollectionDescription
        foreach ($item in $SessionHost) {
            $result = $result -and ($config.SessionHost -contains $item)
        }
        foreach ($item in $config.SessionHost) {
            $result = $result -and ($SessionHost -contains $item)
        }
    }
    return $result
}


Export-ModuleMember -Function *-TargetResource

