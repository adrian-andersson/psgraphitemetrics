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