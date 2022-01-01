# On Windows, this will pop up a web-GUI to login with. On other OSes,
# it will ask you to open a browser separately with a code for logging in.
$az = Connect-AzAccount

# Save the subscription/tentant ID for later
#$subscriptionID = $az.Context.Subscription.Id
#$tenantID = $az.Context.Subscription.TenantId

$pArgs = @{
    AZSubscriptionId = $az.Context.Subscription.Id
    AZTenantId = $az.Context.Subscription.TenantId
    AZAppCred = (Get-Credential)
}
New-PACertificate example.com -Plugin Azure -PluginArgs $pArgs

Set-PAServer LE_STAGE
Install-Module -Name Posh-ACME -Scope AllUsers

New-PACertificate '*.Noobeh.net','Noobeh.net' -AcceptTOS -Contact 'Mryan@mendelsonconsulting.com' -Plugin Azure
    -PluginArgs $pArgs -Verbose




    ######endregion

    $certNames = '*.Noobeh.net','Noobeh.net'
    $email = 'Mryan@MendelsonConsulting.com'
    $pArgs = @{
        FDToken = (Read-Host 'FakeDNS API Token' -AsSecureString)
    }
    New-PACertificate $certNames -AcceptTOS -Contact $email -Plugin FakeDNS -PluginArgs $pArgs


    ###############

    # On Windows, this will pop up a web-GUI to login with. On other OSes,
# it will ask you to open a browser separately with a code for logging in.
$az = Connect-AzAccount

# Save the subscription/tentant ID for later
$subscriptionID = $az.Context.Subscription.Id
$tenantID = $az.Context.Subscription.TenantId

$roleDef = Get-AzRoleDefinition -Name "DNS Zone Contributor"
$roleDef.Id = $null
$roleDef.Name = "DNS TXT Contributor"
$roleDef.Description = "Manage DNS TXT records only."
$roleDef.Actions.RemoveRange(0,$roleDef.Actions.Count)
$roleDef.Actions.Add("Microsoft.Network/dnsZones/TXT/*")
$roleDef.Actions.Add("Microsoft.Network/dnsZones/read")
$roleDef.Actions.Add("Microsoft.Authorization/*/read")
$roleDef.Actions.Add("Microsoft.Insights/alertRules/*")
$roleDef.Actions.Add("Microsoft.ResourceHealth/availabilityStatuses/read")
$roleDef.Actions.Add("Microsoft.Resources/deployments/read")
$roleDef.Actions.Add("Microsoft.Resources/subscriptions/resourceGroups/read")
$roleDef.AssignableScopes.Clear()
$roleDef.AssignableScopes.Add("/subscriptions/$($az.Context.Subscription.Id)")

$role = New-AzRoleDefinition $roleDef
$role
#####################################endregion$notBefore = Get-Date
$notBefore = Get-Date
$notAfter = $notBefore.AddYears(10)

#Requires -RunAsAdministrator
$spParams = @{
    DisplayName = 'PoshACME'
    StartDate = $notBefore
    EndDate = $notAfter
    SkipAssignment = $true
}
$sp = New-AzADServicePrincipal @spParams
# For AZAppCred
$appCred = [pscredential]::new($sp.ApplicationId,$sp.Secret)

# For AZAppUsername and AZAppPasswordInsecure
$appUser = $appCred.UserName
$appPass = $appCred.GetNetworkCredential().Password