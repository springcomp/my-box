Function Invoke-RemoteScript {
	[CmdletBinding()]
	param(
		[Parameter(Position = 0)]
		[string]$address,
		[Parameter(ValueFromRemainingArguments = $true)]
		$remainingArgs
	)

	iex "& { $(irm $address) } $remainingArgs"
}
Set-Alias -Name irs -Value Invoke-RemoteScript

irs 'https://aka.ms/install-powershell.ps1' -daily

irm 'https://raw.githubusercontent.com/springcomp/my-box/master/bootstrap/pwsh-core.ps1' `
	-OutFile $env:TEMP\pwsh-core.ps1

$pwsh = "$env:LOCALAPPDATA\Microsoft\powershell-daily\pwsh.exe"
. $pwsh -nologo -noprofile -file $env:TEMP\pwsh-core.ps1
