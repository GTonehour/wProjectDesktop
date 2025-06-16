function Invoke-Command {
    param($project, $spawnWt, $projectPath, $wtLocated)
    cd $env:projects\docs ; .\venv\verif\Scripts\Activate.ps1 ; py verif_aff.py ; deactivate
}