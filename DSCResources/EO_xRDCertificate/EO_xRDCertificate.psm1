if (
    [System.Environment]::OSVersion.Version -lt "6.2.9200.0"
) { 
    Throw "The minimum OS requirement was not met."
}

# The switch -Global is required, because otherwise
# the module is not available in called module scripts.
# E. g. when calling the Set-RDCertificate cmdlet,
# it calls the Get-RDServer from another script in the same module.
# This fails, if the RemoteDesktop module is not imported globally.

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
        [parameter(Mandatory)]
        [ValidateSet(
            "RDGateway",
            "RDWebAccess",
            "RDRedirector",
            "RDPublishing"
        )]
        [string] $Role,

        [parameter(Mandatory)]
        [string] $ImportPath,

        [parameter(Mandatory)]
        [pscredential] $Password,

        [string] $ConnectionBroker
    )

    $result = $null

    if ([string]::IsNullOrWhiteSpace($ConnectionBroker))  {
        $ConnectionBroker =  $localhost 
    }

    write-verbose `
        "Getting certificate for '$Role' from '$ConnectionBroker'..."    
        $cert = Get-RDCertificate `
            -ConnectionBroker $ConnectionBroker `
            -Role $Role

    if ($cert) {
        write-verbose `
            "The '$Role' certificate's level is $($cert.Level)"

            $result = 
            @{
                "ConnectionBroker" = $ConnectionBroker
                "Role" = $Role
                "ExpiresOn" = $cert.ExpiresOn
                "IssuedBy" = $cert.IssuedBy
                "Level" = $cert.Level
                "Subject" = $cert.Subject
                "SubjectAlternateName" = $cert.SubjectAlternateName
                "Thumbprint" = $cert.Thumbprint
            }
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
        [ValidateSet(
            "RDGateway",
            "RDWebAccess",
            "RDRedirector",
            "RDPublishing"
        )]
        [string] $Role,

        [parameter(Mandatory)]
        [string] $ImportPath,

        [parameter(Mandatory)]
        [pscredential] $Password,

        [string] $ConnectionBroker
    )

    if ([string]::IsNullOrWhiteSpace($ConnectionBroker))  { 
        $ConnectionBroker =  $localhost 
    }
    
    Write-Verbose `
        "Importing certificate $ImportPath for $Role..."
    Write-Verbose "calling Set-RDCertificate cmdlet..."
    Set-RDCertificate `
        -Role $Role `
        -ImportPath $ImportPath `
        -Password $Password.Password `
        -ConnectionBroker $ConnectionBroker `
        -Force
    write-verbose "Set-RDCertificate done."
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
        [ValidateSet(
            "RDGateway",
            "RDWebAccess",
            "RDRedirector",
            "RDPublishing"
        )]
        [string] $Role,

        [parameter(Mandatory)]
        [string] $ImportPath,

        [parameter(Mandatory)]
        [pscredential] $Password,

        [string] $ConnectionBroker
    )

    # Get thumbprint of pfx file

    $thumbprint = (
        Get-PfxData -FilePath $ImportPath
    ).EndEntityCertificates.Thumbprint

    write-verbose "Thumbprint of pfx file:  $thumbprint"

    $target = Get-TargetResource @PSBoundParameters

    write-verbose "Thumbprint of certificate for role $($Role):  $($target.Thumbprint)"

    $result = $target.Thumbprint -eq $thumbprint 
    
    write-verbose "Test-TargetResource returning:  $result"
    return $result
}


Export-ModuleMember -Function *-TargetResource
