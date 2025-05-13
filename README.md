# Calculatrice de Temps de Travail (WorkClock)


<div align="center">
  <img src="https://github.com/user-attachments/assets/871eeeb1-80da-4dba-b753-416f4a54064d" alt="WorkClock screenshot" />
</div>


## Description
WorkClock est une application développée en PowerShell, permettant de calculer le temps de travail effectué durant une journée. Elle permet à l'utilisateur de saisir son quota de travail journalier, les heures de travail effectuées, et calcule soit le total des heures travaillées, soit l'heure de fin estimée si la journée n'est pas terminée.
L'application fonctionne sans console visible grâce à une interface graphique, et peut être lancée en tant qu'exécutable (EXE) pour faciliter son utilisation.

## Fonctionnalités
Saisie du quota journalier à effectuer.
Saisie des heures de travail du matin et de l'après-midi.
Calcul du total d'heures effectuées ou estimation de l'heure de fin.
Interface graphique simple et épurée.
Pas de console visible lors de l'exécution de l'application.
Icône personnalisée pour l'application.

## Prérequis
PowerShell : L'application a été développée et testée sur des versions récentes de PowerShell. Assurez-vous que PowerShell est installé sur votre machine (il est préinstallé sur Windows).
.NET Framework : Nécessaire pour l'exécution de l'interface graphique sous Windows.

## Installation
Clonez ou téléchargez le projet.
Ouvrez le fichier workclock.exe pour lancer l'application (il est déjà compilé depuis le script calculette.ps1).
Remarque : L'exécutable ne nécessite pas de console PowerShell, donc vous pouvez utiliser l'application directement sans aucune interaction avec PowerShell.

## Utilisation
Une fois l'application lancée, vous pourrez entrer votre quota journalier, ainsi que les heures de travail effectuées le matin et l'après-midi.
L'application calculera automatiquement le total des heures travaillées ou, si la journée n'est pas terminée, l'heure estimée de fin.

## Interface
Champ "Quota journalier" : Saisissez le nombre d'heures que vous devez travailler pendant la journée.
Champ "Heure de début" : Entrez l'heure à laquelle vous avez commencé à travailler le matin.
Champ "Heure de fin" : Entrez l'heure de fin pour votre travail de l'après-midi.
Bouton "Calculer" : Calcul du total des heures effectuées ou de l'heure de fin estimée.
