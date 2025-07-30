#!/bin/bash

echo "=== Vérification de Conformité aux Consignes - Projet IoT ==="

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour vérifier une condition
check_requirement() {
    local condition="$1"
    local description="$2"
    local success_msg="$3"
    local failure_msg="$4"
    
    if eval "$condition"; then
        echo -e "✅ ${GREEN}$description${NC}: $success_msg"
        return 0
    else
        echo -e "❌ ${RED}$description${NC}: $failure_msg"
        return 1
    fi
}

echo ""
echo -e "${BLUE}🔍 Vérification de la structure du projet...${NC}"

# Vérification structure générale
check_requirement "[ -d 'p1' ]" "Structure P1" "Dossier p1 présent" "Dossier p1 manquant"
check_requirement "[ -d 'p2' ]" "Structure P2" "Dossier p2 présent" "Dossier p2 manquant"
check_requirement "[ -d 'p3' ]" "Structure P3" "Dossier p3 présent" "Dossier p3 manquant"

# Vérification fichiers obligatoires
check_requirement "[ -f 'p1/Vagrantfile' ]" "P1 Vagrantfile" "Fichier présent" "Fichier manquant"
check_requirement "[ -d 'p1/scripts' ]" "P1 Scripts" "Dossier scripts présent" "Dossier scripts manquant"
check_requirement "[ -d 'p1/confs' ]" "P1 Confs" "Dossier confs présent" "Dossier confs manquant"

check_requirement "[ -f 'p2/Vagrantfile' ]" "P2 Vagrantfile" "Fichier présent" "Fichier manquant"
check_requirement "[ -d 'p2/scripts' ]" "P2 Scripts" "Dossier scripts présent" "Dossier scripts manquant"
check_requirement "[ -d 'p2/confs' ]" "P2 Confs" "Dossier confs présent" "Dossier confs manquant"

check_requirement "[ -d 'p3/scripts' ]" "P3 Scripts" "Dossier scripts présent" "Dossier scripts manquant"
check_requirement "[ -d 'p3/confs' ]" "P3 Confs" "Dossier confs présent" "Dossier confs manquant"

echo ""
echo -e "${BLUE}📋 Vérification des contenus P1...${NC}"

# P1 - Vérification Vagrantfile
if [ -f "p1/Vagrantfile" ]; then
    check_requirement "grep -q 'chillionS' p1/Vagrantfile" "P1 Nom machine 1" "chillionS trouvé" "Nom machine incorrect"
    check_requirement "grep -q 'chillionSW' p1/Vagrantfile" "P1 Nom machine 2" "chillionSW trouvé" "Nom machine incorrect"
    check_requirement "grep -q '192.168.56.110' p1/Vagrantfile" "P1 IP machine 1" "IP correcte" "IP incorrecte"
    check_requirement "grep -q '192.168.56.111' p1/Vagrantfile" "P1 IP machine 2" "IP correcte" "IP incorrecte"
fi

# P1 - Scripts
check_requirement "[ -f 'p1/scripts/install_k3s_server.sh' ]" "P1 Script server" "Script présent" "Script manquant"
check_requirement "[ -f 'p1/scripts/install_k3s_agent.sh' ]" "P1 Script agent" "Script présent" "Script manquant"
check_requirement "[ -x 'p1/scripts/install_k3s_server.sh' ]" "P1 Script executable" "Scripts exécutables" "Scripts non exécutables"

echo ""
echo -e "${BLUE}🌐 Vérification des contenus P2...${NC}"

# P2 - Vérification configurations
check_requirement "[ -f 'p2/confs/app1-deployment.yaml' ]" "P2 App1 config" "Configuration présente" "Configuration manquante"
check_requirement "[ -f 'p2/confs/app2-deployment.yaml' ]" "P2 App2 config" "Configuration présente" "Configuration manquante"
check_requirement "[ -f 'p2/confs/app3-deployment.yaml' ]" "P2 App3 config" "Configuration présente" "Configuration manquante"
check_requirement "[ -f 'p2/confs/ingress.yaml' ]" "P2 Ingress" "Ingress configuré" "Ingress manquant"

# P2 - Vérification replicas App2
if [ -f "p2/confs/app2-deployment.yaml" ]; then
    check_requirement "grep -q 'replicas: 3' p2/confs/app2-deployment.yaml" "P2 App2 replicas" "3 replicas configurés" "Nombre de replicas incorrect"
fi

echo ""
echo -e "${BLUE}🚀 Vérification des contenus P3...${NC}"

# P3 - Scripts obligatoires
check_requirement "[ -f 'p3/scripts/install.sh' ]" "P3 Script installation" "Script présent" "Script manquant"
check_requirement "[ -f 'p3/scripts/setup_cluster.sh' ]" "P3 Setup cluster" "Script présent" "Script manquant"
check_requirement "[ -x 'p3/scripts/install.sh' ]" "P3 Scripts executables" "Scripts exécutables" "Scripts non exécutables"

# P3 - Configurations
check_requirement "[ -f 'p3/confs/deployment.yaml' ]" "P3 Deployment" "Configuration présente" "Configuration manquante"
check_requirement "[ -f 'p3/confs/application.yaml' ]" "P3 Argo App" "Application Argo CD configurée" "Application manquante"

# P3 - Vérification port 8888
if [ -f "p3/confs/deployment.yaml" ]; then
    check_requirement "grep -q '8888' p3/confs/deployment.yaml" "P3 Port 8888" "Port 8888 configuré" "Port 8888 non trouvé"
fi

echo ""
echo -e "${BLUE}📁 Vérification outils et documentation...${NC}"

# Outils
check_requirement "[ -f 'Makefile' ]" "Makefile" "Présent" "Manquant"
check_requirement "[ -f '.gitignore' ]" "Gitignore" "Présent" "Manquant"
check_requirement "[ -f 'Tools/cleanup.sh' ]" "Script nettoyage" "Présent" "Manquant"

# Documentation
check_requirement "[ -f 'README.md' ]" "README principal" "Présent" "Manquant"
check_requirement "[ -f 'Docs/CONSIGNES_POINTS_CLES.md' ]" "Points clés consignes" "Présent" "Manquant"
check_requirement "[ -f 'p1/README.md' ]" "README P1" "Présent" "Manquant"
check_requirement "[ -f 'p2/README.md' ]" "README P2" "Présent" "Manquant"
check_requirement "[ -f 'p3/README.md' ]" "README P3" "Présent" "Manquant"

echo ""
echo -e "${BLUE}🔧 Vérification des prérequis système...${NC}"

# Outils système
check_requirement "command -v vagrant >/dev/null 2>&1" "Vagrant installé" "Vagrant disponible" "Vagrant non installé"
check_requirement "command -v docker >/dev/null 2>&1" "Docker installé" "Docker disponible" "Docker non installé"
check_requirement "command -v kubectl >/dev/null 2>&1" "kubectl installé" "kubectl disponible" "kubectl non installé"

echo ""
echo -e "${YELLOW}📋 Résumé des points critiques pour l'évaluation:${NC}"
echo ""
echo "🎯 Partie 1:"
echo "   • 2 VMs nommées chillionS et chillionSW"
echo "   • IPs 192.168.56.110 et 192.168.56.111"
echo "   • SSH sans mot de passe"
echo "   • K3s cluster fonctionnel"
echo ""
echo "🎯 Partie 2:"
echo "   • 1 VM avec 3 applications web"
echo "   • Routing par HOST (app1.com, app2.com)"
echo "   • App2 avec exactement 3 replicas"
echo "   • Ingress configuré (ne pas montrer pendant l'éval)"
echo ""
echo "🎯 Partie 3:"
echo "   • K3d au lieu de Vagrant"
echo "   • Script d'installation des outils"
echo "   • Namespaces: argocd et dev"
echo "   • Repository GitHub public"
echo "   • Application port 8888"
echo "   • GitOps v1 → v2 démontrable"
echo ""
echo -e "${GREEN}📚 Documentation complète disponible dans Docs/CONSIGNES_POINTS_CLES.md${NC}"
echo ""
echo "✅ Vérification terminée ! Consultez les erreurs éventuelles ci-dessus."
