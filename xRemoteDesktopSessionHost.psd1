@{
# Version number of this module.
moduleVersion = '1.8.0.0'

# ID used to uniquely identify this module
GUID = '162cb569-16e0-4513-84db-40036a55425d'

# Author of this module
Author = 'Microsoft Corporation, Roman Korecky'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation, Easy On'

# Copyright statement for this module
Copyright = '(c) 2018 Easy On - Roman Korecky EDV-Dienstleistungen. All rights reservers. Includedes parts with (c) 2014 Microsoft Corporation. All rights reserved. (c'

# Description of the functionality provided by this module
Description = 'Module with DSC Resources for Remote Desktop Session Host'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

RootModule = 'xRemoteDesktopSessionHostCommon.psm1'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResource')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/Rokory/xRemoteDesktopSessionHost/blob/dev/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/Rokory/xRemoteDesktopSessionHost/blob'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '* Added resource xRDConnectionBrokerhighAvailability
        * Added resource xRDCertificate
        * Changes in xRDGatewayConfiguration
          * Removed property GatewayServer
          * Renamed poperty ExternalFqdn to GatewayExternalFqdn
          * Checking BypassLocal property in Test-TargetResource
        * Changes in xRDLicenseConfiguration
          * Renamed property LicenseMode parameter to Mode to conform with original Set-RDLicenseConfiguration parameter name and simplify the Set-TargetResource cmdlet.
          * Test-TargetResource checks LicenseServer property.
        * Changes in xRDSesionCollection
          * Property SessionHost is not a key anymore and is an array, so that more session hosts can be configured at creation time
          * Get-TargetResource gives more information about the current status of the resource
          * Set-TargetResource checks for existence of the collection and configures other properties, if necessary.
          * Test-TargetResource not only checks for existence of the collection, but also for the other properties provided.
        * Changes to xRDServer
          * Property Role is key to allow multiple instances of the resource for the same server but for different roles.
        * Changes to xRDSessionDeployment
          * Fixed issue where an initial deployment failed due to a convert to lowercase (issue #39).
          * Added unit tests to test Get, Test and Set results in this resource.
          * Changed property SessionHost to string array
          * Removed obligatory reboot
          * Fix for "Cannot find any service with service name RDMS." error message.
        * Change to xRDRemoteApp
          * Fixed issue where this resource ignored the CollectionName provided in the parameters (issue #41).
          * Changed key values in schema.mof to only Alias and CollectionName, DisplayName and FilePath are not key values.
          * Added Ensure property (Absent or Present) to enable removal of RemoteApps.
          * Added unit tests to test Get, Test and Set results in this resource.
        '

    } # End of PSData hashtable

} # End of PrivateData hashtable
}





