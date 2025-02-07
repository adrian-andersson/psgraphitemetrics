function export-graphiteMetricToFile
{

    <#
        .SYNOPSIS
            Export all the metrics in a metricList to a temporary file. Return the filepath
            
        .DESCRIPTION
            Provide a list of graphite metrics in the form of a metricList.
            This function will flatten the list into a graphite compatible format and save it as a UTF8, LF line ending file.
            Will return the file path so you can bundle it up into a rest method to your metric collector
            
        ------------
        .EXAMPLE
            #Make an empty metric list
            $metricList = new-graphiteMetricList
            #Add some metrics to your metric list, use the current DateTime stamp as the timestamp
            $metricList.addMetric('my.test.metric',41.3)
            $metricList.addMetric('my.test.metric2',45.3)
            $metricList.addMetric('my.test.metric3',65324)
            #Export to file and capture the file path
            $metricFile =  export-graphiteMetricToFile -metricList $metricList
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2025-05-07 - AA
                    - Created the file
                    
    #>

    [CmdletBinding()]
    PARAM(
        #A metric list option. use new-graphiteMetricList to make one
        [Parameter(Mandatory,ValueFromPipeline)]
        [metricList]$metricList,
        #Allow Override of the temp file path
        [Parameter(DontShow)]
        [string]$tempFilePath
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"

        if(!$tempFilePath)
        {
            $tempFilePath = "$([System.IO.Path]::GetTempFileName().Replace('.', '')).txt"
            write-verbose "Temp File will be: $tempFilePath"
        }else{
            write-verbose "Temp file override to: $tempFilePath"
        }
    }
    
    process{
        #Use the inbuilt object method to flatten to the right format
        write-verbose "Flattening metric data. $($metricList.count) items to flatten"
        $metricDataFlat = $metricList.toGraphite()
        write-verbose "Outputting content to file: $tempFilePath"
        #Graphite Files need to specificaly have LF file endings, and it seems safest to force uft8
        $metricDataFlat -join "`n"|Set-Content -path $tempFilePath -NoNewline -Force -Encoding utf8
        write-verbose 'return Temp File path'
        $tempFilePath
        
    }
    
}