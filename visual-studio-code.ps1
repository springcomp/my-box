Function Install-VsCode {
	[CmdletBinding()]
	param()

	BEGIN{
        $address = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
		$exe = "$Env:TEMP\VsCodeUserSetup_x64.exe"
	}
	PROCESS{

        Invoke-RestMethod `
            -Method Get `
            -Uri $address `
            -OutFile $exe

		$job = Start-Job `
            -ArgumentList $exe `
            -ScriptBlock {
                param([string]$exe)
			    $expression = ". `"$($exe)`" /verysilent /norestart /mergetasks=!runcode"
                Write-Host $expression
			    Invoke-Expression -Command $expression
			    [Threading.Thread]::Sleep(10000)
		    }

		Wait-Job $job
		Receive-Job $job
		Remove-Job $job
	}
	END {

		$code = "$Env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
		if (Test-Path -Path $code) {
			Write-Host "Visual Studio Code installed successfully." -ForegroundColor Cyan
			return $true
		} else {
			Write-Host "Unable to install Visual Studio Code." -ForegroundColor Red
			return $false
		}
	}
}

## list all currently installed extensions using the following command:
## > code --list-extensions | % { "code --install-extension $_" }
## > code --list-extensions | % { "`"$_`", ``" }

Function Install-VsCodeExtensions {

	$code = "$Env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
	$extensions = 
		"Azurite.azurite", `
		"DotJoshJohnson.xml", `
		"eamodio.gitlens", `
		"formulahendry.dotnet-test-explorer", `
		"ms-azuretools.vscode-azurefunctions", `
		"ms-azuretools.vscode-azureresourcegroups", `
		"ms-azuretools.vscode-azurestaticwebapps", `
		"ms-azuretools.vscode-docker", `
		"MS-CEINTL.vscode-language-pack-fr", `
		"ms-dotnettools.csharp", `
		"ms-kubernetes-tools.vscode-kubernetes-tools", `
		"ms-vscode-remote.remote-containers", `
		"ms-vscode-remote.remote-ssh", `
		"ms-vscode-remote.remote-ssh-edit", `
		"ms-vscode-remote.remote-ssh-explorer", `
		"ms-vscode-remote.remote-wsl", `
		"ms-vscode-remote.vscode-remote-extensionpack", `
		"ms-vscode.azure-account", `
		"ms-vscode.powershell", `
		"redhat.vscode-yaml", `
		"slevesque.vscode-hexdump", `
		"TqrHsn.vscode-docker-registry-explorer", `
		"Tyriar.sort-lines", `
		"vscodevim.vim" |% {

			Write-Host "Installing $_ Visual Studio Code extension..." -ForegroundColor DarkGray
			. $code --install-extension $_
		
		}
}

if (Install-VsCode) {
    Install-VsCodeExtensions
}
