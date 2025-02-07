# PSgraphiteMetrics PowerShell Module

## What is this

A PowerShell module to make dealing with Graphite Metrics in Pwsh (And Windows / Cross-Platform) easier and faster.

## What is Graphite ?

Graphite is an Open-Source Metric store/graph tool. It seems to be pretty popular, but I've never used it. I made this because lots of other tools (Such as Graphana, SumoLogic etc) seem to be quite happy to injest Graphite Metric log files, and I wanted to get metrics into those systems in a format they would support.

Graphite Metrics are pretty easy to read and understand, its a single line including a name, value and time, i.e. `{metric.name} {value} {unixtimestamp}`

Example:

```text
my.test.metric 41 1738902081
my.test.metric2 45 1738902081
my.test.metric3 65324 1738902081
```

which translates to:

|metricName|metricValue|timestamp|
|-|-|-|
|my.test.metric|41|1738902081|
|my.test.metric2|45|1738902081|
|my.test.metric3|65324|1738902081|

## What problem does this module solve

I really needed some custom metrics into Sumo Logic. The whole concept of Metrics seemed much more aligned to what I needed over logs (Which is easy enough to do with a REST call and a JSON blob). Sumo only supports a few formats for Metrics, and the Graphite format seemed simple and straight-forwards, but it turns out like all things in life, there were challenges:

- Sumo would only accept my metrics if I provided a file with LF line endings, and was very strict
- I wanted a fast and consistent way to collate and convert the data from Pwsh that obeyed Sumo's strictness
- I wanted to automate as much as possible, and keep the code lighter on the collation side

If you need Sumo Metrics, and your a PowerShell Nerd or your on Windows, this will help. If you don't have that very specific requirement, this may not be the module for you!

## How to use this module

PSGallery (Not there yet)

```pwsh
#PSResourceGet (The better way to handle modules)
Install-psresource -repository psgalelry -name PSgraphiteMetrics

#PowerShellGet
install-module -repository psgallery -name PSgraphiteMetrics
```

## Start using

```pwsh
#Make an empty metric list
$metricList = new-graphiteMetricList

#Add some metrics to your metric list, use the current DateTime stamp as the timestamp
$metricList.addMetric('my.test.metric',41.3)
$metricList.addMetric('my.test.metric2',45.3)
$metricList.addMetric('my.test.metric3',65324)

#Export to file and capture the file path
$metricFile =  export-graphiteMetricToFile -metricList $metricList

#Do something with your file, like ship it to sumo
$requestSplat = @{
    contenttype = 'application/vnd.sumologic.graphite'
    method = 'post'
    uri = 'https://your.sumo.html.collector'
    infile = $metricFile
}

Invoke-RestMethod @requestSplat
```
