#	Example PS script to create Teams from educationClass Template

#   Graph Namespace Description
#   https://docs.microsoft.com/en-us/graph/api/team-post?view=graph-rest-beta

#   Requires new application registration in AAD with credentials
#   https://docs.microsoft.com/pl-pl/azure/active-directory/develop/howto-create-service-principal-portal

#   Required permissions for Application
#   Application 	Group.ReadWrite.All

# To preserve diacritics (i.e. Polish) use UTF-8 BOM encoding with VScode editor

# function for invoke credential (valid for 1 hour)
function invokeAuthReq {
    # Application (client) ID, tenant Name and secret
    $clientId = "yourApplicationClientID"
    $tenantName = "yourTenant.onmicrosoft.com"
    $clientSecret = "yourApplicationClientSecret"
    $resource = "https://graph.microsoft.com/"


    $ReqTokenBody = @{
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        client_Id     = $clientID
        Client_Secret = $clientSecret
    }
 

    $TokenResponse = (Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody)
    return $TokenResponse
    start-sleep 10

}

#Function calling Ghraph API to create Team 
#Variable OwnerID must be provided as ObjectID attribute of existing Office 365 user i.e. '8b6b799c-3744-48c1-763b-995d59b5cc3a'
function callGraphTeamCreate {
    PARAM ([string]$DisplayName, [string]$Notes, [string]$OwnerID, [psobject]$Tokenresponse)

    #Create Teams from Goups via GRAPH API
    $apiUrl = 'https://graph.microsoft.com/beta/teams'    

    $json = @"
{
  `"template@odata.bind`": `"https://graph.microsoft.com/beta/teamsTemplates('educationClass')`",
  `"displayName`": `"$DisplayName`",
  `"description`": `"$Notes`",
  `"owners@odata.bind`": [`"https://graph.microsoft.com/beta/users('$OwnerID')`"],

    `"memberSettings`": {
        `"allowCreateUpdateChannels`": false,
        `"allowDeleteChannels`": false,
        `"allowAddRemoveApps`": false,
        `"allowCreateUpdateRemoveTabs`": false,
        `"allowCreateUpdateRemoveConnectors`": false
    }
}
"@
    $body = [System.Text.Encoding]::UTF8.GetBytes($json)
    Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)" } -Uri $apiUrl -Body $Body -Method Post -ContentType 'application/json; charset=utf-8'
    Start-Sleep 60 #Timeout to avoid requests trheshold
}

#   usage example

$myToken = invokeAuthReq

#Build PSobject with data input
$newTeams = @(
    [pscustomobject]@{teamDisplayName='Testowa (2022.A)';teamDescription='subject: Math | year: 2019 | class: D';teamOwner='admin@yourtenant.onmicrosoft.com';ownerObjectID='8b6b799c-3744-48c1-763b-995d59b5cc3a'}
    [pscustomobject]@{teamDisplayName='Testowa (2022.B)';teamDescription='subject: History | year: 2018 | class: A';teamOwner='admin@yourtenant.onmicrosoft.com';ownerObjectID='8b6b799c-3744-48c1-763b-995d59b5cc3a'}
    [pscustomobject]@{teamDisplayName='Testowa (2022.C)';teamDescription='subject: Geography | year: 2015 | class: C';teamOwner='admin@yourtenant.onmicrosoft.com';ownerObjectID='8b6b799c-3744-48c1-763b-995d59b5cc3a'}
)    

foreach ($newTeam in $newTeams) {
    callGraphTeamCreate $newTeam.teamDisplayName $newTeam.teamDescription $newTeam.ownerObjectID $myToken
}
