function New-GraphiteMetric
{

    <#
        .SYNOPSIS
            Creates a new GraphiteMetric object with the specified metric name, value, and optional timestamp.
            
        .DESCRIPTION
            The New-GraphiteMetric function allows you to create a GraphiteMetric object, which represents a metric with a name, value, and timestamp. 
            The function supports multiple ways to specify the timestamp, including a Datetime object, a UnixTimeStamp object, or a Unix timestamp in seconds. 
            If no timestamp is provided, the current date and time are used.
            
        .EXAMPLE
            # Create a GraphiteMetric with the current timestamp
            $metric = New-GraphiteMetric -MetricName "cpu.usage" -MetricValue 75
            Write-Output $metric.toGraphite()
            
        .EXAMPLE
            # Create a GraphiteMetric with a specific Datetime
            $metric = New-GraphiteMetric -MetricName "memory.usage" -MetricValue 512 -Datetime (Get-Date "2025-02-06T14:00:00")
            Write-Output $metric.toGraphite()

        .EXAMPLE
            # Create a GraphiteMetric with a UnixTimeStamp object
            $UnixTimeStamp = [UnixTimeStamp]::new(1672531199)
            $metric = New-GraphiteMetric -MetricName "disk.usage" -MetricValue 1024 -UnixTimeStamp $UnixTimeStamp
            Write-Output $metric.toGraphite()

        .EXAMPLE
            # Create a GraphiteMetric with a Unix timestamp in seconds
            $metric = New-GraphiteMetric -MetricName "network.usage" -MetricValue 300 -timestamp 1672531199
            Write-Output $metric.toGraphite()

        .OUTPUTS
            [GraphiteMetric]
            Output will be a custom GraphiteMetric object
            
        .NOTES
            Author: Adrian Andersson
                                
    #>

    [CmdletBinding(DefaultParameterSetName = 'default')]
    PARAM(
        #Metric Name / metric path: This is a period-delimited path that identifies the thing being measured, such as 'servers.prod.memory.free'
        [Parameter(Mandatory,ParameterSetName = 'default')]
        [Parameter(Mandatory,ParameterSetName = 'Datetime')]
        [Parameter(Mandatory,ParameterSetName = 'UnixTimeStamp')]
        [Parameter(Mandatory,ParameterSetName = 'TimeStampString')]
        [Alias('MetricPath','Metric')]
        [string]$MetricName,
        #Value of the metric, anything numeric. Is a long since decimals and ints are valid usually, so lets force decimals to make life easier
        [Parameter(Mandatory,ParameterSetName = 'default')]
        [Parameter(Mandatory,ParameterSetName = 'Datetime')]
        [Parameter(Mandatory,ParameterSetName = 'UnixTimeStamp')]
        [Parameter(Mandatory,ParameterSetName = 'TimeStampString')]
        [Alias('value')]
        [double]$MetricValue,
        [Parameter(Mandatory,ParameterSetName = 'Datetime')]
        [Datetime]$Datetime,
        [Parameter(Mandatory,ParameterSetName = 'UnixTimeStamp')]
        [UnixTimeStamp]$UnixTimeStamp,
        [Parameter(Mandatory,ParameterSetName = 'TimeStampString')]
        [string]$TimeStampString
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        switch ($PSCmdlet.ParameterSetName) {
            'Datetime' {
                write-verbose 'Creating with Datetime'
                return [GraphiteMetric]::new($MetricName, $MetricValue, $Datetime)
            }
            'UnixTimeStamp' {
                write-verbose 'Creating with UnixTimeStamp object'
                return [GraphiteMetric]::new($MetricName, $MetricValue, $UnixTimeStamp)
            }
            'TimeStampString' {
                write-verbose 'Creating with a UnixTime, will convert string to long'
                return [GraphiteMetric]::new($MetricName, $MetricValue, [long]$TimeStampString)
            }
            default {
                write-verbose 'Creating with current Datetime'
                return [GraphiteMetric]::new($MetricName, $MetricValue)
            }
        }
        
    }
    
}