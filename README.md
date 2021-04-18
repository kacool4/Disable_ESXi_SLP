# Disable ESXi Service for SLP and Firewall 
This is the work around for vmware SLP vulnerability that was announced on 23 Feb 2021

https://www.vmware.com/security/advisories/VMSA-2021-0002.html

## Scope:
 Script is performing the workaround for the vSphere ESXi according to VMware suggestions. It uses SSH session in order to log in to vSphere ESXi and execute all the necessary commands to stop SLP and disable Firewall for CIM SLP.
 
 
## Requirements:
- Windows Server 2012 and above, Windows 10
- Powershell 5.1 and above
- PowerCLI either standalone or import the module in Powershell (Preferred)
- vSphere ESXi version 6.X
- vSphere ESXi must be part of a vCenter and part of Domain
- Import Module Posh SSH
- (Optional) list.txt

## How it works
  It takes all the esxis from the vCenter or from the list.txt. Checks if the SSH service is enabled. If not it enables it. 
  Then using SSH session it will login automatically to each ESXi and use ESXCLI commands in order to perform the fix. When everything is done on that host it will close the session. Stop the SSH service and go the the next ESXi performing the same steps.


## Running the script

Open Powershell or Powercli and run the script. The scrpt will ask for vCenter FQDN, Domain account and domain Password in order to use them to login to vCenter and to ESXis via SSH.

```powershell
   PS> SLP_Disable.ps1
```

## Example

![Alt text](/screenshots/menu.jpg?raw=true "Run script")
 
 When you run the script it will load a menu. You can choose from there :
 1. All the hosts
     It will scan all the hosts that are connected to the vCenter
 
 2. Specified in the list.txt file
    You can choose this option in case you want to apply the workaround only to specific hosts. In order to use this option you must 
    put the FQDN of the hosts in the list.txt file. (one in each line)
 
 ## How to check the result
 In order to check if everything is ok log in to one of the ESXis via SSH and use the following commands
 
 ```esxcli
    esxcli network firewall ruleset list
 ```
 
 And search for this CIMSLP rule. It should be disabled <br/><br/>
 ![Alt text](/screenshots/fw.jpg?raw=true "FW Rule")

 You can also check the firewall rule from vCenter. Go to the ESXi -->Configuration --> Firewall --> Edit
 ![Alt text](/screenshots/esx.jpg?raw=true "FW Rule")
 
Then use this command to check status of SLP service
```esxcli
   /etc/init.d/slpd status
```
The output should be like that :<br/> <br/>
 ![Alt text](/screenshots/service.jpg?raw=true "Status")


## Frequetly Asked Questions:
* Will be there downtime during this activity?
   > No there is no downtime. The script changes the password while the ESXi is in production
   
* When I run the script it gives me a lot of SSH session errors.
   > You do not have the SSH module installed. In order to install it  run this command : <br/>
   ```powershell
   PS> Install-Module -Name Posh-SSH -Repository PSGallery -Verbose -Force
  ```   
* When I choose to run the workaround with specific ESXis it gives me a lot of error.
   > You need to type the FQDN to list.txt file without spaces,comma and one host per line.
     Correct way <br/>
     ![Alt text](/screenshots/correct.jpg?raw=true "Correct way")
   
   > Wrong way to add hosts<br/>
     ![Alt text](/screenshots/wrong.jpg?raw=true "Wrong way")
