# Calculateur d'Adaptation d'Impédance RF

Ce projet permet de calculer les réseaux d'adaptation d'impédance en L et affiche les résultats sous forme textuelle. Il est implémenté en MATLAB/Octave.

## Fonctionnalités

- Calcul des réseaux d'adaptation en L (normal et inversé)
- Gestion automatique des cas spéciaux (impédances égales)
- Support des préfixes SI (G, M, k, m, u, n, p)
- Calcul du facteur Q optimal
- Interface graphique pour la saisie des paramètres
- Identification automatique du meilleur type de réseau
- Affichage formaté des composants avec leurs valeurs

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
   - Load Real(Z) : Partie réelle de l'impédance de charge
   - Load Imag(Z) : Partie imaginaire de l'impédance de charge
   - Source Real(Z) : Partie réelle de l'impédance source
   - Source Imag(Z) : Partie imaginaire de l'impédance source
   - Z0 : Impédance caractéristique (typiquement 50Ω)
   - Freq : Fréquence de travail (avec préfixe SI)

3. Cliquez sur "Calculer" pour voir les résultats

Exemples de valeurs :
- Fréquence : "2.4G" pour 2.4 GHz, "100M" pour 100 MHz
- Impédances : "50" pour 50Ω
- Préfixes supportés : G (Giga), M (Mega), k (kilo), m (milli), u (micro), n (nano), p (pico)

## Structure des fichiers

- `impedance_gui.m` : Interface graphique utilisateur
- `impedance_matching.m` : Moteur de calcul et affichage
- Les résultats sont sauvegardés sous forme de PNG

## Formules utilisées

Le programme utilise les formules standard d'adaptation d'impédance :

1. Condition de faisabilité pour Rs > Rl :
   ```
   |Im(Zl)| >= sqrt(Rl * (Rs - Rl))
   ```

2. Condition de faisabilité pour Rs < Rl :
   ```
   |Im(Zs)| >= sqrt(Rs * (Rl - Rs))
   ```

où :
- Rs : partie réelle de l'impédance source
- Rl : partie réelle de l'impédance de charge
- Im(Z) : partie imaginaire de l'impédance

## Auteur

Nathanael Blavo Ballarin

## Licence

Libre d'utilisation pour des fins éducatives et personnelles.