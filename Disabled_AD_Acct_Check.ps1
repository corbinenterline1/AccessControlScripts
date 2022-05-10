#TODO add a catch to document when an account doesn't exist
 
 
#Run Powershell as Non-Privileged Account
  
#Import CSV
#Make sure cell A1 says "Identity"
# Import-Module localaccount
param (
    [Parameter(Mandatory=$true)][string]$CSVPath = ""
)
   
$csv = Import-Csv -Path $CSVPath
Write-Host "Now Loading..."
  
#Loop through all items in the CSV
$AllAccounts = @()
ForEach ($row In $csv) 
{
    try #Attempts cmdlet below; if error, correlated exception catch is ran.
    {
        $AccountsList = Get-ADUser -Identity $row.Identity -Properties enabled, whenChanged, PasswordLastSet | Select-Object name,SamAccountName, enabled, whenChanged, PasswordLastSet
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        Write-Host ($row.Identity + " not found!") -BackgroundColor DarkRed
        Write-Host "Skipping row on CSV..."
        continue #Skips the rest of this iteration of the ForEach loop, so disabled account isn't written to output CSV.
    }
    foreach ($Account in $AccountsList) {
    $AllAccounts += [pscustomobject]@{
        AccountName = $row.Identity
        Name = $Account.Name
        SamAccountName = $Account.SamAccountName
        Enabled = $Account.enabled
        whenChanged = $Account.whenChanged
        PasswordLastSet = $Account.PasswordLastSet
        }
    }
}
  
Write-Host "Query Complete"
  
$AllAccounts | Export-Csv "$($env:USERPROFILE)\Documents\PSQueryResults_$(Get-Date -Format yyyy-MM-dd).csv" -NoTypeInformation
  
Write-Output "You can find the CSV export here $($env:USERPROFILE)\Documents\PSQueryResults_$(Get-Date -Format yyyy-MM-dd).csv"