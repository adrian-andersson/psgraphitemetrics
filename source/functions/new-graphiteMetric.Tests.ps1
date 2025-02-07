BeforeAll{
    #Reference Current Path
    $currentPath = $(get-location).path
    $sourcePath = join-path -path $currentPath -childPath 'source'
    #Reference Dependencies
    $dependencies = [ordered]@{
        enums = @()
        validationClasses = @()
        classes = @('1.unixTimeStamp.ps1','2.graphiteMetric.ps1','3.metricList.ps1')
        private = @()
    }

    $dependencies.GetEnumerator().ForEach{
        $DirectoryRef = join-path -path $sourcePath -childPath $_.Key
        $_.Value.ForEach{
            $ItemPath = join-path -path $DirectoryRef -childpath $_
            $ItemRef = get-item $ItemPath -ErrorAction SilentlyContinue
            if($ItemRef){
                write-verbose "Dependency identified at: $($ItemRef.fullname)"
                . $ItemRef.Fullname
            }else{
                write-warning "Dependency not found at: $ItemPath"
            }
        }
    }
    
    #Load THis File
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe 'New-GraphiteMetric' {
    It 'Should create a GraphiteMetric with current dateTime' {
        $metricName = 'test.metric'
        $metricValue = 100
        $metric = New-GraphiteMetric -metricName $metricName -metricValue $metricValue
        $($metric.GetType().Name) | Should -Be 'graphiteMetric'
        $metric.metricName | Should -Be $metricName
        $metric.metricValue | Should -Be $metricValue
        [int]$($metric.timestamp.toString()) | Should -BeGreaterThan 0
    }



    It 'Should create a GraphiteMetric with specific DateTime' {
        $metricName = 'test.metric'
        $metricValue = 100
        $dateTime = Get-Date "2025-02-06T14:00:00"
        $metric = New-GraphiteMetric -metricName $metricName -metricValue $metricValue -datetime $dateTime
        $($metric.GetType().Name) | Should -Be 'graphiteMetric'
        $metric.metricName | Should -Be $metricName
        $metric.metricValue | Should -Be $metricValue
        $metric.timestamp.toString() | Should -Be $(get-date $dateTime -UFormat %s)
    }

    It 'Should create a GraphiteMetric with UnixTimeStamp object' {
        $metricName = 'test.metric'
        $metricValue = 100
        $unixTimeStamp = 1672531199
        $metric = New-GraphiteMetric -metricName $metricName -metricValue $metricValue -timestampstring $unixTimeStamp
        $($metric.GetType().Name) | Should -Be 'graphiteMetric'
        $metric.MetricName | Should -Be $metricName
        $metric.MetricValue | Should -Be $metricValue
        $metric.timestamp.toString() | Should -Be $unixTimeStamp 
    }
}