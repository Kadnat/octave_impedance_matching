# Calculateur d'Adaptation d'Impédance RF

Ce projet permet de calculer les réseaux d'adaptation d'impédance en L et affiche les résultats sous forme textuelle. Il est implémenté en MATLAB/Octave et dispose d'une interface graphique pour faciliter la saisie des paramètres.

## Fonctionnalités

- Calcul des réseaux d'adaptation en L (normal et inversé)
- Gestion automatique des cas spéciaux (impédances à parties réelles égales)
- Support des préfixes SI (G, M, k, m, u, n, p) pour simplifier la saisie
- Calcul du facteur Q optimal pour chaque configuration
- Interface graphique pour la saisie des paramètres
- Identification automatique du meilleur type de réseau selon les conditions de faisabilité
- Gestion des multiples solutions possibles pour un même problème d'adaptation

## Prérequis

- MATLAB ou GNU Octave
- Package de base (pas de dépendances spéciales requises)

## Installation

1. Clonez ce dépôt :
```bash
git clone https://github.com/Kadnat/octave_impedance_matching.git
```

2. Ajoutez le dossier au path MATLAB/Octave :
```matlab
addpath('chemin/vers/le/dossier')
```

## Utilisation

1. Lancez l'interface graphique :
```matlab
impedance_gui
```

2. Entrez les paramètres :
   - Load Real(Z) : Partie réelle de l'impédance de charge (Ω)
   - Load Imag(Z) : Partie imaginaire de l'impédance de charge (Ω)
   - Source Real(Z) : Partie réelle de l'impédance source (Ω)
   - Source Imag(Z) : Partie imaginaire de l'impédance source (Ω)
   - Z0 : Impédance caractéristique (typiquement 50Ω)
   - Freq : Fréquence de travail (avec préfixe SI)

3. Cliquez sur "Calculer" pour voir les résultats

Exemples de valeurs :
- Fréquence : "2.4G" pour 2.4 GHz, "100M" pour 100 MHz
- Impédances : "50" pour 50Ω
- Préfixes supportés : G (Giga), M (Mega), k (kilo), m (milli), u (micro), n (nano), p (pico)

## Fondements théoriques


### Types de réseaux d'adaptation

Ce programme se concentre sur les réseaux d'adaptation en L, qui sont composés de deux éléments réactifs. Ces réseaux sont les plus simples pour réaliser une adaptation d'impédance.
#### Réseau en L normal (parallèle-série)
Configuration: Source → [Composant parallèle] → [Composant série] → Charge

Utilisé lorsque la partie réelle de l'impédance source est supérieure à celle de la charge.

#### Réseau en L inversé (série-parallèle)
Configuration: Source → [Composant série] → [Composant parallèle] → Charge

Utilisé lorsque la partie réelle de l'impédance source est inférieure à celle de la charge.

#### Cas spécial: parties réelles égales
Lorsque les parties réelles des impédances source et charge sont égales, un seul composant réactif en série est nécessaire pour l'adaptation.

## Conditions de faisabilité

### Pour Rs > Rl (Réseau normal)
Pour qu'un réseau en L normal puisse adapter l'impédance de charge à celle de la source, la condition suivante doit être satisfaite :
```
|Im(Zl)| >= sqrt(Rl * (Rs - Rl))
```

### Pour Rs < Rl (Réseau inversé)
Pour qu'un réseau en L inversé puisse adapter l'impédance de charge à celle de la source, la condition suivante doit être satisfaite :
```
|Im(Zs)| >= sqrt(Rs * (Rl - Rs))
```

### Cas de double faisabilité
Dans certaines situations, les deux types de réseaux (normal et inversé) peuvent être utilisés. Le programme calcule alors toutes les solutions possibles.

## Algorithme de calcul

### Facteur de qualité (Q)
Le facteur Q détermine la sélectivité du circuit et les pertes. Le programme calcule le facteur Q optimal pour chaque configuration selon la formule :
```
Q = sqrt((Rn/Rd - 1) + (Xn^2)/(Rn*Rd))
```
où:
- Rn = partie réelle du numérateur (Zs pour réseau normal, Zl pour réseau inversé)
- Rd = partie réelle du dénominateur (Zl pour réseau normal, Zs pour réseau inversé)
- Xn = partie imaginaire du numérateur

### Calcul des réactances
Le programme calcule les valeurs des réactances X1 et X2 pour les deux composants du réseau en L:

#### Pour X1 (premier composant):
```
X1 = (Xn ± Rn*Q)/(Rn/Rd - 1)
```

#### Pour X2 (second composant):
```
X2 = -(Xi ± Ri*Q)
```
où Xi et Ri sont les parties imaginaire et réelle de l'impédance de référence.

### Conversion en valeurs de composants
Les réactances calculées sont converties en valeurs d'inductance ou de capacité selon leur signe:

#### Pour une inductance (réactance positive):
```
L = X/(2*pi*f)
```

#### Pour un condensateur (réactance négative):
```
C = 1/(2*pi*f*|X|)
```

### Formatage des valeurs
Le programme utilise un système intelligent de formatage qui ajuste automatiquement les préfixes SI en fonction de l'ordre de grandeur des valeurs calculées.

## Implémentation détaillée

### Structure des fichiers

- `impedance_gui.m`: Interface graphique permettant de saisir les paramètres et de lancer le calcul.
  - Gère la saisie des paramètres avec support des préfixes SI
  - Transmet les données au moteur de calcul

- `impedance_matching.m`: Moteur de calcul principal et fonctions d'affichage
  - Implémente l'algorithme de sélection du type de réseau adapté
  - Calcule les valeurs des composants pour chaque configuration possible
  - Formate les résultats pour l'affichage par le gui

### Fonctions principales

#### `impedance_matching(source_impedance, load_impedance, z0, frequency)`
Fonction principale qui orchestre le processus de calcul et d'affichage.

#### `match_network(source_impedance, load_impedance, frequency)`
Détermine le type de réseau adapté en fonction des conditions de faisabilité.

#### `calculate_normal(source, load, frequency)`
Calcule les valeurs des composants pour un réseau en L normal.

#### `calculate_reversed(source, load, frequency)`
Calcule les valeurs des composants pour un réseau en L inversé.

#### `calculate_equal_case(source, load, frequency)`
Traite le cas spécial où les parties réelles des impédances sont égales.

#### `calculate_q(numerator, denominator)`
Calcule le facteur de qualité Q du circuit.

#### `calculate_component_value(frequency, impedance)`
Convertit une réactance en valeur de composant (inductance ou capacité).

## Extensions possibles

- Ajout de réseaux en T et en Pi
- Intégration d'une visualisation sur l'abaque de Smith
- Support des composants réels avec facteurs de qualité finis
- Exportation des résultats vers des formats standard (csv, etc.)

## Références théoriques

1. Adaptation d'impédance, Joël Redoutey, 2009 (https://www.chireux.fr/mp/cours/Polys/5-adaptation_impedance.pdf)
2. Robert Lacoste's The Darker Side, Robert Lacoste, Elsevier Science, 2009
   - Chapitres sur l'adaptation d'impédance RF et les réseaux en L

3. Microwave Active Circuit Analysis and Design, Clive Poole, Elsevier Science, 2015
   - Chapitre 9

## Outils

1. Claude 3.7 Sonnet (Interface GUI)
2. Calculatrice d’adaptation d’impédance (https://fr.farnell.com/calculateur-d-adaptation-d-impedance)
3. ONLINE SMITH CHART TOOL (https://www.will-kelsey.com/smith_chart/)

## Auteur

Nathanaël Blavo Ballarin

