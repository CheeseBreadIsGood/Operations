



$UserList = Import-Csv -Path C:\NoobehIT\ServerSetup\MISCsoftware\usernames.csv 
$pass = Read-Host "Enter Password for every user" -AsSecureString
foreach ($User in $UserList) {
   $User.FirstName = $User.FirstName  -replace '[^a-zA-Z0-9]', '' ##.trim()  ##Clear leading and trailing spaces
   $User.LastName  = $User.LastName -replace '[^a-zA-Z0-9]', '' ##.trim()  ##Clear leading and trailing spaces

     $Attributes = @{

        Enabled = $true
        ChangePasswordAtLogon = $false
        Path = "OU=CloudUsers,DC=Cloud,DC=local"

        State = "FL"
        Office = "Office"
        Title ="Standard User"
        Description = "Standard User"
        fax = 'Created from script'

        Name = "$($User.FirstName) $($User.LastName)"
        DisplayName = "$($User.FirstName) $($User.LastName)"
        UserPrincipalName = $User.FirstName.Substring(0,1) + $User.LastName + "@Cloud.local"
        SamAccountName = $User.FirstName.Substring(0,1) + $User.LastName

        GivenName = $User.FirstName
        Surname = $User.LastName

        AccountPassword = $pass
        
     }

  New-ADUser @Attributes
 #$Attributes
}
