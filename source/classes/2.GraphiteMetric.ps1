class GraphiteMetric {
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

    [string] ToGraphite(){
        return "$($this.metricName) $($this.metricValue.toString()) $($this.timestamp.ToString())"
    }
}