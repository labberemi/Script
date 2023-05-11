@echo off

REM Chemin du répertoire source
set src_dir="C:\chemin\du\repertoire\source"

REM Chemin du répertoire de destination
set dest_dir="C:\chemin\du\repertoire\destination"

REM Copie des dossiers spécifiés et leur contenu du répertoire source vers le répertoire de destination
xcopy /E /I /Y "%src_dir%\Dossiers1" "%dest_dir%\Dossiers1"
xcopy /E /I /Y "%src_dir%\Dossiers2" "%dest_dir%\Dossiers2"
xcopy /E /I /Y "%src_dir%\Dossiers3" "%dest_dir%\dossiers3"
xcopy /E /I /Y "%src_dir%\Dossiers4" "%dest_dir%\Dossiers4"

REM Affichage d'un message de confirmation
REM echo Les dossiers et leur contenu ont été copiés avec succès.