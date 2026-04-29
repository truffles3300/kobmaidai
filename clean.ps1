Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Kmd Cleaner"
$form.Size = New-Object System.Drawing.Size(500,500)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#121212"

# Header
$title = New-Object System.Windows.Forms.Label
$title.Text = "Kmd Cleaner"
$title.ForeColor = "#00ffcc"
$title.Font = New-Object System.Drawing.Font("Segoe UI",18,[System.Drawing.FontStyle]::Bold)
$title.Location = New-Object System.Drawing.Point(20,10)
$title.Size = New-Object System.Drawing.Size(300,40)
$form.Controls.Add($title)

# Mode toggle
$mode = New-Object System.Windows.Forms.ComboBox
$mode.Items.AddRange(@("Safe","Advanced"))
$mode.SelectedIndex = 0
$mode.Location = New-Object System.Drawing.Point(350,20)
$mode.Size = New-Object System.Drawing.Size(100,25)
$form.Controls.Add($mode)

# Sections
$tasks = @(
    "Clear Run History",
    "Clear Recent Files",
    "Clear Temp Files",
    "Clear Explorer Cache",
    "Clear Browser History"
)

$checks = @()
for ($i=0;$i -lt $tasks.Count;$i++){
    $c = New-Object System.Windows.Forms.CheckBox
    $c.Text = $tasks[$i]
    $c.ForeColor = "White"
    $c.Location = New-Object System.Drawing.Point(30,70 + ($i*35))
    $c.Size = New-Object System.Drawing.Size(300,30)
    $c.Checked = $true
    $form.Controls.Add($c)
    $checks += $c
}

# Progress bar
$bar = New-Object System.Windows.Forms.ProgressBar
$bar.Location = New-Object System.Drawing.Point(30,300)
$bar.Size = New-Object System.Drawing.Size(420,25)
$form.Controls.Add($bar)

# Status
$status = New-Object System.Windows.Forms.Label
$status.ForeColor = "White"
$status.Location = New-Object System.Drawing.Point(30,330)
$status.Size = New-Object System.Drawing.Size(420,30)
$form.Controls.Add($status)

# Button
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "Start Cleaning"
$btn.BackColor = "#00cc99"
$btn.FlatStyle = "Flat"
$btn.ForeColor = "Black"
$btn.Location = New-Object System.Drawing.Point(170,380)
$btn.Size = New-Object System.Drawing.Size(150,40)
$form.Controls.Add($btn)

# Action
$btn.Add_Click({
    $selected = $checks | Where-Object {$_.Checked}
    $total = $selected.Count
    $i = 0

    foreach($c in $selected){
        $status.Text = "Cleaning: $($c.Text)"
        $form.Refresh()

        switch($c.Text){

            "Clear Run History" {
                Remove-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name * -ErrorAction SilentlyContinue
            }

            "Clear Recent Files" {
                Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\*" -Recurse -Force -ErrorAction SilentlyContinue
            }

            "Clear Temp Files" {
                Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
            }

            "Clear Explorer Cache" {
                Remove-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" -Recurse -Force -ErrorAction SilentlyContinue
            }

            "Clear Browser History" {
                Remove-Item "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History" -Force -ErrorAction SilentlyContinue
            }
        }

        $i++
        $bar.Value = [int](($i/$total)*100)
    }

    $status.Text = "Done"
})

$form.ShowDialog()
