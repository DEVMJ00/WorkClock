# calculette.ps1

<#
.SYNOPSIS
    Calculatrice de temps de travail permettant de calculer le temps total effectué en fonction des heures d'arrivée et de départ.
    Elle permet également de calculer l'heure estimée de fin de journée en fonction d'un quota journalier.

.DESCRIPTION
    Cette application graphique permet à un utilisateur de saisir les heures d'arrivée et de départ pour le matin et l'après-midi,
    puis de calculer le temps total effectué. L'utilisateur peut aussi entrer un quota horaire quotidien et obtenir l'heure estimée 
    de fin de journée si la journée de travail n'est pas terminée.

.PARAMETER Quota journalier
    Le quota journalier à atteindre en heures, utilisé pour calculer l'heure estimée de fin.

.PARAMETER Heures de travail
    Les heures d'arrivée et de départ pour le matin et l'après-midi, au format "HH:mm", sont utilisées pour calculer le temps 
    total effectué.

.EXAMPLES
    Exemple d'utilisation:
    - L'utilisateur entre son quota journalier (par exemple, 8 heures).
    - L'utilisateur saisit ses heures de travail pour le matin (ex. 08:00-12:00) et l'après-midi (ex. 13:00-17:00).
    - Le calcul de l'heure estimée de fin ou du temps total effectué s'affiche dans l'interface graphique.
#>


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$margeGauche = 20 ;
$margeDroite = 20 ;


# === Fenêtre principale ===
$form = New-Object System.Windows.Forms.Form
$form.Text = "Calculette de Temps de Travail"
$form.Size = New-Object System.Drawing.Size(500, 500)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "Fixed3D"
$form.MaximizeBox = $false

# Créer une image (logo) dans un PictureBox
$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Size = New-Object System.Drawing.Size(70, 50) # Taille de l'image
$pictureBox.Location = New-Object System.Drawing.Point(0, 0) # Position à gauche du label
$pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
$pictureBox.BackColor = [System.Drawing.Color]::Transparent
$pictureBox.Image = [System.Drawing.Image]::FromFile("$PSScriptRoot\logo.png") 
$form.Controls.Add($pictureBox)

# === HEADER GRAPHIQUE ===
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Size = New-Object System.Drawing.Size(600, 50)
$headerPanel.BackColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
$headerPanel.Dock = "Top"
$form.Controls.Add($headerPanel)

# Titre du projet
$labelHeader = New-Object System.Windows.Forms.Label
$labelHeader.Text = "WorkClock"
$labelHeader.ForeColor = [System.Drawing.Color]::FromArgb(0, 50, 100)
$labelHeader.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$labelHeader.AutoSize = $true
$headerPanel.Controls.Add($labelHeader)
$labelHeader.Location = New-Object System.Drawing.Point(80, 10)

# === Labels et zones de texte ===
$labelsText = @(
    "Quota journalier (en heures) :",
    "Heure d'arrivée matin (HH:mm) :",
    "Heure de départ matin (HH:mm) :",
    "Heure d'arrivée après-midi (HH:mm) :",
    "Heure de départ après-midi (HH:mm) :"
)

$textboxes = @()

for ($i = 0; $i -lt $labelsText.Length; $i++) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $labelsText[$i]
    $label.Location = New-Object System.Drawing.Point(($margeGauche), (80 + $i * 40))
    $label.Size = New-Object System.Drawing.Size(300, 20)
    $form.Controls.Add($label)

    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Location = New-Object System.Drawing.Point(($label.Location.X + ($label.Size.Width + $margeDroite)), (80 + $i * 40))
    $textbox.Size = New-Object System.Drawing.Size(100, 20)
    $form.Controls.Add($textbox)

    $textboxes += $textbox
}

$quotaBox   = $textboxes[0]
$startAmBox = $textboxes[1]
$endAmBox   = $textboxes[2]
$startPmBox = $textboxes[3]
$endPmBox   = $textboxes[4]

# === Résultat ===
$resultLabel = New-Object System.Windows.Forms.Label
$resultLabel.Location = New-Object System.Drawing.Point($margeGauche, 300)
$resultLabel.Size = New-Object System.Drawing.Size(360, 60)
$resultLabel.ForeColor = "Green"
$resultLabel.Text = ""
$form.Controls.Add($resultLabel)

# === Bouton Calculer ===
$calcButton = New-Object System.Windows.Forms.Button
$calcButton.Text = "Calculer"
$calcButton.Size = New-Object System.Drawing.Size(100, 30)
$form.Controls.Add($calcButton)

# Centrer le bouton à l'initialisation
$calcButton.Location = New-Object System.Drawing.Point(
[Math]::Max(0, ($form.ClientSize.Width - $calcButton.Size.Width) / 2), 350)
# === Événement click ===
$calcButton.Add_Click({
    try {
        $quota = [double]$quotaBox.Text
        $targetTime = [timespan]::FromHours($quota)

        function Parse-Time($t) {
            if ([string]::IsNullOrWhiteSpace($t)) { return $null }
            return [datetime]::ParseExact($t, "HH:mm", $null)
        }

        $startAm = Parse-Time $startAmBox.Text
        $endAm   = Parse-Time $endAmBox.Text
        $startPm = Parse-Time $startPmBox.Text
        $endPm   = Parse-Time $endPmBox.Text

        $total = [timespan]::Zero

        if ($startAm -and $endAm) {
            $total += $endAm - $startAm
        }

        if ($startPm -and $endPm) {
            $total += $endPm - $startPm
        }

        if (($startAm -and $endAm) -and ($startPm -and -not $endPm)) {
            # Matin fait, début d'aprèm commencé
            $reste = $targetTime - $total
            $heureFinEstimee = $startPm + $reste
            $resultLabel.Text = "Heure estimée de fin : $($heureFinEstimee.ToString('HH:mm'))"
        } else {
            $resultLabel.Text = "Temps total effectué : $([math]::Floor($total.TotalHours)) h et $([math]::Round(($total.TotalMinutes % 60), 2)) min"

        }
    } catch {
        $resultLabel.Text = "Erreur : Vérifie le format (HH:mm) et les champs requis."
    }
})


# === Bouton Réinitialiser ===
$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Text = "Réinitialiser"
$resetButton.Size = New-Object System.Drawing.Size(100, 30)
$resetButtonX = $calcButton.Location.X 
$resetButtonY = $calcButton.Location.Y + 10 + $calcButton.Size.Height
$resetButton.Location = New-Object System.Drawing.Point($resetButtonX, $resetButtonY)
$form.Controls.Add($resetButton)



# Événement : efface tous les champs
$resetButton.Add_Click({
    foreach ($tb in $textboxes) {
        $tb.Text = ""
        $resultLabel.Text = ""
    }
})



# === Affichage ===
$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()


