
. "$PSScriptRoot\Connect-Mstsc.ps1"


function Login()
{
    $profileSettingsFile = Get-Item (join-path (Get-Location)  "glenn.azureprofile")
    if($profileSettingsFile.Exists)
    {
        Write-Host "Found settingsfile, logging in"
        $account = Select-AzureRmProfile -path $profileSettingsFile.FullName
        Write-Host "$($account.Context.Account) logged in..."
        
        $subscription = Get-AzureRmSubscription
        Write-Host "Active subscription: $($subscription.SubscriptionName) ($($subscription.SubscriptionId))"
    }
    else
    {
        Add-AzureRmAccount   
    }    
}

function ListVMs()
{
    Write-Host "Found VMs:"
    Write-Host (Get-AzureRmVM).Name
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
    
}

function ConnectRDP($vmName, $user, $passWord)
{    
    $ip = (Get-AzureRmPublicIpAddress -Name $vmName -ResourceGroupName $vmName).IpAddress 
    Connect-Mstsc $ip  $user $password    
}


    
Write-Host "Devtool started"
Login
ListVMs
#ShutOff "dev"
#SwitchOn "dev"
ConnectRDP "dev" "Glenn" "password"


