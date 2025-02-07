function new-graphiteMetric
{

    <#
        .SYNOPSIS
            Creates a new GraphiteMetric object with the specified metric name, value, and optional timestamp.
            
        .DESCRIPTION
            The New-GraphiteMetric function allows you to create a GraphiteMetric object, which represents a metric with a name, value, and timestamp. 
            The function supports multiple ways to specify the timestamp, including a DateTime object, a UnixTimeStamp object, or a Unix timestamp in seconds. 
            If no timestamp is provided, the current date and time are used.
            
        .EXAMPLE
            # Create a GraphiteMetric with the current timestamp
            $metric = New-GraphiteMetric -metricName "cpu.usage" -metricValue 75
            Write-Output $metric.toGraphite()
            
        .EXAMPLE
            # Create a GraphiteMetric with a specific DateTime
            $metric = New-GraphiteMetric -metricName "memory.usage" -metricValue 512 -dateTime (Get-Date "2025-02-06T14:00:00")
            Write-Output $metric.toGraphite()

        .EXAMPLE
            # Create a GraphiteMetric with a UnixTimeStamp object
            $unixTimeStamp = [UnixTimeStamp]::new(1672531199)
            $metric = New-GraphiteMetric -metricName "disk.usage" -metricValue 1024 -unixTimeStamp $unixTimeStamp
            Write-Output $metric.toGraphite()

        .EXAMPLE
            # Create a GraphiteMetric with a Unix timestamp in seconds
            $metric = New-GraphiteMetric -metricName "network.usage" -metricValue 300 -timestamp 1672531199
            Write-Output $metric.toGraphite()


            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2025-02-06 - AA
                    - Created function
                    
    #>

    [CmdletBinding(DefaultParameterSetName = 'default')]
    PARAM(
        #Metric Name / metric path: This is a period-delimited path that identifies the thing being measured, such as 'servers.prod.memory.free'
        [Parameter(Mandatory,ParameterSetName = 'default')]
        [Parameter(Mandatory,ParameterSetName = 'datetime')]
        [Parameter(Mandatory,ParameterSetName = 'unixTimeStamp')]
        [Parameter(Mandatory,ParameterSetName = 'timeStampString')]
        [Alias('metricPath','metric')]
        [string]$metricName,
        #Value of the metric, anything numeric. Is a long since decimals and ints are valid usually, so lets force decimals to make life easier
        [Parameter(Mandatory,ParameterSetName = 'default')]
        [Parameter(Mandatory,ParameterSetName = 'datetime')]
        [Parameter(Mandatory,ParameterSetName = 'unixTimeStamp')]
        [Parameter(Mandatory,ParameterSetName = 'timeStampString')]
        [Alias('value')]
        [double]$metricValue,
        [Parameter(Mandatory,ParameterSetName = 'datetime')]
        [datetime]$datetime,
        [Parameter(Mandatory,ParameterSetName = 'unixTimeStamp')]
        [unixTimeStamp]$unixTimeStamp,
        [Parameter(Mandatory,ParameterSetName = 'timeStampString')]
        [string]$timeStampString
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        switch ($PSCmdlet.ParameterSetName) {
            'datetime' {
                write-verbose 'Creating with Datetime'
                return [graphiteMetric]::new($metricName, $metricValue, $dateTime)
            }
            'unixTimeStamp' {
                write-verbose 'Creating with UnixTimestamp object'
                return [graphiteMetric]::new($metricName, $metricValue, $unixTimeStamp)
            }
            'timeStampString' {
                write-verbose 'Creating with a UnixTime, will convert string to long'
                return [graphiteMetric]::new($metricName, $metricValue, [long]$timeStampString)
            }
            default {
                write-verbose 'Creating with current dateTime'
                return [graphiteMetric]::new($metricName, $metricValue)
            }
        }
        
    }
    
}