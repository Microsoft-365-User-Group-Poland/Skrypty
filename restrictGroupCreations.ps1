# This script restricts users from creating new Microsoft Teams & Office 365 group.
# Only members of $GroupName variable value are allowed to create groups

# The original script was published in with following article:
# How to Restrict Users from Creating new Microsoft Teams and Office 365 Groups 
# http://www.thatlazyadmin.com/how-to-restrict-users-from-creating-new-microsoft-teams-and-office-365-groups/

# Requirements: PowerShell modules AzureADPreview ans MSOnline

# Example owner of group
$GroupOwner = 'admin@yourTenant.onmicrosoft.com'
# Example members of goups 
$GroupMembers = ('user1@yourTenant.onmicrosoft.com','user2@yourTenant.onmicrosoft.com','user2@yourTenant.onmicrosoft.com')
# New Group with permission to create Teams & Office 365 groups
$GroupName = "AllowedToCreateGroups"
# Enable/Disable switch
$AllowGroupCreation = "False"

#assign Office 365 admin credentials to variable
$creds = (get-credentials) 

Install-Module AzureADPreview 
Install-Module MSOnline

Connect-MsolService -Credential $creds
Connect-AzureAD -Credential $creds

#Create goup to control who can create new Office 365 Groups
New-UnifiedGroup -DisplayName $GroupName -Notes "Group with permission to create Teams & Office 365 groups" -Members $ugmembers -Owner admin@praxisedupl.onmicrosoft.com   

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