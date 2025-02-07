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
