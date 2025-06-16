function Invoke-Command {
    param($project, $spawnWt, $projectPath, $wtLocated)
    Invoke-Expression "$spawnWt --title `"ssh port-forwarding HashiCorp Vault`" ssh -NL 8200:localhost:8200 mmi@$env:VPS"; Start-Process firefox -ArgumentList https://localhost:8200
}