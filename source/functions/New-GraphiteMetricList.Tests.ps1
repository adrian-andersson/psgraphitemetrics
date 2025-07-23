BeforeAll{
    #Reference Current Path
    $currentPath = $(get-location).path
    $sourcePath = join-path -path $currentPath -childPath 'source'
    #Reference Dependencies
    $dependencies = [ordered]@{
        enums = @()
        validationClasses = @()
        classes = @('1.UnixTimeStamp.ps1','2.GraphiteMetric.ps1','3.MetricList.ps1')
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

Describe "New-GraphiteMetricList" {
    
    It 'Should create an empty MetricList' {
        $metricList = New-GraphiteMetricList
        #$metricList | Should -BeOfType 'MetricList'
        $($metricList.GetType().Name) | Should -Be 'MetricList'
        $metricList.Count | Should -Be 0
    }   
}