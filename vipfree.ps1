Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "ZOTHEPH BOOST"
$form.WindowState = "Maximized"
$form.StartPosition = "CenterScreen"

# รูปพื้นหลัง
$picture = New-Object System.Windows.Forms.PictureBox
$picture.Dock = "Fill"
$picture.SizeMode = "StretchImage"
$picture.Image = [System.Drawing.Image]::FromFile("logo.png")
$form.Controls.Add($picture)

# ปุ่ม Boost
$button = New-Object System.Windows.Forms.Button
$button.Text = "BOOST REG"
$button.Size = New-Object System.Drawing.Size(220,60)
$button.BackColor = "Black"
$button.ForeColor = "Purple"
$button.Font = New-Object System.Drawing.Font("Arial",16,[System.Drawing.FontStyle]::Bold)
$button.Location = New-Object System.Drawing.Point(850,650)

$button.Add_Click({
Start-Process regedit.exe -ArgumentList "/s boost.reg" -Verb RunAs
[System.Windows.Forms.MessageBox]::Show("Boost Installed!")
})

$form.Controls.Add($button)
$button.BringToFront()

$form.ShowDialog()
