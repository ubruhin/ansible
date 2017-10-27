#!powershell

# This file is part of Ansible
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

# WANT_JSON
# POWERSHELL_COMMON

$params = Parse-Args $args -supports_check_mode $true

$result = @{
    msg = $null
    changed = $false
}

$name = Get-AnsibleParam -obj $params -name "name" -failifempty $true -type "str"
$scope = Get-AnsibleParam -obj $params -name "scope" -failifempty $true -type "str"
$value = Get-AnsibleParam -obj $params -name "value" -failifempty $true -type "str"
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -default $false -type "bool"

Function Find-Command
{
    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$true, Position=0)] [string] $command
    )
    $installed = get-command $command -erroraction Ignore
    write-verbose "$installed"
    if ($installed) {
        return $installed
    }
    return $null
}

Function FindGit
{
    [CmdletBinding()]
    param()
    $p = Find-Command "git.exe"
    if ($p -ne $null) {
        return $p
    }
    $a = Find-Command "C:\Program Files\Git\bin\git.exe"
    if ($a -ne $null) {
        return $a
    }
    Throw "git.exe is not installed. It must be installed (use chocolatey)"
}

Function BuildOpts
{
    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$true, Position=0)] [string] $scope,
      [Parameter(Mandatory=$true, Position=1)] [string] $name
    )
    $opts = @()
    $opts += "config"
    if ($scope -ne ($null -or "")) {
        $opts += "--$scope"
    }
    $opts += $name
    return $opts
}

Function GetConfig
{
    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$true, Position=0)] [string] $scope,
      [Parameter(Mandatory=$true, Position=1)] [string] $name
    )
    $opts = BuildOpts $scope $name
    &git $opts | Tee-Object -Variable git_output | Out-Null
    if ($LASTEXITCODE -ge 2) {
      Throw "`git $opts` failed with return code $LASTEXITCODE!"
    }
    return $git_output
}

Function SetConfig
{
    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$true, Position=0)] [string] $scope,
      [Parameter(Mandatory=$true, Position=1)] [string] $name,
      [Parameter(Mandatory=$true, Position=2)] [string] $value
    )
    $opts = BuildOpts $scope $name
    $opts += $value
    &git $opts | Tee-Object -Variable git_output | Out-Null
    if ($LASTEXITCODE -ne 0) {
      Throw "`git $opts` failed with return code $LASTEXITCODE!"
    }
}

try {
    FindGit
    $old_value = GetConfig $scope $name
    if ($value -ne $old_value) {
        if ($check_mode) {
            $result.msg = "Would have set $scope $name to $value"
        } else {
            SetConfig $scope $name $value
            $result.msg = "Successfully set $scope $name to $value"
        }
        $result.changed = $true
    } else {
        $result.msg = "$scope $name was already set to $value"
    }
} catch {
    $ErrorMessage = $_.Exception.Message
    $result.msg = $ErrorMessage
    Fail-Json $result "Could not set $name to $value! Msg: $ErrorMessage"
}

Exit-Json $result
