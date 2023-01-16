Connect-AzAccount

$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

for ($i = 0; $i -lt $howManyVMs; $i++) {
    $VMName = Read-Host "$i - Enter a VM Name"
    $rgname = Read-Host "$i - Enter a Resource Group name"
    $rgIsNotCreated = true
    $RGLocation = "Eastus"
    $ImageVM = "Win2016Datacenter"
    $vmParams = @{
      ResourceGroupName = $rgname
      Name = $VMName
      Location = $RGLocation
      ImageName = $ImageVM
      PublicIpAddressName = 'PublicIp'
      Credential = $cred
      OpenPorts = 3389
    }
    
    if ((Get-AzResourceGroup -Name $rgname -ErrorVariable notPresent -ErrorAction SilentlyContinue).length -eq 1) {
        Write-Host "Resource Group called $rgname was found, $VMName will be created inside it." -ForegroundColor green
        New-AzVM @vmParams
    } else {
        New-AzResourceGroup -Name $rgname -Location $RGLocation
        Write-Host "Creating Resource Group $rgname..." -ForegroundColor green
        do {
            $wasCreated = (Get-AzResourceGroup -Name $rgname -ErrorVariable notPresent -ErrorAction SilentlyContinue).length
            if ($wasCreated -eq 1) {
                Write-Host "Resource Group $rgname was Created!" -ForegroundColor green
                $rgIsNotCreated = false
            } else {
                Write-Host "Wait a little bit more..." -ForegroundColor green
                Start-Sleep -Seconds 2
            }
        } while ($rgIsNotCreated)
        $newVM = New-AzVM @vmParams
    }   
}
