# Autor: Luca Kaufmann
# Date: 2021/04/22
#
# Beschreibung:
#
# Dieses Script Exportiert Zyklisch alle Root DFS Namespaces
# Zudem löscht es Backup Dateien, die eine bestimmte Anzahl von Tagen alt sind. Die Dateierweiterungen, das Alter sowie der Ablageort sind definierbar.
# Der Löschvorgang erstreckt sich auf alle Unterordner
# Alle Operationen werden in einem Logfile  gespeichert
#
# 


#Variablen

#Hier können Sie den Quellordner, das Alter der Dateien (in Tagen) festgelegt werden

$Source = "C:\DFSBackup\"        # Wichtig: muss mit "\" enden
$SourceLog = "C:\DFSBackup\Log\"  # Wichtig: muss mit "\" enden
$Days = 30                       # Anzahl der Tage, nach denen die Dateien gelöscht werden


# Funktionen

function DeletelatestFiles($Source,$Days)
{
  	
    $DateBeforeXDays = (Get-Date).AddDays(-$Days)
        
    write-host "--------------------------------------------------------------------------------------"
    write-host "Löschen aller Dateien im Ordner $Source die älter sind als $Days Tage."
    write-host "--------------------------------------------------------------------------------------"
    
    Get-ChildItem $Source* -Recurse | where {$_.lastwritetime -lt $DateBeforeXDays -and -not $_.psiscontainer -and -not $_.Directory} | Remove-Item -force -verbose

}

function ExportallDfsRoot($Source)
{
    $DFSExportTarges = Get-DfsnRoot
    $Date = Get-Date -Format "yyyy_MM_dd" 
    $FilenameDomain = $env:USERDNSDOMAIN.ToLower() + "_"
    $DFSDomain = "\\" + $env:USERDNSDOMAIN.ToLower() + "\"
    foreach($Target in $DFSExportTarges)
    {

    $Target = $Target.NamespacePath
    $TempTarget = $Target.Replace($DFSDomain,$FilenameDomain)
    $NameTarget = $TempTarget.Replace(".","_")
    $NameTarget = $NameTarget.Replace("-","_")

    $Filename = $Date+"_"+$NameTarget+".xml"
    $Path = $Source+$Filename
        try{
            Dfsutil root export $Target $Path
            Write-Host $Target " - wurde erfolgreich exportiert " -ForegroundColor Green -BackgroundColor Black
        }
        catch{
            Write-Host "Fehler Beim Exportieren" -ForegroundColor Red -BackgroundColor Black
        }

    }


}

#Script

$PathTest = Test-Path -Path $Source
$PathLogTest= Test-Path -Path $SourceLog

if($PathTest-eq $false)
{
    Write-Host "Erstelle Verzeichniss" $Source  -ForegroundColor Yellow -BackgroundColor Black
    New-Item -ItemType Directory -Path $Source
}
else{

    write-host "--------------------------------------------------------------------------------------"
    write-host "Verzeichniss" $Source "Vorhanden." -ForegroundColor Green -BackgroundColor Black
    write-host "--------------------------------------------------------------------------------------"

}

if($PathLogTest -eq $false)
{
     Write-Host "Erstelle Verzeichniss" $SourceLog -ForegroundColor Yellow -BackgroundColor Black
     New-Item -ItemType Directory -Path $SourceLog
}
else{

    write-host "--------------------------------------------------------------------------------------"
    write-host "Verzeichniss" $SourceLog "Vorhanden." -ForegroundColor Green -BackgroundColor Black
    write-host "--------------------------------------------------------------------------------------"

}

$log = "$SourceLog$(get-date -format yyyy_MM_dd_HH_mm).txt"
Start-Transcript $log

DeletelatestFiles -Source $Source -Days $Days
Start-Sleep -Seconds 3
ExportallDfsRoot -Source $Source

Stop-Transcript