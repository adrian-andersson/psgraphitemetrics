function New-GraphiteMetricList
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