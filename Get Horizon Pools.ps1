<#
.SYNOPSIS
    Get Omnissa Horizon Desktop Pools using the Horizon helper module

.PARAMETER connectionServer
    The Horizon Connection Server to connect to
    
.PARAMETER credentials
    Credentials for the connection to the Connection Server. Use Get-Credential to create or read from save CLIXML file for automation
    
.PARAMETER force
    Force the HZ connection. Use if get error "The SSL connection could not be established"

.PARAMETER horizonModules
    The module names to import

.EXAMPLE
    & '.\Get Horizon Pools.ps1' -connectionServer GLHVS22HZS01.guyrleech.local

    Fetch all pools from the Horizon Connection Server specified which will probazbly prompt for credentials

.NOTES
    Modification History:

    2025/02/04  @guyrleech  Script born
#>

[CmdletBinding()]

Param
(
    [string]$connectionServer = $env:COMPUTERNAME ,
    [PSCredential]$credentials ,
    [switch]$force ,
    [string[]]$horizonModules = @( 'Omnissa.VimAutomation.HorizonView' , 'Omnissa.Horizon.Helper' )
)

Import-Module -Name $horizonModules
if( -Not $? )
{
    Write-Warning -Message "Unable to import module $horizonModules - available at https://developer.omnissa.com/horizon-powercli/download/"
}

[hashtable]$connectionParameters = @{
    Server = $connectionServer
    Force = $force
}

if( $null -ne $credentials )
{
    $connectionParameters.Add( 'Credential' , $cred )
}

$connection = $null
$connection = Connect-HVServer @connectionParameters

if( $null -eq $connection )
{
    Throw "Failed to connect to $($connectionParameters.Server)"
}

try
{
    [array]$pools = @()
    $pools = @( Get-HVPool )
    Write-Verbose -Message "Got $($pools.Count) pools"
    $pools ## output to pipeline
}
catch
{
    Throw
}
finally
{
    if( $null -ne $connection )
    {
        Disconnect-HVServer -Force -Confirm:$false
    }
}
