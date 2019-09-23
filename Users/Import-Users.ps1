$UserList = Import-Csv -Path C:\names\usernames.csv 

foreach ($User in $UserList) {

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

        AccountPassword = 'Cloud##123$$' | ConvertTo-SecureString -AsPlainText -Force

     }

  New-ADUser @Attributes
 #$Attributes
}
