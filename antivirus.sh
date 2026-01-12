    #!/bin/bash

    # ==============================================================================
    # Nom du script : antivirus.sh
    # Description   : Gestion de fichiers corrompus selon un critère défini.
    # Auteur        : Herrard Clément, Navarro Thomas
    # Date          : 06/01/2026
    # Paramètres    : $1 = chemin du fichier contenant le critère (ex: .sha)
    # Codes retour  : 0 (Succès), 1 (Erreur argument), 2 (Fichier introuvable)
    # ==============================================================================

    CRITERE="" # Stock l'extension du virus
    FICHIER_CRITERE="$1"

    # Fonction : usage
    # Description : Affiche le message d'utilisation du script
    # Paramètres  : Aucun
    # Retour      : Aucun
    function usage () 
    {
        echo $0 "Usage : <chemin du fichier contenant le critère>"
    }

    # Fonction : verifier_environnement
    # Description : Vérifie que l'argument du script est valide et charge le critère
    # Paramètres  : Aucun
    # Variables globales : $FICHIER_CRITERE (lecture), $CRITERE (écriture)
    # Codes retour : 1 (Erreur argument ou fichier vide), 2 (Fichier introuvable)
    function verifier_environnement ()
    {
        if [ -z "$FICHIER_CRITERE" ]
        then
            echo "Erreur : Argument manquant." >&2 
            usage
            exit 1
        fi

        if [ ! -f "$FICHIER_CRITERE" ] || [ ! -r "$FICHIER_CRITERE" ]
        then
            echo "Erreur : Le fichier '$FICHIER_CRITERE' est introuvable ou illisible." >&2
            exit 2
        fi

        CRITERE=$(cat "$FICHIER_CRITERE" | tr -d '[:space:]')
        
        if [ -z "$CRITERE" ] 
        then
            echo "Erreur : Le fichier critère est vide." >&2
            exit 1
        fi


    }

    # Fonction : demander_fichier
    # Description : Demande à l'utilisateur un chemin de fichier ou dossier valide
    # Paramètres  : $1 = Prompt à afficher (string)
    #               $2 = Type attendu : 0 pour fichier, 1 pour dossier (entier)
    # Retour      : Affiche le chemin valide via echo
    # Codes retour : 0 (Succès), 1 (Type incorrect)
    function demander_fichier () 
    {
        prompt="$1"
        type="$2" # 0 fichier, 1 dossier
        fic=""

        # Sécurité
        if [ "$type" -ne 0 ] && [ "$type" -ne 1 ] 
        then
            echo "Erreur : Type incorrect (0 ou 1 attendu)" >&2
            return 1
        fi

        while true; do
            # Affiche le prompt mis en paramètre dans l'appel de fonction et va mettre dans la variable fic ce que l'utilisateur va taper
            read -p "$prompt" fic

            if [ "$type" -eq 0 ] 
            then
                # Cas Fichier

                # Verifie si le fichier est un fichier ordinaire et si le programme à la permission de le lire
                if [ -f "$fic" ] && [ -r "$fic" ] 
                then
                    echo "$fic"
                    return 0
                else
                    echo "Erreur : Fichier introuvable ou illisible." >&2
                fi

            elif [ "$type" -eq 1 ] 
            then
                # Cas Repertoire
                if [ -d "$fic" ] && [ -r "$fic" ]; then
                    echo "$fic"
                    return 0
                else
                    echo "Erreur : Dossier introuvable ou illisible." >&2
                fi
            fi
        done
    }

    # Fonction : chercher_virus
    # Description : Cherche tous les fichiers correspondant au critère dans un répertoire
    # Paramètres  : Aucun
    # Variables globales : $CRITERE (lecture)
    # Effet de bord : Crée/écrase le fichier historique.txt
    # Retour      : Aucun
    function chercher_virus ()
    {
        echo ""
        chemin=$(demander_fichier "Veuillez choisir le chemin du répertoire (relatif ou absolu) : " 1)
        echo ""
        echo "Votre chemin :" $chemin
        ls $chemin | find -name *$CRITERE > historique.txt
        echo ""
        echo "Voici les virus détectés au répertoire :" $chemin
        cat historique.txt
        return 0
    }

    # Fonction : afficher_contenu
    # Description : Affiche le contenu complet d'un fichier
    # Paramètres  : Aucun
    # Retour      : Code retour 0
    function afficher_contenu () 
    {

        #Appel de fonction
        fichier=$(demander_fichier "Fichier à afficher : " 0)

        echo "--- Fichier : $fichier ---"
        cat "$fichier"
        return 0
    }

    # Fonction : afficher_lignes
    # Description : Affiche X premières ou dernières lignes d'un fichier
    # Paramètres  : $1 = Mode : "head" (début) ou "tail" (fin) (string)
    # Retour      : Code retour 0 (succès)
    function afficher_lignes () 
    {
        echo ""
        fich=$(demander_fichier "Quel fichier voulez vous afficher ? " 0)
        echo ""
        read -p "Combien de lignes voulez vous lire ? " nb_lignes
        if [ "$1" = "head" ]; then
            echo "Voici les $nb_lignes premières lignes de $fich :"
            head -n "$nb_lignes" "$fich"
            return 0
        elif [ "$1" = "tail" ]; then
            echo "Voici les $nb_lignes dernières lignes de $fich :"
            tail -n "$nb_lignes" "$fich"
            return 0
        fi
    }

    # Fonction : historique
    # Description : Affiche le contenu du fichier historique.txt
    # Paramètres  : Aucun
    # Effet de bord : Lit le fichier historique.txt
    # Retour      : Aucun
    function historique () 
    {
        echo ""
        echo "Voici l'historique des fichiers corrompus :"
        echo ""
        cat historique.txt
    }

    # Fonction : compter_virus
    # Description : Compte et affiche le nombre de lignes dans historique.txt
    # Paramètres  : Aucun
    # Effet de bord : Lit le fichier historique.txt
    # Retour      : Aucun   
    function compter_virus () 
    {
        echo ""
        echo "Voici le nombre de virus que vous avez sur votre appareil : "
        echo ""
        cat historique.txt | wc -l
    }   


    # --- CORPS PRINCIPAL ---

    verifier_environnement

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