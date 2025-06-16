function Invoke-Command {
    param($project, $spawnWt, $projectPath, $wtLocated)
    Invoke-Expression "$spawnWt --title `"ssh port-forwarding PG`" ssh -fNL 15432:localhost:5432 mmi@$env:VPS"
}