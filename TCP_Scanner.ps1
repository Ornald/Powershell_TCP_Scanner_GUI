Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "TCP Port Scanner"
$form.Size = New-Object System.Drawing.Size(420,900)
$form.StartPosition = "CenterScreen"

# Label - IP Address
$labelIP = New-Object System.Windows.Forms.Label
$labelIP.Text = "IP Address (just 1):"
$labelIP.Location = New-Object System.Drawing.Point(10,20)
$form.Controls.Add($labelIP)

# TextBox - IP Address
$textIP = New-Object System.Windows.Forms.TextBox
$textIP.Location = New-Object System.Drawing.Point(130,20)
$textIP.Width = 250
$form.Controls.Add($textIP)

# Label - Port Range
$labelPorts = New-Object System.Windows.Forms.Label
$labelPorts.Text = "Ports (e.g. 22,80,1000-1010):"
$labelPorts.Location = New-Object System.Drawing.Point(10,60)
$form.Controls.Add($labelPorts)

# TextBox - Port Range
$textPorts = New-Object System.Windows.Forms.TextBox
$textPorts.Location = New-Object System.Drawing.Point(200,60)
$textPorts.Width = 150
$form.Controls.Add($textPorts)

# Button - Scan
$buttonScan = New-Object System.Windows.Forms.Button
$buttonScan.Text = "Scan"
$buttonScan.Location = New-Object System.Drawing.Point(160,100)
$form.Controls.Add($buttonScan)

# Results box Open
$textResultsOpen = New-Object System.Windows.Forms.TextBox
$textResultsOpen.Location = New-Object System.Drawing.Point(10,140)
$textResultsOpen.Size = New-Object System.Drawing.Size(190,700)
$textResultsOpen.Multiline = $true
$textResultsOpen.ScrollBars = "Vertical"
$form.Controls.Add($textResultsOpen)

$textResultsClose = New-Object System.Windows.Forms.TextBox
$textResultsClose.Location = New-Object System.Drawing.Point(200,140)
$textResultsClose.Size = New-Object System.Drawing.Size(190,700)
$textResultsClose.Multiline = $true
$textResultsClose.ScrollBars = "Vertical"
$form.Controls.Add($textResultsClose)


function Get-PortList($portsList) {
    $ports = @()
    foreach ($part in $portsList -split ",") {
        if ($part -match "^\d+$") {
            $ports += [int]$part
        }
        elseif ($part -match "^(\d+)-(\d+)$") {
            $ports += ([int]$matches[1]..[int]$matches[2])
        }
    }
    return $ports | Sort-Object -Unique
}


# Define scan action
$buttonScan.Add_Click({

    $ip = $textIP.Text
    $portInput = $textPorts.Text
    $textResultsClose.Clear()
    $textResultsOpen.Clear()

    if (-not $ip) {
        [System.Windows.Forms.MessageBox]::Show("Please enter an IP address.")
        return
    }

    if (-not $portInput) {
        [System.Windows.Forms.MessageBox]::Show("Please enter at least one port or range.")
        return
    }

    $ports = Get-PortList $portInput
    if (-not $ports) {
        [System.Windows.Forms.MessageBox]::Show("Invalid port format. Use e.g. 22,80,1000-1010")
        return
    }
   
    foreach ($port in $ports) {
        $client = New-Object System.Net.Sockets.TcpClient
        $client.ReceiveTimeout = 50  
        $client.SendTimeout = 50     
        try {
            $client.Connect($ip, $port)   # try to connect
            $textResultsOpen.AppendText("Port $port is OPEN`r`n")
            $client.Close()

        } catch {
            $textResultsClose.AppendText("Port $port is CLOSED`r`n")
        }
        
    }

})

# Show form
[System.Windows.Forms.MessageBox]::Show("Do not change screen focus from the scanning tool, as it will freeze. It will work in the background but all live updates will be lost until sccaning it completed.")
[void]$form.ShowDialog()
