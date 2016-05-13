. .\NetScalerConfiguration.ps1

Trace-VstsEnteringInvocation $MyInvocation
try{
    [string]$NSAddress = Get-VstsInput -Name NSAddress
    [string]$ServiceNames = Get-VstsInput -Name ServiceNames
    [string]$Action = Get-VstsInput -Name Action
    [string]$NSUserName = Get-VstsInput -Name NSUserName
    [string]$NSPassword = Get-VstsInput -Name NSPassword
    [string]$NSProtocol = Get-VstsInput -Name NSProtocol
    [string]$GracefulShutdown = Get-VstsInput -Name GracefulShutdown
    [int]$GraceFulShutdownDelay = Get-VstsInput -Name GraceFulShutdownDelay -AsInt
    [switch]$SkipCACheck = Get-VstsInput -Name SkipCACheck -AsBool

    Write-Verbose $NSAddress
    Write-Verbose $ServiceNames 
    Write-Verbose $Action
    Write-Verbose $NSUserName
    Write-Verbose $NSPassword 
    Write-Verbose $NSProtocol 
    Write-Verbose $GracefulShutdown 
    Write-Verbose $GraceFulShutdownDelay 
    Write-Verbose $SkipCACheck 

    if ($SkipCACheck){
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    }

    Set-NSMgmtProtocol -Protocol $NSProtocol
    $myNSSession = Connect-NSAppliance -NSAddress $NSAddress -NSUserName $NSUserName -NSPassword $NSPassword
    
    foreach ($ServiceName in  ($ServiceNames -split '\n' | where-object {$_ -ne " "} ) ) {
        Write-Verbose $ServiceName
        $payload = @{
            name=$ServiceName
            }
        if($Action -eq "Disable") {
            $payload = @{
                name=$ServiceName;
                graceful=$GracefulShutdown;
                delay=$GraceFulShutdownDelay
                }
        }
        Invoke-NSNitroRestApi -NSSession $myNSSession -OperationMethod POST -ResourceType service -Payload $payload -Action $Action
    }

} finally {
    Disconnect-NSAppliance -NSSession $myNSSession
    Trace-VstsLeavingInvocation $MyInvocation
}