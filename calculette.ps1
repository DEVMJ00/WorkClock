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
    Le quota journalier à atteindre en heures, est utilisé pour calculer l'heure estimée de fin.

.PARAMETER Heures de travail
    Les heures d'arrivée et de départ pour le matin et l'après-midi, au format "HH:mm", sont utilisées pour calculer le temps 
    total effectué.

.EXAMPLES
    Exemple d'utilisation:
    - L'utilisateur entre son quota journalier (par exemple, 7h30).
    - L'utilisateur saisit ses heures de travail pour le matin (ex. 08:00-12:00) et l'après-midi (ex. 13:00-17:00).
    - Le calcul de l'heure estimée de fin ou du temps total effectué s'affiche dans l'interface graphique.
#>


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$margeGauche = 14 ;
$couleurrouge = [System.Drawing.Color]::FromArgb(230, 11, 79)
$couleurbleu = [System.Drawing.Color]::FromArgb(0, 51, 102)

# === Fenêtre principale ===
$form = New-Object System.Windows.Forms.Form
$form.Text = "Calculette de Temps de Travail"
$form.Size = New-Object System.Drawing.Size(500, 500)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "Fixed3D"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 245)


# Créer une image (logo) dans un PictureBox
$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Size = New-Object System.Drawing.Size(46, 46) # Taille de l'image
$pictureBox.Location = New-Object System.Drawing.Point(420, 14) # Position à droite du label
$pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
$pictureBox.BackColor = [System.Drawing.Color]::FromArgb(0, 51, 102)
#$pictureBox.Image = [System.Drawing.Image]::FromFile("$PSScriptRoot\logo.png") 
$logoPath = Join-Path (Get-Location) 'logo.png'
$pictureBox.Image = [System.Drawing.Image]::FromFile($logoPath)
$form.Controls.Add($pictureBox)

# === HEADER GRAPHIQUE ===
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Size = New-Object System.Drawing.Size(600, 74)
$headerPanel.BackColor = $couleurbleu
$headerPanel.Dock = "Top"
$form.Controls.Add($headerPanel)

# Label primaire "SDH"
$labelHeader = New-Object System.Windows.Forms.Label
$labelHeader.Text = "SDH"
$labelHeader.ForeColor = $couleurrouge
#$labelHeader.BackColor = [System.Drawing.Color]::Transparent
$labelHeader.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$labelHeader.AutoSize = $true
$headerPanel.Controls.Add($labelHeader)
$labelHeader.Location = New-Object System.Drawing.Point($margeGauche, 16)

# Label intermédiaire "| Groupe Action"
$labelHeaderIntermediaire = New-Object System.Windows.Forms.Label
$labelHeaderIntermediaire.Text = " |  Groupe Action"
$labelHeaderIntermediaire.ForeColor = [System.Drawing.Color]::White
$labelHeaderIntermediaire.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Regular)
$labelHeaderIntermediaire.AutoSize = $true
# Position du 2e label : juste après le 1er
$labelHeaderIntermediaire.Location = New-Object System.Drawing.Point(($labelHeader.Location.X + $labelHeader.Width), 20)
$headerPanel.Controls.Add($labelHeaderIntermediaire)

# Label secondaire "Logement"
$labelHeaderSecondaire = New-Object System.Windows.Forms.Label
$labelHeaderSecondaire.Text = "Logement"
$labelHeaderSecondaire.ForeColor = [System.Drawing.Color]::White
$labelHeaderSecondaire.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$labelHeaderSecondaire.AutoSize = $true
$labelHeaderSecondaire.Location = New-Object System.Drawing.Point(($labelHeaderIntermediaire.Location.X + $labelHeaderIntermediaire.Width), 20)
$headerPanel.Controls.Add($labelHeaderSecondaire)

# Label Footer
$labelFooter = New-Object System.Windows.Forms.Label
$labelFooter.Text = "Made with ❤ by DEVMJ"
$labelFooter.ForeColor = [System.Drawing.Color]::Gainsboro
$labelFooter.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Regular)
$labelFooter.AutoSize = $true
$labelFooter.Location = New-Object System.Drawing.Point(($form.ClientSize.Width - $labelFooter.Width - 45), ($form.ClientSize.Height - $labelFooter.Height - 10))
$form.Controls.Add($labelFooter)

function Add-TimeInput {
    param (
        [string]$labelText,
        [int]$top,
        [int]$defaultHour,
        [int]$defaultMinute,
        [string]$ForeGroundColor = "Black"  
    )

    # Labels
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $labelText
    $label.Location = New-Object System.Drawing.Point($margeGauche, ($top+15))
    $label.Size = New-Object System.Drawing.Size(200, 40)
    $label.ForeColor = [System.Drawing.Color]::$ForeGroundColor
    $form.Controls.Add($label)

    if ($labelText -eq "Quota journalier :") {
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    }

    # ComboBox Heure
    $comboHeure = New-Object System.Windows.Forms.ComboBox
    $comboHeure.Location = New-Object System.Drawing.Point(320, ($top+15))
    $comboHeure.Width = 60
    $comboHeure.DropDownStyle = 'DropDownList'
    $comboHeure.Items.AddRange((0..23 | ForEach-Object { "{0:D2}" -f $_ }))
    $comboHeure.SelectedItem = "{0:D2}" -f $defaultHour
    $form.Controls.Add($comboHeure)

    # ComboBox Minute
    $comboMinute = New-Object System.Windows.Forms.ComboBox
    $comboMinute.Location = New-Object System.Drawing.Point(390, ($top+15))
    $comboMinute.Width = 60
    $comboMinute.DropDownStyle = 'DropDownList'
    $comboMinute.Items.AddRange((0..59 | ForEach-Object { "{0:D2}" -f $_ }))
    $comboMinute.SelectedItem = "{0:D2}" -f $defaultMinute
    $form.Controls.Add($comboMinute)

    # Retourner les objets créés si tu veux les récupérer
    return @{ Heure = $comboHeure; Minute = $comboMinute }
}



function Check-saisie($saisie) {
    $h = $saisie['Heure'].SelectedItem
    $m = $saisie['Minute'].SelectedItem

    Write-Host "function Check-saisie > Valeur heure sélectionnée : '$h'"
    Write-Host "function Check-saisie > Valeur minute sélectionnée : '$m'"

    if (-not $h -or -not $m) {
        Write-Host "function Check-saisie > Erreur : une valeur n'est pas sélectionnée correctement."
        return 0
    }

    try {
        return ([int]$h * 60) + [int]$m
    } catch {
        Write-Host "function Check-saisie > Erreur de conversion : $_"
        return 0
    }
}

$inputQuota = Add-TimeInput -labelText "Quota journalier :" -top 80 -defaultHour 7 -defaultMinute 30 -ForeGroundColor "Green"
$inputMatinArrivee = Add-TimeInput -labelText "Arrivée Matin :" -top 120 -defaultHour 9 -defaultMinute 0
$inputMatinDepart  = Add-TimeInput -labelText "Départ Matin :"  -top 160 -defaultHour 12 -defaultMinute 0
$inputApremArrivee = Add-TimeInput -labelText "Arrivée Après-midi :" -top 200 -defaultHour 13 -defaultMinute 0
$inputApremDepart  = Add-TimeInput -labelText "Départ Après-midi :"  -top 240 


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
[Math]::Max(0, ($form.ClientSize.Width - $calcButton.Size.Width) / 2), 360)


# === Événement click ===
$calcButton.Add_Click({
    $arrivee_matin = Check-saisie $inputMatinArrivee
    $depart_matin  = Check-saisie $inputMatinDepart
    $arrivee_aprem = Check-saisie $inputApremArrivee
    $depart_aprem = Check-saisie $inputApremDepart
    $quota_journalier = Check-saisie $inputQuota
    


    # Cas où l'après-midi est remplie
    if ($depart_aprem -and $depart_aprem -ne 0) {
        if (
            $arrivee_matin -ge $depart_matin -or
            $arrivee_aprem -ge $depart_aprem -or
            $depart_matin -gt $arrivee_aprem
        ) {
            [System.Windows.Forms.MessageBox]::Show(
                "L'heure d'arrivée ne peut pas être supérieure ou égale à celle du départ.",
                "Erreur de saisie", 'OK', 'Error')
            return
        }


    # Calcul normal de la journée complète
    $total_minutes = ($depart_matin - $arrivee_matin) + ($depart_aprem - $arrivee_aprem)
    $manquant = $quota_journalier - $total_minutes

    if ($manquant -le 0) {
            $resultLabel.ForeColor = "Green"
            $resultLabel.Text = "Journée terminée ✅. Temps total : {0}h{1:D2}" -f `
                ([math]::Floor($total_minutes / 60)), ($total_minutes % 60)
        } else {
            $resultLabel.ForeColor = "OrangeRed"
            $resultLabel.Text = "Temps manquant : {0}h{1:D2}" -f `
                ([math]::Floor($manquant / 60)), ($manquant % 60)
        }

    # Cas où l’après-midi est en cours
    } else {
        # On vérifie uniquement la cohérence du matin
        if ($arrivee_matin -ge $depart_matin) {
            [System.Windows.Forms.MessageBox]::Show(
                "L'heure d'arrivée matin ne peut pas être supérieure ou égale à celle du départ.",
                "Erreur de saisie", 'OK', 'Error')
            return
        }

        $total_minutes = $depart_matin - $arrivee_matin
        $manquant = $quota_journalier - $total_minutes

        $heure_estimee = $arrivee_aprem + $manquant
        $heure_fin = "{0}h{1:D2}" -f ([math]::Floor($heure_estimee / 60)), ($heure_estimee % 60)

        $resultLabel.ForeColor = "OrangeRed"
        $resultLabel.Text = "Temps manquant : {0}h{1:D2}`nFin estimée : $heure_fin" -f `
            ([math]::Floor($manquant / 60)), ($manquant % 60)
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
    $inputQuota.Heure.SelectedIndex = 7
    $inputQuota.Minute.SelectedIndex = 30
    $inputMatinArrivee.Heure.SelectedIndex = 9
    $inputMatinArrivee.Minute.SelectedIndex = 0
    $inputMatinDepart.Heure.SelectedIndex = 12
    $inputMatinDepart.Minute.SelectedIndex = 0
    $inputApremArrivee.Heure.SelectedIndex = 13
    $inputApremArrivee.Minute.SelectedIndex = 0
    $inputApremDepart.Heure.SelectedIndex = 0
    $inputApremDepart.Minute.SelectedIndex = 0
})


# === Affichage ===
$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()