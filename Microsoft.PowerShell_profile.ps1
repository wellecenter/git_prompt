function prompt {

    $branchName = $(git rev-parse --abbrev-ref HEAD 2>$null)
	$untracked = 0
	$modified = 0
	$deleted = 0
	$notStaged = 0
	$notPushed = 0
	
	$status = git status --porcelain=v1
	foreach ($line in $status) {
		if ($line -match "^\?\? ") { $untracked += 1 }
		if ($line -match "^M ") { $modified += 1 }
		if ($line -match "^D ") { $deleted += 1 }
		if ($line -match "^.M ") { $notStaged += 1 }
		if ($line -match "^.D ") { $notStaged += 1 }
	}
	
	$notCommited = $modified + $deleted

	$cherry = git cherry
	foreach ($line in $cherry) {
		if ($line -match "^+") {
			$notPushed += 1
		}
	}

   Write-Host ""
   Write-Host "=========================================================================================="
   Write-Host -NoNewline "Current: "
   Write-Host -ForegroundColor DarkYellow "$pwd"
   Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
   if ($branchName) {
      Write-Host -NoNewline "Branch: "
      Write-Host -NoNewline -ForegroundColor Blue "$branchName"

      function Output-Count {
         param (
            [Parameter(Mandatory)] [string]$Description,
            [Parameter(Mandatory)] [int]$Count
         )

         Write-Host -NoNewline "$Description"
         if ($Count -gt 0) {Write-Host -NoNewline -ForegroundColor Red "$Count"} else {Write-Host -NoNewline -ForegroundColor Green "$Count"}
      }

      Write-Host -NoNewline " ("
	  Output-Count -Description "not committed: " -Count $notCommited
	  Output-Count -Description ", modified: " -Count $modified
	  Output-Count -Description ", deleted: " -Count $deleted
	  Output-Count -Description ", untracked: " -Count $untracked
	  Output-Count -Description ", not staged: " -Count $notStaged
	  Output-Count -Description ", not pushed: " -Count $notPushed
      Write-Host ")"
   }
   
   Write-Host -NoNewline "PS: "
   Write-Host -NoNewline -ForegroundColor DarkYellow "..\$((Get-Item .).Name)"
   Write-Host -NoNewline "$(Get-Date -Format " | HH.mm:ss")"
   Write-Output "> "
}

New-Alias mergeFromMaster "git fetch origin master; git merge origin/master" -Scope Global -Option AllScope
