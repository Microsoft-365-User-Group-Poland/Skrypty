$plik = "lista.csv"
$licencja_naucz_1 = "Office 365 A1 dla nauczycieli lub wykładowców"
$licencja_naucz_2 = "Microsoft Power Automate Free+Office 365 A1 dla nauczycieli lub wykładowców"
$licencja_uczen_1 = "Office 365 A1 dla uczniów lub studentów"
$licencja_uczen_2 = "Office 365 A1 dla uczniów lub studentów+Microsoft Power Automate Free"
$credentials = Get-Credential;
$credentialsPath = Join-Path -Path . -ChildPath credentials.xmls;
$credentials | Export-CliXml $credentialsPath;
Import-Module MicrosoftTeams
Connect-MicrosoftTeams -Credential $credentials
# Wyszukaj użytkowników z licencją nauczyciela
$members = Import-Csv .\$plik -Delimiter ',' |`
 where { ($_.Licenses -eq $licencja_naucz_1) -or ($_.Licenses -eq $licencja_naucz_2)}
$members | ForEach-Object { 
    Write-Host "Przypisuję uprawnienia dla" $_.DisplayName "`t`t`tIdentyfikator: "$_.ObjectId
    Grant-CsUserPolicyPackage -Identity $_.ObjectId -PackageName Education_Teacher
}
# Wyszukaj użytkowników z licencją ucznia
$members = Import-Csv .\$plik -Delimiter ',' |`
 where { ($_.Licenses -eq $licencja_uczen_1) -or ($_.Licenses -eq $licencja_uczen_2)}
$members | ForEach-Object { 
    Write-Host "Przypisuję uprawnienia dla" $_.DisplayName "`t`t`tIdentyfikator: "$_.ObjectId
    Grant-CsUserPolicyPackage -Identity $_.ObjectId -PackageName Education_Teacher
}