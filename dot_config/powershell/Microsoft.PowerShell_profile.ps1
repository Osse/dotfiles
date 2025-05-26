Import-Module Get-ChildItemColor
Import-Module PSReadline

Set-Alias ls Get-ChildItemColor -option AllScope
Set-Alias g git
Set-Alias v nvim

Set-PSReadlineOption -EditMode Vi
Set-PSReadlineOption -ViModeIndicator Prompt
Set-PSReadlineOption -PredictionSource None

Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord Ctrl+r -Function ReverseSearchHistory
Set-PSReadlineKeyHandler -Key ';' -ViMode Command -Function RepeatLastCharSearch

Set-PSReadLineOption -HistoryNoDuplicates:$True

Remove-Item -Force -ErrorAction Ignore Alias:cd
function cd {
    if ($args.Count -eq 0)
    {
        Set-Location -Path $env:USERPROFILE
        return
    }

    if ($args[1] -eq ":/")
    {
        Set-Location -path (git rev-parse --show-toplevel)
        return
    }

    Set-Location -Path @args
}

function less
{
    Out-Host -Paging
}


function printf
{
    $args[0] -f ($args | Select-Object -Skip 1)
}

function tempd
{
    $tmp = New-TemporaryFile
    Remove-Item $tmp.FullName
    New-Item -Type Directory -Path $tmp.FullName
    Set-Location -Path $tmp.FullName
}

$global:vi_mode = ""

function OnViModeChange {
    $global:vi_mode = $args[0]
}

function Parse-Git {
    $ret = @{ }
}

function cmake {
    if ($args.Contains("--preset")) {
        $oldpwd = $pwd
        cd C:\zivid\zivid-sdk\sdk\cpp
    }
    & "C:\Program Files\CMake\bin\cmake.exe" $args
    if ($args.Contains("--preset")) {
        cd $oldpwd
    }
}


$seendirs = @{}

function display_cwd {
    $pwdarray = [array]$pwd.Path.Replace($env:HOME, "~").Split("\")

    if ($pwdarray.Length -eq 1) {
        return $pwdarray[0]
    }

    $shortened = ($pwdarray | Select-Object -Skip 1 | Select-Object -SkipLast 1 | % { $_.SubString(0, 1) })
    @($pwdarray[0], $shortened, $pwdarray[-1]) | Join-String -Separator "\"
}

function Prompt {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent().Name.Split("\")[1]
    $pwdstr = $pwd.Path
    $pwdarray = $pwdstr.Split("\")
    $displaypwdstr = display_cwd
    $prompt = "`e[92m{0}`e[0m@`e[92m{1}`e[0m:`e[94m{2}`e[0m" -f $user, $env:computername, $displaypwdstr
    $git = ""

    if (!$seendirs.Contains($pwdstr) -or $seendirs[$pwdstr] -eq $true) {
        $output = @(git status --porcelain=v2 --untracked-files=normal --branch 2>NUL)

        if ($LastExitCode -ne 0) {
            $seendirs[$pwdstr] = $false
        }
        else {
            $seendirs[$pwdstr] = $true


            $parsed = @{ }

            foreach($line in $output) {
                if ($line.StartsWith("# branch.head")) {
                    $parsed["branch"] += $line.SubString(14)
                }
                elseif ($line.StartsWith("# branch.upstream")) {
                    $parsed["upstream"] = $line.SubString(18)
                }
                elseif ($line.StartsWith("# branch.ab")) {
                    $ab = $line.SubString(12).Split(" ")

                    $parsed["ahead"] = [int]$ab[0]
                    $parsed["behind"] = [int]$ab[1] * - 1
                }
                elseif ($line.StartsWith("1 M")) {
                    $parsed["staged"] = $true
                }
                elseif ($line.StartsWith("1 .M")) {
                    $parsed["unstaged"] = $true
                }
                elseif ($line.StartsWith("?")) {
                    $parsed["untracked"] = $true
                    break
                }
            }

            $git += "["

            if ($parsed["ahead"] -gt 0) {
                $git += "`e[92m" + $parsed["ahead"].ToString() + "▲"
            }
            if ($parsed["behind"] -gt 0) {
                $git += "`e[93m" + $parsed["behind"].ToString() + "▼"
            }
            if ($git.Length -gt 1) {
                $git += " "
            }

            $git += "`e[0m" + $parsed["branch"]

            if ($parsed["staged"]) {
                $git += "`e[92m•`e[0m"
            }
            if ($parsed["unstaged"]) {
                $git += "`e[93m•`e[0m"
            }
            if ($parsed["untracked"]) {
                $git += "`e[91m•`e[0m"
            }

            $git += "]"
        }
    }

    $vs = ""

    if ($env:VSCMD_VER) {
        $vs += "[VS $env:VSCMD_VER $env:VSCMD_ARG_TGT_ARCH]"
    }

    $prompt + $git + $vs + "`e[0m> "
}

Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange
