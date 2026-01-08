#!/bin/bash

# ==============================================================================
# Nom du script : antivirus.sh
# Description   : Gestion de fichiers corrompus selon un critère défini.
# Auteur        : Herrard Clément, Navarro Thomas
# Date          : 06/01/2026
# Paramètres    : $1 = chemin du fichier contenant le critère (ex: .sha)
# Codes retour  : 0 (Succès), 1 (Erreur argument), 2 (Fichier introuvable)
# ==============================================================================
EXTENSION=""
FICHIER="$1"

usage() {
    echo $0 "Usage : <chemin du fichier contenant le critère>"
}

afficher_contenu () {
    cat "$FICHIER"
    return 0
}


# --- CORPS PRINCIPAL ---

while true; do
    echo ""
    echo "========== MENU ANTIVIRUS ($CRITERE) =========="
    echo "1. Chercher les fichiers corrompus"
    echo "2. Déplacer les fichiers corrompus"
    echo "3. Annoter les fichiers corrompus"
    echo "4. Compter les fichiers corrompus"
    echo "5. Afficher contenu fichier"
    echo "6. Historique des corrompus"
    echo "7. Afficher X premières lignes"
    echo "8. Afficher X dernières lignes"
    echo "q. Quitter"
    echo "==============================================="
    read -p "Votre choix : " choix

    case $choix in
        1) chercher_virus ;;
        2) deplacer_virus ;;
        3) annoter_virus ;;
        4) compter_virus ;;
        5) afficher_contenu ;;
        6) historique ;;
        7) afficher_lignes "head" ;;
        8) afficher_lignes "tail" ;;
        q) echo "Fin du script."; exit 0 ;;
        *) echo "Choix invalide." ;;
    esac
done