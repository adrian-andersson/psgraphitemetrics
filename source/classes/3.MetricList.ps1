class MetricList : System.Collections.Generic.List[object] {
    
    MetricList() : base() {}


    [void] AddMetric([GraphiteMetric]$metric) {
        $this.Add($metric)
    }

    [void] AddMetric([string]$metricName, [double]$metricValue, [datetime]$dateTime) {
        $metric = [GraphiteMetric]::new($metricName, $metricValue, $dateTime)
        $this.Add($metric)
    }

    [void] AddMetric([string]$metricName, [double]$metricValue, [UnixTimeStamp]$unixTimeStamp) {
        $metric = [GraphiteMetric]::new($metricName, $metricValue, $unixTimeStamp)
        $this.Add($metric)
    }

    [void] AddMetric([string]$metricName, [double]$metricValue, [long]$timestamp) {
        $metric = [GraphiteMetric]::new($metricName, $metricValue, $timestamp)
        $this.Add($metric)
    }

    [void] AddMetric([string]$metricName, [double]$metricValue) {
        $metric = [GraphiteMetric]::new($metricName, $metricValue)
        $this.Add($metric)
    }

    
    [string] ToGraphiteString() {
        $list = $this | ForEach-Object { $_.toGraphite() }
        $listJoin = $list -join "`n"
        return $listJoin
    }
}