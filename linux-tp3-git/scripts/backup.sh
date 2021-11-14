 #!/bin/bash
#Backup script for minecraft server project
# Lack_off1 -- 11/11/2021

file_name='$(date '+%y%m%d_%H%M%S')'
#archivage des fichiers
tar -zcvf backup_${file_name}.tar.gz $2
rsync -av --remove-source-files backup_${file_name}.tar.gz $1

#suppression des anciennes backups si + de 5 fichiers
ls -tp $1 | grep -v '/$' | tail -n +6 | xargs -I {} rm -- $1/{}
