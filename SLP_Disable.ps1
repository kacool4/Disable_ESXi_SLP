## Script that Disables the SLP from all ESXis and set the start up policy to "Start and stop Manually"
Write-Output "Give FQDN of the vCenter"
$vcenter = Read-Host "FQDN "
$DUSR = Read-Host "Provide Domain account "
$PSW = Read-Host "Provide Domain Password "

Write-Output "Connecting to vCenter... Please wait"
Connect-VIServer -Server $vcenter -User $DUSR -Password $PSW

Write-Output "Select which ESXis should be fixed"
Write-Output " 1. All the hosts"
Write-Output " 2. Specified in list.txt file"
Write-Output " 3. Exit"
Write-Output " ----------------------------------"

do{
$opt = Read-Host " Option "
}while($opt -notin 1,2,3)

## Getting all the ESXis from the vCenter
if ($opt -eq '1') {
    $Get_esxi = Get-VMHost  | Select -ExpandProperty name
    Write-Output "Please wait while task is in progress..."
} elseif ($opt -eq '2'){
    $Get_esxi = Get-Content -path .\list.txt
} elseif ($opt -eq '3'){
    exit
} 


## Getting each ESXi name in order to perform the work around

foreach($esxi in $Get_esxi){
   $esxName = $esxi

$esx = Get-VMHost -Name $esxName

## Check for SSH status
$ssh_service = Get-VMHostService -VMHost $esx | where{$_.Key -eq 'TSM-SSH'} |select -ExpandProperty running

## Set of commands to be performed after script logs in via SSH session
$cmdsub = @'
/etc/init.d/slpd stop;
/etc/init.d/slpd status;
esxcli network firewall ruleset set -r CIMSLP -e 0;
chkconfig slpd off;
chkconfig --list | grep slpd;
'@

## Set the password for the domain user in order to access the ESXi via ssh 
$secPswd = ConvertTo-SecureString $PSW -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($DUSR, $secPswd)

## Checking Service status and run it in case it is stopped.
if (-not $ssh_service) {
       Get-VMHostService -VMHost $esx | where{$_.Key -eq 'TSM-SSH'} | Start-VMHostService -Confirm:$false | Out-Null
}


## Login session
$session = New-SSHSession -ComputerName $esx.Name -Credential $cred -AcceptKey

## Execute a set of commands
Invoke-SSHCommand -SSHSession $session -Command $cmdSub | Select -ExpandProperty Output

## Close session
Remove-SSHSession -SSHSession $session | Out-Null

## Stop SSH service
Get-VMHostService -VMHost $esx | where{$_.Key -eq 'TSM-SSH'} | Stop-VMHostService -Confirm:$false | Out-Null
}

Write-Output "Task is completed."
