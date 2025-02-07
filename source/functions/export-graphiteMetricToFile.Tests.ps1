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
        functions = @('new-graphiteMetricList.ps1')
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

Describe 'Export-GraphiteMetricToFile' {
    It 'Should export a MetricList to a temporary file' {
        # Create a new metric list and add some metrics
        $metricList = New-GraphiteMetricList
        $metricList.AddMetric('my.test.metric', 41.3)
        $metricList.AddMetric('my.test.metric2', 45.3)
        $metricList.AddMetric('my.test.metric3', 65324)

        # Export the metric list to a file
        $tempFilePath = Export-GraphiteMetricToFile -metricList $metricList

        # Verify the file exists
        Test-Path $tempFilePath | Should -Be $true

        # Verify the file content
        $fileContent = Get-Content -Path $tempFilePath -Raw
        $fileContent | Should -BeLike '*my.test.metric 41.3 *'
        $fileContent | Should -BeLike '*my.test.metric2 45.3 *'
        $fileContent | Should -BeLike '*my.test.metric3 65324 *'

        # Clean up the temporary file
        Remove-Item -Path $tempFilePath -Force
    }

    It 'Should allow overriding the temp file path' {
        # Create a new metric list and add some metrics
        $metricList = New-GraphiteMetricList
        $metricList.AddMetric('my.test.metric', 41.3)

        # Specify a custom temp file path
        $customTempFilePath = "$env:TEMP\custom_metric_file.txt"

        # Export the metric list to the custom file
        $tempFilePath = Export-GraphiteMetricToFile -metricList $metricList -tempFilePath $customTempFilePath

        # Verify the custom file path is used
        $tempFilePath | Should -Be $customTempFilePath

        # Verify the file exists
        Test-Path $tempFilePath | Should -Be $true

        # Clean up the custom temporary file
        Remove-Item -Path $customTempFilePath -Force
    }
}