function Export-GraphiteMetricToFile
{

    <#
        .SYNOPSIS
            Export all the metrics in a MetricList to a temporary file. Return the filepath
            
        .DESCRIPTION
            Provide a list of graphite metrics in the form of a MetricList.
            This function will flatten the list into a graphite compatible format and save it as a UTF8, LF line ending file.
            Will return the file path so you can bundle it up into a rest method to your metric collector
            
        ------------
        .EXAMPLE
            #Make an empty metric list
            $MetricList = new-graphiteMetricList
            #Add some metrics to your metric list, use the current DateTime stamp as the timestamp
            $MetricList.addMetric('my.test.metric',41.3)
            $MetricList.addMetric('my.test.metric2',45.3)
            $MetricList.addMetric('my.test.metric3',65324)
            #Export to file and capture the file path
            $metricFile =  Export-GraphiteMetricToFile -MetricList $MetricList
            
            
        .NOTES
            Author: Adrian Andersson
            
    #>

    [CmdletBinding()]
    PARAM(
        #A metric list option. use new-graphiteMetricList to make one
        [Parameter(Mandatory,ValueFromPipeline)]
        [MetricList]$MetricList,
        #Allow Override of the temp file path
        [Parameter(DontShow)]
        [string]$TempFilePath
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"

        if(!$TempFilePath)
        {
            $TempFilePath = "$([System.IO.Path]::GetTempFileName().Replace('.', '')).txt"
            write-verbose "Temp File will be: $TempFilePath"
        }else{
            write-verbose "Temp file override to: $TempFilePath"
        }
    }
    
    process{
        #Use the inbuilt object method to flatten to the right format
        write-verbose "Flattening metric data. $($MetricList.count) items to flatten"
        $metricDataFlat = $MetricList.toGraphite()
        write-verbose "Outputting content to file: $TempFilePath"
        #Graphite Files need to specificaly have LF file endings, and it seems safest to force uft8
        $metricDataFlat -join "`n"|Set-Content -path $TempFilePath -NoNewline -Force -Encoding utf8
        write-verbose 'return Temp File path'
        $TempFilePath
        
    }
    
}