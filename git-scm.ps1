Function Install-Git {
	[CmdletBinding()]
	param()

	BEGIN {

		$address = "https://github.com/git-for-windows/git/releases/download/v2.36.0.windows.1/Git-2.36.0-64-bit.exe"
		$exe = "$Env:TEMP\git-scm.exe"
	}

	PROCESS {

		Invoke-RestMethod `
			-Method Get `
			-Uri $address `
			-OutFile $exe

		Write-Host "Installing Git. Please wait..." -ForegroundColor Cyan

		$job = Start-Job `
			-ArgumentList $exe `
			-ScriptBlock {
			param([string]$exe)

			## https://github.com/git-for-windows/git/wiki/Silent-or-Unattended-Installation

			$options = "gitlfs,assoc,assoc_sh,windowsterminal"

			$expression = ". `"$($exe)`" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS=`"$options`" "
			Write-Host $expression
			Invoke-Expression -Command $expression
			[Threading.Thread]::Sleep(50000)
		}

		Wait-Job $job
		Receive-Job $job
		Remove-Job $job
	}
}

Install-Git