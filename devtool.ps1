
. "$PSScriptRoot\Connect-Mstsc.ps1"


function Login()
{
    $settingsFilePath = join-path (Get-Location)  "glenn.azureprofile"
    $settingsFileExists = Test-Path $settingsFilePath
    
    if($settingsFileExists)
    {
        Write-Host "Found settingsfile, logging in"
        $account = Select-AzureRmProfile -path $settingsFilePath
        Write-Host "$($account.Context.Account) logged in..."                                           
    }
    else
    {        
        Add-AzureRmAccount                        
        Save-AzureRmProfile -Path $settingsFilePath                                 
    }    
}

function WriteAzureSubscriptionInfo()
{                
    $subscription = Get-AzureSubscription
    Write-Host "Active subscription: $($subscription.SubscriptionName) ($($subscription.SubscriptionId))"
}

function ListVMs()
{
    Write-Host "Found VMs:"
    Write-Host (Get-AzureRmVm).Name
}

function ShutOff($vmName)
{    
    $vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $vmName -Status
    Write-Host "$($vm.Name) found"
    if($vm.Statuses | where Code -match "PowerState/running")
    {
        Write-Host "$($vm.Name) is running, shutting down..."
        Stop-AzureRmVM -Name $vmName -ResourceGroupName $vmName -Force  
    }
    else
    {
        Write-Warning "$($vm.Name) is is already shut off"
    }
    
}

function SwitchOn($vmName)
{    
    $vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $vmName -Status
    Write-Host "$($vm.Name) found"
    if($vm.Statuses | where Code -match "PowerState/deallocated")
    {
        Write-Host "$($vm.Name) is not running, starting..."
        Start-AzureRmVM -Name $vmName -ResourceGroupName $vmName          
    }
    else
    {
        Write-Warning "$($vm.Name) is is already running"
    }
    return $vmName
    
}

function ConnectRDP($vmName, $user, $passWord)
{    
    $ip = (Get-AzureRmPublicIpAddress -Name $vmName -ResourceGroupName $vmName).IpAddress 
    Connect-Mstsc $ip  $user $password    
}


function InstallAzureCommands()
{
   # Install the Azure Resource Manager modules from the PowerShell Gallery
    Install-Module AzureRM
    Install-AzureRM

    # Install the Azure Service Management module from the PowerShell Gallery
    Install-Module Azure

    # Import AzureRM modules for the given version manifest in the AzureRM module
    Import-AzureRM

    # Import Azure Service Management module
    Import-Module Azure
}

function IsAzureCommandsInstalled()
{
    Get-Module -ListAvailable | where -Match -Value "Azure" -Property "Name"
}
    
Write-Host "Devtool started"
#InstallAzureCommands
Login
#WriteAzureSubscriptionInfo 
#ListVMs
#ShutOff "dev"
#SwitchOn "dev"
#ConnectRDP "dev" "Glenn" "password"

#ConnectRDP  $(SwitchOn "dev")  "Glenn"  "password"
ShutOff "dev"
 


