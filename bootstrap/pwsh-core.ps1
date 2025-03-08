BEGIN {

    Function Install-NerdFonts {

        BEGIN {
            $address = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/CascadiaCode.zip"
            $archive = "$($Env:TEMP)\CascadiaCode.zip"
            $folder = "$($Env:TEMP)\CascadiaCode"

            $shell = New-Object -ComObject Shell.Application
            $obj = $shell.Namespace(0x14)
            $systemFontsPath = $obj.Self.Path
            $userFontsPath = Join-Path -Path $Env:LOCALAPPDATA -ChildPath "Microsoft\Windows\Fonts"
        }

        PROCESS {

            Invoke-RestMethod `
                -Method Get `
                -Uri $address `
                -OutFile $archive

            Expand-Archive `
                -Path $archive `
                -DestinationPath $folder `
                -Force

            $shouldReboot = $false
            
            Get-ChildItem `
                -Path $folder |% {
                    $path = $_.FullName
                    $fontName = $_.Name
                    
                    $systemTarget = Join-Path -Path $systemFontsPath -ChildPath $fontName
                    $userTarget = Join-Path -Path $userFontsPath -ChildPath $fontName
                    if ($fontName.EndsWith(".ttf")) {
                        if ((test-path $systemTarget) -or (test-path $userTarget)) {
                            Write-Host "Ignoring $($path) as it already exists." -ForegroundColor DarkGray
                        } else {
                            Write-Host "Installing $($path)..." -ForegroundColor Cyan
                            $obj.CopyHere($path)
                        }
                    }
                }
        }

        END{
            Remove-Item `
                -Path $folder `
                -Recurse `
                -Force `
                -EA SilentlyContinue
        }

    }

    Function Download-Profile {
        [CmdletBinding()]
        param(
            [Parameter(Position = 0)]
            [string]$name
        )

        $template = "Microsoft.PowerShell_%{NAME}%profile.ps1"
        $address = "https://raw.githubusercontent.com/springcomp/powershell_profile.ps1/master/"
        $fileName = Split-Path $profile -Leaf
        if ($name -ne ""){ $fileName = $fileName.Replace("profile", "$name-profile") }
        $uri = "$($address)$($fileName)"
        $destination = Join-Path -Path (Split-Path $profile) -ChildPath $fileName

        Write-Host "GET $uri HTTP/1.1" -ForegroundColor DarkGray

        New-Item `
            -Path (Split-Path $profile) `
            -ItemType Directory `
            -EA SilentlyContinue `
            | Out-Null

        Invoke-RestMethod `
            -Method Get `
            -Uri $uri `
            -OutFile $destination

        Write-Host "$destination updated." -ForegroundColor Cyan
    }

    Function Install-OhMyPosh {
        [CmdletBinding()]
        param()

        . winget install JanDeDobbeleer.OhMyPosh -s winget
    }

    Function Upgrade-OhMyPosh {
        [CmdletBinding()]
        param()

        . winget update JanDeDobbeleer.OhMyPosh -s winget
    }

    Function Upgrade-TerminalIcons {
        [CmdletBinding()]
        param()

        $moduleName = "Terminal-Icons"
        $hasModule = Get-Module -Name $moduleName | Select -First 1
        if ($hasModule) {
            Update-Module -Name "Terminal-Icons"
        }
        else {
            Install-Module -Name $moduleName
        }

    }

}

PROCESS {

    Download-Profile
    Install-Module -Name Pwsh-Profile -Repository PSGallery -Scope CurrentUser -Force

    . $profile

    Install-NerdFonts
    Install-OhMyPosh
    
    Install-Profile "oh-my-posh" -Load
    Install-Profile "psreadline" -Load

    Update-PoshTheme
    Upgrade-OhMyPosh
    Upgrade-TerminalIcons

}
