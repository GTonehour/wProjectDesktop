param(
	[string]$ConfigPath
) # [CmdletBinding()] requires it.

# On pourrait avoir envie de sortir d'InstallFunction la partie "configuration" pour la mettre ici, parce que notre test (actuel) ne spécifie pas de ConfigPath. Mais c'est contradictoire avec le principe des tests, si vous réfléchissez bien...
. $PSScriptRoot\install_res\InstallFunction.ps1

# Call the function, "splatting" all parameters that were passed to this script
Install-WPD @PSBoundParameters | Out-Null # On a besoin d'un return pour le test, mais pas de l'afficher
