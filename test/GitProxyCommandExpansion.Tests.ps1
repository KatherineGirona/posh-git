BeforeAll {
    . $PSScriptRoot\Shared.ps1
}

Describe 'Proxy Command Expansion Tests' {
    Context 'Proxy Command Name TabExpansion Tests' {
        BeforeEach {
            if(Test-Path -Path Function:\Invoke-GitFunction) {
                Rename-Item -Path Function:\Invoke-GitFunction -NewName Invoke-GitFunctionBackup
            }
            if(Test-Path -Path Alias:\igf) {
                Rename-Item -Path Alias:\igf -NewName igfbackup
            }
            New-Alias -Name 'igf' -Value Invoke-GitFunction -Scope 'Script'
        }
        AfterEach {
            if(Test-Path -Path Function:\Invoke-GitFunction) {
                Remove-Item -Path Function:\Invoke-GitFunction
            }
            if(Test-Path -Path Function:\Invoke-GitFunctionBackup) {
                Rename-Item Function:\Invoke-GitFunctionBackup Invoke-GitFunction
            }
            if(Test-Path -Path Alias:\igf) {
                Remove-Item -Path Alias:\igf
            }
            if(Test-Path -Path Alias:\igfbackup) {
                Rename-Item -Path Alias:\igfbackup -NewName igf
            }
        }
        It 'Expands a proxy command with parameters' {
            function script:Invoke-GitFunction { git checkout $args }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction -b newbranch'
            $result | Should -Be 'git checkout -b newbranch'
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf -b newbranch')
        }
        It 'Expands a multiline proxy command' {
            function script:Invoke-GitFunction { git checkout $args }
            $result = & $module Expand-GitProxyCommand "Invoke-GitFunction ```r`n-b ```r`nnewbranch"
            $result | Should -Be 'git checkout -b newbranch'
            $result | Should -Be (& $module Expand-GitProxyCommand "igf ```r`n-b ```r`nnewbranch")
        }
        It 'Does not expand the proxy command name if there is no preceding whitespace before backtick newlines' {
            function script:Invoke-GitFunction { git checkout $args }
            & $module Expand-GitProxyCommand "Invoke-GitFunction```r`n-b```r`nnewbranch" | Should -Be "Invoke-GitFunction```r`n-b```r`nnewbranch"
            & $module Expand-GitProxyCommand "igf```r`n-b```r`nnewbranch" | Should -Be "igf```r`n-b```r`nnewbranch"
        }
        It 'Does not expand the proxy command name if there is no preceding non-newline whitespace before any backtick newlines' {
            function script:Invoke-GitFunction { git checkout $args }
            & $module Expand-GitProxyCommand "Invoke-GitFunction ```r`n-b```r`nnewbranch" | Should -Be "Invoke-GitFunction ```r`n-b```r`nnewbranch"
            & $module Expand-GitProxyCommand "igf ```r`n-b```r`nnewbranch" | Should -Be "igf ```r`n-b```r`nnewbranch"
        }
        It 'Does not expand the proxy command name if the preceding whitespace before backtick newlines are newlines' {
            function script:Invoke-GitFunction { git checkout $args }
            & $module Expand-GitProxyCommand "Invoke-GitFunction`r`n```r`n-b`r`n```r`nnewbranch" | Should -Be "Invoke-GitFunction`r`n```r`n-b`r`n```r`nnewbranch"
            & $module Expand-GitProxyCommand "igf`r`n```r`n-b`r`n```r`nnewbranch" | Should -Be "igf`r`n```r`n-b`r`n```r`nnewbranch"
        }
        It 'Does not expand the proxy command if there is no trailing space' {
            function script:Invoke-GitFunction { git checkout $args }
            & $module Expand-GitProxyCommand 'Invoke-GitFunction' | Should -Be 'Invoke-GitFunction'
            & $module Expand-GitProxyCommand 'igf' | Should -Be 'igf'
        }
    }
    Context 'Proxy Command Definition Expansion Tests' {
        BeforeEach {
            if(Test-Path -Path Function:\Invoke-GitFunction) {
                Rename-Item -Path Function:\Invoke-GitFunction -NewName Invoke-GitFunctionBackup
            }
            if(Test-Path -Path Alias:\igf) {
                Rename-Item -Path Alias:\igf -NewName igfbackup
            }
            New-Alias -Name 'igf' -Value Invoke-GitFunction -Scope 'Script'
        }
        AfterEach {
            if(Test-Path -Path Function:\Invoke-GitFunction) {
                Remove-Item -Path Function:\Invoke-GitFunction
            }
            if(Test-Path -Path Function:\Invoke-GitFunctionBackup) {
                Rename-Item Function:\Invoke-GitFunctionBackup Invoke-GitFunction
            }
            if(Test-Path -Path Alias:\igf) {
                Remove-Item -Path Alias:\igf
            }
            if(Test-Path -Path Alias:\igfbackup) {
                Rename-Item -Path Alias:\igfbackup -NewName igf
            }
        }
        It 'Expands a single line command' {
            function script:Invoke-GitFunction {
                git checkout $args
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Expands a single line command with short parameter' {
            function script:Invoke-GitFunction {
                git checkout -b $args
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout -b '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Expands a single line command with long parameter' {
            function script:Invoke-GitFunction {
                git checkout --detach $args
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout --detach '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Expands a single line with piped command suffix' {
            function script:Invoke-GitFunction {
                git checkout --detach $args | Write-Host
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout --detach '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Expands the first line in command' {
            function script:Invoke-GitFunction {
                git checkout $args
                $a = 5
                Write-Host $null
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Expands the middle line in command' {
            function script:Invoke-GitFunction {
                $a = 5
                git checkout $args
                Write-Host $null
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Expands the last line in command' {
            function script:Invoke-GitFunction {
                $a = 5
                Write-Host $null
                git checkout $args
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Expands semicolon delimited commands' {
            function script:Invoke-GitFunction {
                $a = 5; git checkout $args; Write-Host $null;
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Expands mixed semicolon delimited and newline commands' {
            function script:Invoke-GitFunction {
                $a = 5; Write-Host $null
                git checkout $args; Write-Host $null;
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Expands mixed semicolon delimited and newline multiline commands' {
            function script:Invoke-GitFunction {
                $a = 5; Write-Host $null
                git `
                checkout `
                $args; Write-Host $null;
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Expands simultaneously semicolon delimited and newline commands' {
            function script:Invoke-GitFunction {
                $a = 5;
                Write-Host $null;
                git checkout $args;
                Write-Host $null;
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Expands multiline command' {
            function script:Invoke-GitFunction {
                git `
                checkout `
                $args
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Expands multiline command that terminates with semicolon on new line' {
            function script:Invoke-GitFunction {
                git `
                checkout `
                $args `
                ;
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Expands multiline command with short parameter' {
            function script:Invoke-GitFunction {
                git `
                checkout `
                -b `
                $args
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout -b '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Expands multiline command with long parameter' {
            function script:Invoke-GitFunction {
                git `
                checkout `
                --detach `
                $args
            }
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result | Should -Be 'git checkout --detach '
            $result | Should -Be (& $module Expand-GitProxyCommand 'igf ' )
        }
        It 'Does not expand a single line with piped command prefix' {
            function script:Invoke-GitFunction {
                "master" | git checkout --detach $args
            }
            & $module Expand-GitProxyCommand 'Invoke-GitFunction ' | Should -Be 'Invoke-GitFunction '
            & $module Expand-GitProxyCommand 'igf ' | Should -Be 'igf '
        }
        It 'Does not expand command if $args is not present' {
            function script:Invoke-GitFunction {
                git checkout
            }
            & $module Expand-GitProxyCommand 'Invoke-GitFunction ' | Should -Be 'Invoke-GitFunction '
            & $module Expand-GitProxyCommand 'igf ' | Should -Be 'igf '
        }
        It 'Does not expand command if $args is not attached to the git command' {
            function script:Invoke-GitFunction {
                $a = 5
                git checkout
                Write-Host $args
            }
            & $module Expand-GitProxyCommand 'Invoke-GitFunction ' | Should -Be 'Invoke-GitFunction '
            & $module Expand-GitProxyCommand 'igf ' | Should -Be 'igf '
        }
        It 'Does not expand multiline command if $args is not attached to the git command' {
            function script:Invoke-GitFunction {
                $a = 5
                git `
                checkout
                Write-Host $args
            }
            & $module Expand-GitProxyCommand 'Invoke-GitFunction ' | Should -Be 'Invoke-GitFunction '
            & $module Expand-GitProxyCommand 'igf ' | Should -Be 'igf '
        }
        It 'Does not expand multiline command backtick newlines are not preceded with whitespace' {
            function script:Invoke-GitFunction {
                $a = 5
                git`
                checkout`
                $args
                Write-Host $null
            }
            & $module Expand-GitProxyCommand 'Invoke-GitFunction ' | Should -Be 'Invoke-GitFunction '
            & $module Expand-GitProxyCommand 'igf ' | Should -Be 'igf '
        }
    }
    Context 'Proxy Command Parameter Replacement Tests' {
        BeforeEach {
            if(Test-Path -Path Function:\Invoke-GitFunction) {
                Rename-Item -Path Function:\Invoke-GitFunction -NewName Invoke-GitFunctionBackup
            }
            function script:Invoke-GitFunction { git checkout $args }
        }
        AfterEach {
            if(Test-Path -Path Function:\Invoke-GitFunction) {
                Remove-Item -Path Function:\Invoke-GitFunction
            }
            if(Test-Path -Path Function:\Invoke-GitFunctionBackup) {
                Rename-Item Function:\Invoke-GitFunctionBackup Invoke-GitFunction
            }
        }
        It 'Replaces parameter in $args' {
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction master'
            $result | Should -Be 'git checkout master'
        }
        It 'Replaces short parameter in $args' {
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction -b master'
            $result | Should -Be 'git checkout -b master'
        }
        It 'Replaces long parameter in $args' {
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction --detach master'
            $result | Should -Be 'git checkout --detach master'
        }
        It 'Replaces mixed parameters in $args' {
            $result = & $module Expand-GitProxyCommand 'Invoke-GitFunction -q -f -m --detach master'
            $result | Should -Be 'git checkout -q -f -m --detach master'
        }
    }
    Context 'Proxy Subcommand TabExpansion Tests' {
        BeforeEach {
            if(Test-Path -Path Function:\Invoke-GitFunction) {
                Rename-Item -Path Function:\Invoke-GitFunction -NewName Invoke-GitFunctionBackup
            }
        }
        AfterEach {
            if(Test-Path -Path Function:\Invoke-GitFunction) {
                Remove-Item -Path Function:\Invoke-GitFunction
            }
            if(Test-Path -Path Function:\Invoke-GitFunctionBackup) {
                Rename-Item -Path Function:\Invoke-GitFunctionBackup -NewName Invoke-GitFunction
            }
        }
        It 'Tab completes without subcommands' {
            function script:Invoke-GitFunction { git whatever $args }
            $commandText = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result = & $module GitTabExpansionInternal $commandText

            $result | Should -Be @()
        }
        It 'Tab completes bisect subcommands' {
            function script:Invoke-GitFunction { git bisect $args }
            $commandText = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result = & $module GitTabExpansionInternal $commandText

            $result -contains '' | Should -Be $false
            $result -contains 'start' | Should -Be $true
            $result -contains 'run' | Should -Be $true

            $commandText = & $module Expand-GitProxyCommand 'Invoke-GitFunction s'
            $result2 = & $module GitTabExpansionInternal $commandText

            $result2 -contains 'start' | Should -Be $true
            $result2 -contains 'skip' | Should -Be $true
        }
        It 'Tab completes remote subcommands' {
            function script:Invoke-GitFunction { git remote $args }
            $commandText = & $module Expand-GitProxyCommand 'Invoke-GitFunction '
            $result = & $module GitTabExpansionInternal $commandText

            $result -contains '' | Should -Be $false
            $result -contains 'add' | Should -Be $true
            $result -contains 'set-branches' | Should -Be $true
            $result -contains 'get-url' | Should -Be $true
            $result -contains 'update' | Should -Be $true

            $commandText = & $module Expand-GitProxyCommand 'Invoke-GitFunction s'
            $result2 = & $module GitTabExpansionInternal $commandText

            $result2 -contains 'set-branches' | Should -Be $true
            $result2 -contains 'set-head' | Should -Be $true
            $result2 -contains 'set-url' | Should -Be $true
        }
    }
}
