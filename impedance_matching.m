%% Programme d'adaptation d'impédance avec abaque de Smith
% @file impedance_matching.m
% @brief Calcule et affiche les réseaux d'adaptation d'impédance
% @author nathanael blavo ballarin

%% Fonction principale
% @brief Calcule et affiche les réseaux d'adaptation entre deux impédances
% @param source_impedance Impédance source complexe (Ω)
% @param load_impedance Impédance de charge complexe (Ω)
% @param z0 Impédance caractéristique (Ω)
% @param frequency Fréquence de travail (Hz)
function impedance_matching(source_impedance, load_impedance, z0, frequency)
    network_count = 1;

    % Affiche l'en-tête
    printf("\nSource: %s\nLoad: %s\n\n", format_complex(source_impedance), format_complex(load_impedance));

    % Calcul des réseaux correspondants
    networks = match_network(source_impedance, load_impedance, frequency);

    % Affiche les réseaux de cas égaux
    if isfield(networks, "Equal")
        printf("L-Network %d:\n", network_count);
        equal_net = networks.Equal.Values;
        for comp = equal_net
            printf("  %s\n", format_component_full(comp{1}));
        end
        network_count++;
    end

    % Affiche les réseaux normaux
    if isfield(networks, "Normal")
        normal_nets = networks.Normal.Values;
        for i = 1:size(normal_nets, 1)
            printf("L-Network %d:\n", network_count);
            printf("  %s\n", format_component_full(normal_nets{i,1}));
            printf("  %s\n", format_component_full(normal_nets{i,2}));
            network_count++;
        end
    end

    % Affiche les réseaux inversés
    if isfield(networks, "Reversed")
        rev_nets = networks.Reversed.Values;
        for i = 1:size(rev_nets, 1)
            printf("L-Network %d:\n", network_count);
            printf("  %s\n", format_component_full(rev_nets{i,1}));
            printf("  %s\n", format_component_full(rev_nets{i,2}));
            network_count++;
        end
    end

    printf("\n");
end

% @brief Formate un composant électronique pour l'affichage
% @details Cette fonction prend un composant (inductance ou condensateur) et
%          génère une chaîne de caractères formatée incluant:
%          - Le type de composant (L ou C)
%          - Sa topologie (série ou parallèle)
%          - Sa valeur avec son unité
%
% @param comp Cellule contenant:
%             - comp{1}: Type et topologie (ex: "Inductance series")
%             - comp{2}: Valeur numérique
%             - comp{3}: Unité (ex: "nH", "pF")
% @return str Chaîne formatée (ex: "L série: 2.5nH")
% @example
%   comp = {'Inductance series', 2.5, 'nH'}
%   str = format_component_full(comp)
%   % Retourne: "L série: 2.5nH"
function str = format_component_full(comp)
    % Cas spécial: composant vide ou court-circuit
    if isempty(comp{1}) || comp{2} == 0
        str = "Court-circuit";
        return;
    end

    % Extrait la première lettre pour identifier le type (L/C)
    type = comp{1}(1);

    % Détermine la topologie (série/parallèle)
    if ~isempty(strfind(lower(comp{1}), "series"))
        topology = "série";
    else
        topology = "parallèle";
    end

    % Formate la valeur avec son unité
    value = sprintf("%.3g%s", comp{2}, comp{3});

    % Combine les éléments dans la chaîne finale
    str = sprintf("%s %s: %s", type, topology, value);
end

%% Fonctions de conversion et formatage
% @brief Convertit un nombre complexe en chaîne de caractères
% @param z Nombre complexe à formater
% @return Chaîne formatée "a+bi" ou "a-bi"
function result = format_complex(z)
    if imag(z) >= 0
        result = sprintf("%.2f+%.2fi", real(z), imag(z));
    else
        result = sprintf("%.2f%.2fi", real(z), imag(z));
    end
end

% @brief Calcule le coefficient de réflexion
% @param z Impédance complexe
% @param z0 Impédance caractéristique
% @return Coefficient de réflexion complexe
function gamma = impedance_to_gamma(z, z0)
    gamma = (z - z0) ./ (z + z0);
end

%% Fonctions de calcul des réseaux
% @brief Détermine le type de réseau d'adaptation en L nécessaire
% @details Cette fonction implémente l'algorithme de choix du réseau en L:
%   1. Compare les parties réelles des impédances pour choisir le type de réseau
%   2. Vérifie la condition de faisabilité basée sur les réactances
%   3. Formules utilisées:
%      - Condition de faisabilité pour Rs > Rl:
%        |Im(Zl)| >= sqrt(Rl * (Rs - Rl))
%      - Condition de faisabilité pour Rs < Rl:
%        |Im(Zs)| >= sqrt(Rs * (Rl - Rs))
%      où:
%      Rs = partie réelle de l'impédance source
%      Rl = partie réelle de l'impédance de charge
%      Im(Zl) = partie imaginaire de l'impédance de charge
%      Im(Zs) = partie imaginaire de l'impédance source
% @param source_impedance Impédance source complexe
% @param load_impedance Impédance de charge complexe
% @param frequency Fréquence de travail
% @return Structure contenant un ou deux réseaux possibles (Normal et/ou Reversed)
function networks = match_network(source_impedance, load_impedance, frequency)
    networks = struct();

    Rs = real(source_impedance);
    Rl = real(load_impedance);

    % Cas Rs = Rl : parties réelles égales
    if abs(Rs - Rl) < 1e-10
        networks.Equal = calculate_equal_case(source_impedance, load_impedance, frequency);
        return;
    end

    % Cas où Rs > Rl : réseau normal possible
    if Rs > Rl
        % Vérifie la condition de faisabilité
        if abs(imag(load_impedance)) >= sqrt(Rl * (Rs - Rl))
            % Les deux types de réseaux sont possibles
            networks.Normal = calculate_normal(source_impedance, load_impedance, frequency);
            networks.Reversed = calculate_reversed(source_impedance, load_impedance, frequency);
        else
            % Seul le réseau normal est possible
            networks.Normal = calculate_normal(source_impedance, load_impedance, frequency);
        end

    % Cas où Rs < Rl : réseau inversé possible
    elseif Rs < Rl
        % Vérifie la condition de faisabilité
        if abs(imag(source_impedance)) >= sqrt(Rs * (Rl - Rs))
            % Les deux types de réseaux sont possibles
            networks.Normal = calculate_normal(source_impedance, load_impedance, frequency);
            networks.Reversed = calculate_reversed(source_impedance, load_impedance, frequency);
        else
            % Seul le réseau inversé est possible
            networks.Reversed = calculate_reversed(source_impedance, load_impedance, frequency);
        end
    end
end

% @brief Calcule le réseau pour le cas où les parties réelles sont égales
% @details Cette fonction calcule le réseau d'adaptation pour le cas spécial
%          où les parties réelles des impédances source et charge sont égales.
%          Dans ce cas, un seul composant réactif en série est nécessaire.
%
% @param source Impédance source complexe sous la forme R + jX (Ω)
% @param load Impédance de charge complexe sous la forme R + jX (Ω)
% @param frequency Fréquence de travail en Hz
% @return Structure contenant:
%         - Impedance: Valeur de la réactance nécessaire
%         - Values: Cellule contenant les composants {type, valeur, unité}
function network = calculate_equal_case(source, load, frequency)
    network = struct();

    % Quand real(Zs) = real(Zl), on peut annuler les parties imaginaires
    % avec un seul composant réactif de valeur opposée à leur somme
    x2 = -(imag(load) + imag(source));
    network.Impedance = x2;

    % Détermine le type de composant (L ou C) et calcule sa valeur
    % En fonction du signe de x2:
    % - Si x2 > 0: inductance série
    % - Si x2 < 0: condensateur série
    xs = calculate_component_value(frequency, x2);

    % Ajoute l'indication 'series' au type de composant
    % Si x2 = 0, court-circuit (cas où les impédances sont conjuguées)
    if xs{2} ~= 0
        xs{1} = [xs{1} ' series'];
    else
        xs{1} = '';
        xs{2} = 0;
        xs{3} = 'Short';
    end

    % Stocke le composant calculé dans la structure de retour
    network.Values = {xs};
end

%% Fonctions de calcul des composants
% @brief Calcule le facteur de qualité Q du circuit
% @details Le facteur Q détermine la sélectivité du circuit et les pertes.
%          Plus Q est élevé, plus la bande passante est étroite.
%          Formule: Q = sqrt((Rn/Rd - 1) + (Xn^2)/(Rn*Rd))
%          où: Rn = partie réelle du numérateur
%              Rd = partie réelle du dénominateur
%              Xn = partie imaginaire du numérateur
% @param numerator Impédance du numérateur (Zs pour normal, Zl pour inversé)
% @param denominator Impédance du dénominateur (Zl pour normal, Zs pour inversé)
% @return Facteur Q (sans unité)
function q = calculate_q(numerator, denominator)
    q = sqrt(real(numerator)/real(denominator) - 1 + imag(numerator)^2/(real(numerator)*real(denominator)));
end

% @brief Calcule les valeurs de réactance X1 du premier composant
% @details Calcule les deux solutions possibles pour le premier composant
%          Formule: X1 = (Xn ± Rn*Q)/(Rn/Rd - 1)
%          où: Xn = partie imaginaire du numérateur
%              Rn = partie réelle du numérateur
%              Rd = partie réelle du dénominateur
%              Q = facteur de qualité
% @param nominator_impedance Impédance du numérateur
% @param denominator_impedance Impédance du dénominateur
% @param q Facteur de qualité calculé
% @return [X1 positif, X1 négatif] en Ohms
function [x1_p, x1_n] = calculate_x1(nominator_impedance, denominator_impedance, q)
    x1_p = (imag(nominator_impedance) + real(nominator_impedance) * q) / ...
           (real(nominator_impedance)/real(denominator_impedance) - 1);
    x1_n = (imag(nominator_impedance) - real(nominator_impedance) * q) / ...
           (real(nominator_impedance)/real(denominator_impedance) - 1);
end

% @brief Calcule les valeurs de réactance X2 du second composant
% @details Calcule les deux solutions possibles pour le second composant
%          Formule: X2 = -(Xi ± Ri*Q)
%          où: Xi = partie imaginaire de l'impédance
%              Ri = partie réelle de l'impédance
%              Q = facteur de qualité
% @param impedance Impédance de référence
% @param q Facteur de qualité calculé
% @return [X2 positif, X2 négatif] en Ohms
function [x2_p, x2_n] = calculate_x2(impedance, q)
    x2_p = -(imag(impedance) + real(impedance) * q);
    x2_n = -(imag(impedance) - real(impedance) * q);
end

% @brief Calcule les composants pour un réseau en L normal (parallèle puis série)
% @details Réseau en L normal:
%          Source --- [Composant parallèle] --- [Composant série] --- Charge
%          1. Calcule le facteur Q optimal
%          2. Détermine les réactances X1 (parallèle) et X2 (série)
%          3. Convertit les réactances en valeurs de composants L/C
% @param source Impédance source complexe
% @param load Impédance de charge complexe
% @param frequency Fréquence de travail en Hz
% @return Structure contenant les impédances et valeurs des composants
function network = calculate_normal(source, load, frequency)
    network = struct();

    % Calcul du facteur Q
    q = calculate_q(source, load);

    % Calcul des valeurs de x1 et x2
    [x1_p, x1_n] = calculate_x1(source, load, q);
    [x2_p, x2_n] = calculate_x2(load, q);

    % Stockage des valeurs d'impédance
    network.Impedance = [x1_p x2_p; x1_n x2_n];

    % Calcul des valeurs de composants
    values = cell(2, 2);
    for i = 1:2
        x1 = network.Impedance(i,1);
        x2 = network.Impedance(i,2);

        % Composant parallèle
        xp = calculate_component_value(frequency, x1);
        xp{1} = [xp{1} 'parallel'];
        % Composant en série
        xs = calculate_component_value(frequency, x2);
        xs{1} = [xs{1} 'series'];

        values(i,:) = {xp, xs};
    end

    network.Values = values;
end

% @brief Calcule les composants pour un réseau en L inversé (série puis parallèle)
% @details Réseau en L inversé:
%          Source --- [Composant série] --- [Composant parallèle] --- Charge
%          1. Calcule le facteur Q optimal avec charge/source inversées
%          2. Détermine les réactances X1 (série) et X2 (parallèle)
%          3. Convertit les réactances en valeurs de composants L/C
% @param source Impédance source complexe
% @param load Impédance de charge complexe
% @param frequency Fréquence de travail en Hz
% @return Structure contenant les impédances et valeurs des composants
function network = calculate_reversed(source, load, frequency)
    network = struct();

    % Calcul du facteur Q
    q = calculate_q(load, source);

    % Calcul des valeurs de x1 et x2
    [x1_p, x1_n] = calculate_x1(load, source, q);
    [x2_p, x2_n] = calculate_x2(source, q);

    % Stockage des valeurs d'impédance
    network.Impedance = [x1_p x2_p; x1_n x2_n];

    % Calcul des valeurs de composants
    values = cell(2, 2);
    for i = 1:2
        x1 = network.Impedance(i,1);
        x2 = network.Impedance(i,2);

        % Composant série
        xs = calculate_component_value(frequency, x2);
        xs{1} = [xs{1} ' series'];

        % Composant parallèle
        xp = calculate_component_value(frequency, x1);
        xp{1} = [xp{1} ' parallel'];

        values(i,:) = {xs, xp};
    end

    network.Values = values;
end

%% Fonctions utilitaires
% @brief Calcule la valeur d'un composant réactif
% @param frequency Fréquence de travail
% @param impedance Impédance réactive
% @return {type, valeur, unité}
function comp = calculate_component_value(frequency, impedance)
    if impedance > 0
        [value, exp] = calculate_inductance(frequency, impedance);
        unit = get_prefix(exp);
        comp = {'L', value, [unit 'H']};
    elseif impedance < 0
        [value, exp] = calculate_capacitance(frequency, impedance);
        unit = get_prefix(exp);
        comp = {'C', value, [unit 'F']};
    else
        comp = {'', 0, ''};
    end
end

% @brief Calcule la valeur d'un condensateur
% @param frequency Fréquence de travail
% @param impedance Impédance capacitive (négative)
% @return [valeur, exposant]
function [value, exponent] = calculate_capacitance(frequency, impedance)
    w = 2 * pi * frequency;
    capacitance = real(1 / (w * impedance));
    exponent = floor(log10(abs(capacitance)));
    value = reformat_value(capacitance, exponent) * (-1);
end

% @brief Calcule la valeur d'une inductance
% @param frequency Fréquence de travail
% @param impedance Impédance inductive (positive)
% @return [valeur, exposant]
function [value, exponent] = calculate_inductance(frequency, impedance)
    w = 2 * pi * frequency;
    inductance = real(impedance / w);
    exponent = floor(log10(abs(inductance)));
    value = reformat_value(inductance, exponent);
end

% @brief Obtient le préfixe SI pour un exposant donné
% @param exponent Exposant en base 10
% @return Préfixe SI correspondant
function prefix = get_prefix(exponent)
    % SI prefixes de 10^-30 à 10^30
    prefixes = {'q', 'r', 'y', 'z', 'a', 'f', 'p', 'n', 'u', 'm', '', ...
                'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y', 'R', 'Q'};

    % Calculer l'indice dans le tableau des préfixes
    idx = floor(exponent/3 + 11);

    % S'assurer que l'index est dans les limites
    idx = max(1, min(length(prefixes), idx));

    prefix = prefixes{idx};
end

% @brief Reformate une valeur selon son exposant pour affichage
% @details Cette fonction ajuste la précision d'affichage d'une valeur numérique
%          en fonction de son ordre de grandeur (exposant). Elle permet d'obtenir
%          une représentation cohérente des valeurs de composants électroniques.
%
% @param original Valeur originale à reformater
% @param exponent Exposant en base 10 de la valeur
% @return Valeur reformatée avec la précision appropriée
%
% @example Pour 1234 avec exposant 3:
%          reformat_value(1234, 3) retourne 1.23
function value = reformat_value(original, exponent)
    % Calcul des points décimaux selon l'exposant
    % Pour garder 2-3 chiffres significatifs
    decimal_points = 2 - mod(exponent, 3);

    % Ajustement de l'exposant au multiple de 3 inférieur
    % Ex: 6 devient 3, -5 devient -6
    exp = exponent - mod(exponent, 3);

    % Formatage selon le signe de l'exposant
    if exponent > 0
        % Cas des grands nombres: divise par 10^exp
        formatted = fix(original / (10^exp) * 10^decimal_points) / 10^decimal_points;
    elseif exponent < 0
        % Cas des petits nombres: multiplie par 10^|exp|
        formatted = fix(original * 10^abs(exp) * 10^decimal_points) / 10^decimal_points;
    else
        % Cas où exposant = 0
        formatted = fix(original * 10^decimal_points) / 10^decimal_points;
    end

    % Suppression des décimales si non nécessaires
    if decimal_points == 0
        formatted = fix(formatted);
    end

    value = formatted;
end
