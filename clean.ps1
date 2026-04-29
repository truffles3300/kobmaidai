Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object Windows.Forms.Form
$form.Text = "Kobmaidai.com Cleaner"
$form.Size = New-Object Drawing.Size(520,520)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#0b0b0b"

# ===== Title =====
$title = New-Object Windows.Forms.Label
$title.Text = "Kobmaidai.com"
$title.ForeColor = "#d4af37"  # gold
$title.Font = New-Object Drawing.Font("Segoe UI",18,[Drawing.FontStyle]::Bold)
$title.Location = New-Object Drawing.Point(20,10)
$title.Size = New-Object Drawing.Size(400,40)
$form.Controls.Add($title)

# ===== Subtitle =====
$sub = New-Object Windows.Forms.Label
$sub.Text = "Cleaner Tool"
$sub.ForeColor = "Gray"
$sub.Location = New-Object Drawing.Point(22,45)
$form.Controls.Add($sub)

# ===== Mode Toggle =====
$mode = New-Object Windows.Forms.ComboBox
$mode.Items.AddRange(@("Safe Mode","Advanced Mode"))
$mode.SelectedIndex = 0
$mode.BackColor = "#1a1a1a"
$mode.ForeColor = "#d4af37"
$mode.Location = New-Object Drawing.Point(350,20)
$form.Controls.Add($mode)

# ===== Checkbox List =====
$items = @(
    "Run History",
    "Recent Files",
    "Temp Files",
    "Explorer Cache",
    "Browser History",
    "UserAssist",
    "Jump Lists"
)

$checks = @()
for ($i=0; $i -lt $items.Count; $i++) {
    $c = New-Object Windows.Forms.CheckBox
    $c.Text = $items[$i]
    $c.ForeColor = "White"
    $c.Location = New-Object Drawing.Point(40,90 + ($i*35))
    $c.Size = New-Object Drawing.Size(300,30)
    $c.Checked = $true
    $form.Controls.Add($c)
    $checks += $c
}

# ===== Progress =====
$bar = New-Object Windows.Forms.ProgressBar
$bar.Location = New-Object Drawing.Point(40,350)
$bar.Size = New-Object Drawing.Size(420,25)
$bar.Style = "Continuous"
$form.Controls.Add($bar)

# ===== Status =====
$status = New-Object Windows.Forms.Label
$status.ForeColor = "#d4af37"
$status.Location = New-Object Drawing.Point(40,380)
$status.Size = New-Object Drawing.Size(420,30)
$status.Text = "Ready"
$form.Controls.Add($status)

# ===== Button =====
$btn = New-Object Windows.Forms.Button
$btn.Text = "Start Cleaning"
$btn.BackColor = "#d4af37"
$btn.ForeColor = "Black"
$btn.FlatStyle = "Flat"
$btn.Font = New-Object Drawing.Font("Segoe UI",11,[Drawing.FontStyle]::Bold)
$btn.Location = New-Object Drawing.Point(170,420)
$btn.Size = New-Object Drawing.Size(180,40)
$form.Controls.Add($btn)

# ===== Action =====
$btn.Add_Click({

    $selected = $checks | Where-Object {$_.Checked}
    if ($selected.Count -eq 0) {
        $status.Text = "เลือกอย่างน้อย 1 รายการ"
        return
    }

    $i = 0
    foreach ($c in $selected) {

        $status.Text = "Cleaning: $($c.Text)"
        $form.Refresh()

        switch ($c.Text) {

            "Run History" {
                Remove-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name * -ErrorAction SilentlyContinue
            }

            "Recent Files" {
                Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\*" -Recurse -Force -ErrorAction SilentlyContinue
            }

            "Temp Files" {
                Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
            }

            "Explorer Cache" {
                Remove-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" -Recurse -Force -ErrorAction SilentlyContinue
            }

            "Browser History" {
                Remove-Item "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History" -Force -ErrorAction SilentlyContinue
            }

            "UserAssist" {
                Remove-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" -Recurse -Force -ErrorAction SilentlyContinue
            }

            "Jump Lists" {
                Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations\*" -Force -ErrorAction SilentlyContinue
                Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations\*" -Force -ErrorAction SilentlyContinue
            }
        }

        $i++
        $bar.Value = [int](($i / $selected.Count) * 100)
    }

    $status.Text = "Done ✔"
})

$form.ShowDialog()
