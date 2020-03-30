# This script restricts users from creating new Microsoft Teams & Office 365 group.
# Only members of $GroupName variable value are allowed to create groups

# The original script was published in the following article:
# Title: How to Restrict Users from Creating new Microsoft Teams and Office 365 Groups 
# URL: http://www.thatlazyadmin.com/how-to-restrict-users-from-creating-new-microsoft-teams-and-office-365-groups/

# Requirements: PowerShell module AzureADPreview
# Install-Module -Name AzureADPreview 

# Set group name with permission to create Teams & Office 365 groups
$GroupName = 'AllowedToCreateGroups'
# Set owner of privileged group
$GroupOwner = 'admin@yourTenant.onmicrosoft.com'
# Set members of privileged group 
$GroupMembers = ('user1@yourTenant.onmicrosoft.com','user2@yourTenant.onmicrosoft.com','user2@yourTenant.onmicrosoft.com')
# New Group with permission to create Teams & Office 365 groups

# Enable/Disable switch for all Users
$AllowGroupCreation = "False"

#assign Office 365 admin credentials to variable
$creds = Get-Credential

Import-Module AzureADPreview 
Connect-AzureAD -Credential $creds

#Create security group to control who can create new Office 365 Groups, set owner and members
if(!(Get-AzureADGroup -SearchString $GroupName)) {
$Response = New-AzureADGroup -DisplayName $GroupName -Description "Group with permission to create Teams & Office 365 groups" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet" 
Add-AzureADGroupOwner -ObjectId $Response.ObjectId -RefObjectId (Get-AzureADUser -ObjectId $GroupOwner).ObjectId
$GroupMembers | foreach {(Get-AzureADUser -ObjectId $_).ObjectId} | foreach {Add-AzureADGroupMember -ObjectId $Response.ObjectId -RefObjectId $_}
} else {write-host "Group already exists !"}

#Setting AAD groups creation
$settingsObjectID = (Get-AzureADDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).id
if (!$settingsObjectID) {
    $template = Get-AzureADDirectorySettingTemplate | Where-object { $_.displayname -eq "group.unified" }
    $settingsCopy = $template.CreateDirectorySetting()
    New-AzureADDirectorySetting -DirectorySetting $settingsCopy
    $settingsObjectID = (Get-AzureADDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).id
}

$settingsCopy = Get-AzureADDirectorySetting -Id $settingsObjectID
$settingsCopy["EnableGroupCreation"] = $AllowGroupCreation

if ($GroupName) {
    $settingsCopy["GroupCreationAllowedGroupId"] = (Get-AzureADGroup -SearchString $GroupName).objectid
}

Set-AzureADDirectorySetting -Id $settingsObjectID -DirectorySetting $settingsCopy

(Get-AzureADDirectorySetting -Id $settingsObjectID).Values
