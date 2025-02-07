<#
Module created by ModuleForge
	 ModuleForge Version: 1.0.0
	BuildDate: 2025-02-07T17:17:33
#>
class unixTimeStamp {
    [long]$Timestamp

    UnixTimeStamp([long]$timestamp){
        $this.Timestamp = $timestamp
    }

    UnixTimeStamp([datetime]$dateTime){
        $timestampConvert = [int][double]::Parse((Get-Date $dateTime -UFormat %s))
        $this.Timestamp = $timestampConvert
    }

    UnixTimeStamp(){
        $timestampConvert = [int][double]::Parse((Get-Date -UFormat %s))
        $this.Timestamp = $timestampConvert
    }

    [string] ToString() {
        return "$($this.Timestamp)"
    }


    [dateTime] ToDateTime() {
        return [datetime]::UnixEpoch.AddSeconds($this.Timestamp)
    }

    [dateTime] ToLocalDateTime() {
        $dateTime = [datetime]::UnixEpoch.AddSeconds($this.Timestamp)
        $timezone = [System.TimeZoneInfo]::Local
        return [System.TimeZoneInfo]::ConvertTime($dateTime, $timezone)
    }
}

class graphiteMetric {
    [string]$metricName
    [double]$metricValue
    [unixTimeStamp]$timestamp

    GraphiteMetric([string]$metricName,[double]$metricValue){
        $this.metricName = $metricName
        $this.metricValue = $metricValue
        $this.timestamp = [unixTimeStamp]::new()
    }

    GraphiteMetric([string]$metricName,[double]$metricValue,[datetime]$dateTime){
        $this.metricName = $metricName
        $this.metricValue = $metricValue
        $this.timestamp = [unixTimeStamp]::new($dateTime)
    }

    GraphiteMetric([string]$metricName,[double]$metricValue,[unixTimeStamp]$unixTimeStamp){
        $this.metricName = $metricName
        $this.metricValue = $metricValue
        $this.timestamp = $unixTimeStamp
    }

    GraphiteMetric([string]$metricName,[double]$metricValue,[long]$unixTimeStamp){
        $this.metricName = $metricName
        $this.metricValue = $metricValue
        $this.timestamp = [unixTimeStamp]::new($unixTimeStamp)
    }

    [string] toGraphite(){
        return "$($this.metricName) $($this.metricValue.toString()) $($this.timestamp.ToString())"
    }
}
class metricList : System.Collections.Generic.List[object] {
    
    metricList() : base() {}


    [void] AddMetric([graphiteMetric]$metric) {
        $this.Add($metric)
    }

    [void] AddMetric([string]$metricName, [double]$metricValue, [datetime]$dateTime) {
        $metric = [graphiteMetric]::new($metricName, $metricValue, $dateTime)
        $this.Add($metric)
    }

    [void] AddMetric([string]$metricName, [double]$metricValue, [unixTimeStamp]$unixTimeStamp) {
        $metric = [graphiteMetric]::new($metricName, $metricValue, $unixTimeStamp)
        $this.Add($metric)
    }

    [void] AddMetric([string]$metricName, [double]$metricValue, [long]$timestamp) {
        $metric = [graphiteMetric]::new($metricName, $metricValue, $timestamp)
        $this.Add($metric)
    }

    [void] AddMetric([string]$metricName, [double]$metricValue) {
        $metric = [graphiteMetric]::new($metricName, $metricValue)
        $this.Add($metric)
    }

    
    [string] ToGraphiteString() {
        $list = $this | ForEach-Object { $_.toGraphite() }
        $listJoin = $list -join "`n"
        return $listJoin
    }
}
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
function new-graphiteMetricList
{

    <#
        .SYNOPSIS
            Creates a new instance of the MetricList class.
            
        .DESCRIPTION
            The New-MetricList function creates a new instance of the MetricList class, which is a specialized list designed to hold GraphiteMetric objects. 
            This function initializes an empty MetricList that can be used to store and manage multiple GraphiteMetric objects.
            

        .EXAMPLE
            # Create an empty MetricList
            $metricList = New-MetricList
            Write-Output $metricList

        .EXAMPLE    
            # Create a MetricList and add a GraphiteMetric to it
            $metricList = New-MetricList
            $metricList.AddMetric("cpu.usage", 75)
            Write-Output $metricList.ToGraphiteString()
            
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
            
                2025-02-06 - AA
                    - Created Function
                    
    #>

    [CmdletBinding()]
    PARAM(

    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        
        write-verbose 'Creating Metriclist'
        $list = [metricList]::new()
        write-verbose "$($list.GetType()|out-string)"
        #return $object
        
        #$list = [System.Collections.Generic.List[object]]::new()
        #write-verbose "$($list.GetType()|out-string)"
        #write-verbose "This should have been a generic list"
        #See that little comma, it's important
        #This tells PowerShell we want to treat the return as a single-item Array, and thus preserve it's type information
        #If we DO NOT include the comma, you never get the resuts of an empty list
        #And even MORE strange, returning a list that has items in it converts it to a fixed-size array and not a list
        # How strange is that
        #Anyway, leave the comma alone ok... It is supposed to be there
        , $list
    }
    
}
