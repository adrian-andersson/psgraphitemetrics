$pesterConfigHash = @{
    Run = @{
        Passthru = $true
        Path = $(join-path -path (join-path -path . -childpath 'source') -childpath 'functions')
    }
    CodeCoverage = @{
        Enabled = $true
        Path = $(join-path -path (join-path -path . -childpath 'source') -childpath 'functions')
    }
    Output = @{
        Verbosity = 'Detailed'
    }
}
$pesterConfig = New-PesterConfiguration -hashtable $pesterConfigHash
Invoke-Pester -Configuration $pesterConfig