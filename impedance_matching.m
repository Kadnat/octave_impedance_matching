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
    % Print header line
    printf("\nZs: %s\tZload: %s\n", format_complex(source_impedance), format_complex(load_impedance));

    % Calculate matching networks
    networks = match_network(source_impedance, load_impedance, frequency);

    % Display results for equal case
    if isfield(networks, "Equal")
        printf("Network Type: Equal\n");
        equal_net = networks.Equal.Values;
        comp = equal_net{1};  % Get the single component
        if ~isempty(comp)
            printf("%s: %7s\n", format_component_type(comp), format_component_value(comp));
        end
    end

    % Display results for normal networks
    if isfield(networks, "Normal")
        printf("Network Type: Normal\n");
        normal_nets = networks.Normal.Values;
        
        for j = 1:size(normal_nets, 1)
            comp1 = normal_nets{j,1};
            comp2 = normal_nets{j,2};
            printf("%s: %7s | %s: %7s\n", ...
                format_component_type(comp1), format_component_value(comp1), ...
                format_component_type(comp2), format_component_value(comp2));
        end
    end

    % Display results for reversed networks
    if isfield(networks, "Reversed")
        printf("Network Type: Reversed\n");
        rev_nets = networks.Reversed.Values;
        
        for j = 1:size(rev_nets, 1)
            comp1 = rev_nets{j,1};
            comp2 = rev_nets{j,2};
            printf("%s: %7s | %s: %7s\n", ...
                format_component_type(comp1), format_component_value(comp1), ...
                format_component_type(comp2), format_component_value(comp2));
        end
    end
    
    printf("-----------------------------------------------------------------\n\n");
end

% New helper functions for formatting
function str = format_component_type(comp)
    if isempty(comp{1})
        str = '';
    else
        str = sprintf("%s%s", comp{1}(1), lower(comp{1}(end)));
    end
end

function str = format_component_value(comp)
    if comp{2} == 0
        str = "Short";
    else
        val = comp{2};
        unit = comp{3};
        str = sprintf("%.3g%s", val, unit);
    end
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
% @param source Impédance source complexe
% @param load Impédance de charge complexe
% @param frequency Fréquence de travail
% @return Structure contenant l'impédance et les valeurs des composants
function network = calculate_equal_case(source, load, frequency)
    network = struct();
    
    % Calcul de l'impédance X2 = -(Xl + Xs)
    x2 = -(imag(load) + imag(source));
    network.Impedance = x2;
    
    % Calcul des valeurs de composants
    xs = calculate_component_value(frequency, x2);
    if xs{2} ~= 0
        xs{1} = [xs{1} ' series'];
    else
        xs{1} = '';
        xs{2} = 0;
        xs{3} = 'Short';
    end
    
    network.Values = {xs};
end

%% Fonctions de calcul géométrique
% @brief Calcule le point suivant sur l'abaque selon le type de connexion
% @param start Point de départ (impédance complexe)
% @param impedance Impédance à ajouter
% @param is_parallel true si connexion parallèle, false si série
% @return Nouvelle impédance complexe
function point = calculate_point(start, impedance, is_parallel)
    if is_parallel
        start_admittance = 1/start;
        admittance = 1/impedance;
        point = 1/(start_admittance + admittance);
    else
        if impedance != 0
            point = start + impedance;
        else
            point = complex(real(start), -imag(start));
        end
    end
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

% @brief Reformate une valeur selon son exposant
% @param original Valeur originale
% @param exponent Exposant en base 10
% @return Valeur reformatée
function value = reformat_value(original, exponent)
    decimal_points = 2 - mod(exponent, 3);
    exp = exponent - mod(exponent, 3);

    if exponent > 0
        formatted = fix(original / (10^exp) * 10^decimal_points) / 10^decimal_points;
    elseif exponent < 0
        formatted = fix(original * 10^abs(exp) * 10^decimal_points) / 10^decimal_points;
    else
        formatted = fix(original * 10^decimal_points) / 10^decimal_points;
    end

    if decimal_points == 0
        formatted = fix(formatted);
    end
    value = formatted;
end
