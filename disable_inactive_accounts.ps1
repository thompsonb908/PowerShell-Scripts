# disable_inactive_accounts.ps1  
# Set msDS-LogonTimeSyncInterval (days) to a sane number.  By
# default lastLogonDate only replicates between DCs every 9-14 
# days unless this attribute is set to a shorter interval.

# https://timclevenger.com/2020/05/26/automatically-disable-inactive-users-in-active-directory/

# Also, make sure to create the EventLog source before running, or
# comment out the Write-EventLog lines if no event logging is
# needed.  Only needed once on each machine running this script.
# New-EventLog -LogName Application -Source "DisableUsers.ps1"
 
# Remove "-WhatIf"s before putting into production.
 
Import-Module ActiveDirectory
 
$inactiveDays = 90
$neverLoggedInDays = 90
$disableDaysInactive=(Get-Date).AddDays(-($inactiveDays))
$disableDaysNeverLoggedIn=(Get-Date).AddDays(-($neverLoggedInDays))
 
# Identify and disable users who have not logged in in x days
 
$disableUsers1 = Get-ADUser -SearchBase "OU=Users,OU=Demo Accounts,DC=lab,DC=clev,DC=work" -Filter {Enabled -eq $TRUE} -Properties lastLogonDate, whenCreated, distinguishedName | Where-Object {($_.lastLogonDate -lt $disableDaysInactive) -and ($_.lastLogonDate -ne $NULL)}
 
 $disableUsers1 | ForEach-Object {
   Disable-ADAccount $_ -WhatIf
   # Set-ADUser -Description ("Account Auto-Disabled by disable_inactive_accounts.ps1 on $(get-date)")
   Write-EventLog -Source "disable_inactive_accounts.ps1" -EventId 9090 -LogName Application -Message "Attempted to disable user $_ because the last login was more than $inactiveDays ago."
   }
 
# Identify and disable users who were created x days ago and never logged in.
 
$disableUsers2 = Get-ADUser -SearchBase "OU=Users,OU=Demo Accounts,DC=lab,DC=clev,DC=work" -Filter {Enabled -eq $TRUE} -Properties lastLogonDate, whenCreated, distinguishedName | Where-Object {($_.whenCreated -lt $disableDaysNeverLoggedIn) -and (-not ($_.lastLogonDate -ne $NULL))}
 
$disableUsers2 | ForEach-Object {
   Disable-ADAccount $_ -WhatIf
   # Set-ADUser -Description ("Account Auto-Disabled by disable_inactive_accounts.ps1 on $(get-date)"
   Write-EventLog -Source "disable_inactive_accounts.ps1" -EventId 9091 -LogName Application -Message "Attempted to disable user $_ because user has never logged in and $neverLoggedInDays days have passed."
   }
