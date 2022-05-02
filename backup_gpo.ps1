$BackupPath = 'Path to save to'
$Domain = 'domain name'
$DomainController = 'DC.domain'

$BackupFolder = New-Item -Path $BackupPath -Name (Get-Date -Format yyyyMMddTHHmmss) -ItemType Directory
Backup-GPO -All -Domain $Domain -Server $DomainController -Path $BackupFolder
