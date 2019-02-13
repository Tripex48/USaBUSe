function spawn() {
	$p = New-Object -TypeName System.Diagnostics.Process
	$i = $p.StartInfo
	$i.CreateNoWindow = $false
	$i.UseShellExecute = $false
	$i.RedirectStandardInput = $true
	$i.RedirectStandardOutput = $true
	$i.RedirectStandardError = $true
	$i.FileName = "cmd.exe"
	$i.Arguments = "/c cmd.exe /k 2>&1 "
	$null = $p.Start()
	return $p
}

function connect($device, $stdout, $stdin) {
	$stdout_buffer = New-Object Byte[] ($M+1)
	$device_buffer = New-Object Byte[] ($M+1)
	$empty_buffer = New-Object Byte[] ($M+1)

	$stdout_task = $stdout.BeginRead($stdout_buffer, 2, ($M-1), $null, $null)
	$device_task = $device.BeginRead($device_buffer, 0, ($M+1), $null, $null)

	$stdout_total = 0
	$device_total = 0
	Write-Output "Entering main loop"
	Write-Output "First write"
	$device.Write($empty_buffer, 0, $M+1)
	$io = $false
	while ($stdout_task -ne $null -and $device_task -ne $null) {
		try {
			if ($stdout_task.IsCompleted -and $can_write) {
				$stdout_bytes_read = $stdout.EndRead($stdout_task)
				if ($stdout_bytes_read -gt 0) {
					$stdout_total += $stdout_bytes_read
					$stdout_buffer[1] = $stdout_bytes_read
					Write-Output "Second write"
					$device.Write($stdout_buffer, 0, $M+1)
					$device.Flush()
					$stdout_task = $stdout.BeginRead($stdout_buffer, 2, ($M-1), $null, $null)
				} else { # process closed?
					$stdout_task = $null
				}
				$io = $true
			}
			if ($device_task.IsCompleted) {
				$device_bytes_read = $device.EndRead($device_task)
				if ($device_bytes_read -gt 0) {
					$can_write = (($device_buffer[1] -band 128) -ne 128)
					$device_buffer[1] = $device_buffer[1] -band ($M-1)
					if ($device_buffer[1] -gt 0) {
						$device_total += $device_buffer[1]
						Write-Output "Third write"
						$stdin.Write($device_buffer, 2, $device_buffer[1])
						$stdin.Flush()
					}
					$device_task = $device.BeginRead($device_buffer, 0, ($M+1), $null, $null)
				} else {
					$device_task = $null
				}
				Write-Output "Fourth write"
				$device.Write($empty_buffer, 0, $M+1)
				$io = $true
			}
			if (!$io) {
				Start-Sleep -m 1
			}
		} catch {
			$ErrorMessage = $_.Exception.Message
			$FailedItem = $_.Exception.ItemName
			Write-Output "Exception caught, terminating main loop"
			Write-Output $ErrorMessage
			Write-Output $FailedItem
			break
		}
	}

	Write-Output "Main loop completed"

	$f.Close()
}

$p = spawn
connect $f $p.StandardOutput.BaseStream $p.StandardInput.BaseStream
