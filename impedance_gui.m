%% Interface graphique d'adaptation d'impédance
% @file impedance_gui.m
% @brief Interface permettant de saisir les paramètres et visualiser les résultats
% @author nathanael blavo ballarin

% @brief Crée et affiche l'interface graphique principale
function impedance_gui()
    % Créer la fenêtre principale plus large et plus haute
    fig = figure('Name', 'Calculateur d''Adaptation d''Impédance RF', 'NumberTitle', 'off', ...
                'Position', [100 100 700 500], 'Resize', 'on');
    
    % Titre principal
    uicontrol(fig, 'Style', 'text', 'String', 'Calculateur d''Adaptation d''Impédance RF', ...
             'Position', [20 460 660 30], 'FontSize', 14, 'FontWeight', 'bold');
    
    % Panneau d'informations
    uicontrol(fig, 'Style', 'text', 'String', ...
             'Ce programme calcule les réseaux d''adaptation d''impédance en L entre une source et une charge.', ...
             'Position', [20 430 660 20]);
    
    % Groupe de la charge (Load)
    uicontrol(fig, 'Style', 'frame', 'Position', [20 330 320 90]);
    uicontrol(fig, 'Style', 'text', 'String', 'Impédance de charge (Load)', ...
             'Position', [30 400 300 20], 'FontWeight', 'bold');
    
    % Champs de saisie pour la charge
    uicontrol(fig, 'Style', 'text', 'String', 'Partie réelle (Ω):', 'Position', [30 370 120 20], 'HorizontalAlignment', 'left');
    loadrealField = uicontrol(fig, 'Style', 'edit', 'Position', [150 370 180 20], 'TooltipString', 'Entrez la partie réelle de l''impédance de charge en ohms');
    
    uicontrol(fig, 'Style', 'text', 'String', 'Partie imaginaire (Ω):', 'Position', [30 340 120 20], 'HorizontalAlignment', 'left');
    loadimagField = uicontrol(fig, 'Style', 'edit', 'Position', [150 340 180 20], 'TooltipString', 'Entrez la partie imaginaire de l''impédance de charge en ohms (sans j)');
    
    % Groupe de la source
    uicontrol(fig, 'Style', 'frame', 'Position', [360 330 320 90]);
    uicontrol(fig, 'Style', 'text', 'String', 'Impédance de source', ...
             'Position', [370 400 300 20], 'FontWeight', 'bold');
    
    % Champs de saisie pour la source
    uicontrol(fig, 'Style', 'text', 'String', 'Partie réelle (Ω):', 'Position', [370 370 120 20], 'HorizontalAlignment', 'left');
    sourcerealField = uicontrol(fig, 'Style', 'edit', 'Position', [490 370 180 20], 'TooltipString', 'Entrez la partie réelle de l''impédance source en ohms');
    
    uicontrol(fig, 'Style', 'text', 'String', 'Partie imaginaire (Ω):', 'Position', [370 340 120 20], 'HorizontalAlignment', 'left');
    sourceimagField = uicontrol(fig, 'Style', 'edit', 'Position', [490 340 180 20], 'TooltipString', 'Entrez la partie imaginaire de l''impédance source en ohms (sans j)');
    
    % Groupe des paramètres système
    uicontrol(fig, 'Style', 'frame', 'Position', [20 240 660 80]);
    uicontrol(fig, 'Style', 'text', 'String', 'Paramètres système', ...
             'Position', [30 300 300 20], 'FontWeight', 'bold');
    
    % Champs pour Z0 et fréquence
    uicontrol(fig, 'Style', 'text', 'String', 'Impédance caractéristique Z0 (Ω):', 'Position', [30 270 200 20], 'HorizontalAlignment', 'left');
    z0Field = uicontrol(fig, 'Style', 'edit', 'Position', [230 270 100 20], 'String', '50', 'TooltipString', 'Typiquement 50Ω pour la plupart des systèmes RF');
    
    uicontrol(fig, 'Style', 'text', 'String', 'Fréquence de travail:', 'Position', [30 240 200 20], 'HorizontalAlignment', 'left');
    freqField = uicontrol(fig, 'Style', 'edit', 'Position', [230 240 100 20], 'TooltipString', 'Entrez la fréquence avec un préfixe SI optionnel (ex: 2.4G pour 2.4 GHz)');
    
    % Information sur les préfixes
    uicontrol(fig, 'Style', 'text', 'String', 'Préfixes SI acceptés:', 'Position', [350 270 320 20], 'HorizontalAlignment', 'left');
    uicontrol(fig, 'Style', 'text', 'String', 'G (Giga), M (Mega), k (kilo), m (milli), u (micro), n (nano), p (pico)', ...
             'Position', [350 240 320 20], 'HorizontalAlignment', 'left');
    
    % Zone de résultats - ajout d'une zone de texte pour afficher les résultats
    uicontrol(fig, 'Style', 'frame', 'Position', [20 60 660 170]);
    uicontrol(fig, 'Style', 'text', 'String', 'Résultats', ...
             'Position', [30 210 300 20], 'FontWeight', 'bold');
    
    % Zone de texte éditable mais en lecture seule pour les résultats
    resultsText = uicontrol(fig, 'Style', 'edit', ...
                           'Position', [30 70 640 140], ...
                           'Max', 2, 'Min', 0, ... % Multi-ligne
                           'HorizontalAlignment', 'left', ...
                           'Enable', 'inactive', ... % Désactivé pour l'édition
                           'BackgroundColor', [1 1 1], ... % Fond blanc
                           'String', 'Les résultats apparaîtront ici après calcul.');
    
    % Bouton de calcul
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Calculer l''adaptation', ...
             'Position', [250 20 200 30], 'FontSize', 12, ...
             'Callback', @(~,~) onCompute());
    
    % Fonction de calcul modifiée pour afficher les résultats dans l'interface
    function onCompute()
        % Validation des entrées
        if isempty(get(loadrealField, 'String')) || isempty(get(loadimagField, 'String')) || ...
           isempty(get(sourcerealField, 'String')) || isempty(get(sourceimagField, 'String')) || ...
           isempty(get(z0Field, 'String')) || isempty(get(freqField, 'String'))
            errordlg('Tous les champs doivent être remplis!', 'Erreur de saisie');
            return;
        end
        
        % Conversion des valeurs
        try
            loadrVal = str2double(get(loadrealField, 'String'));
            loadiVal = str2double(get(loadimagField, 'String'));
            sourcerVal = str2double(get(sourcerealField, 'String'));
            sourceiVal = str2double(get(sourceimagField, 'String'));
            
            z0Val = parseSIprefix(get(z0Field, 'String'));
            freqVal = parseSIprefix(get(freqField, 'String'));
            
            % Vérification des valeurs numériques
            if isnan(loadrVal) || isnan(loadiVal) || isnan(sourcerVal) || isnan(sourceiVal) || ...
               isnan(z0Val) || isnan(freqVal)
                errordlg('Une ou plusieurs valeurs ne sont pas des nombres valides!', 'Erreur de conversion');
                return;
            end
            
            % Vérification de la fréquence
            if freqVal <= 0
                errordlg('La fréquence doit être strictement positive!', 'Erreur de fréquence');
                return;
            end
            
            % Vérification de l'impédance caractéristique
            if z0Val <= 0
                errordlg('L''impédance caractéristique Z0 doit être strictement positive!', 'Erreur d''impédance');
                return;
            end
            
            % Vérification des parties réelles des impédances
            if loadrVal <= 0 || sourcerVal <= 0
                errordlg('Les parties réelles des impédances source et charge doivent être strictement positives pour une adaptation passive!', 'Erreur d''impédance');
                return;
            end
            
            % Création des impédances complexes
            zLoad = loadrVal + 1i*loadiVal;
            zSource = sourcerVal + 1i*sourceiVal;
            
            % Capture des résultats
            results = captureResults(zSource, zLoad, z0Val, freqVal);
            
            % Afficher les résultats dans la zone de texte
            set(resultsText, 'String', results);
            
        catch e
            errordlg(['Erreur lors du traitement des valeurs: ' e.message], 'Erreur');
        end
    end
    
    % Fonction pour capturer les résultats
    function results = captureResults(source_impedance, load_impedance, z0, frequency)
        % Appel direct à impedance_matching avec un paramètre de sortie
        results = impedance_matching(source_impedance, load_impedance, z0, frequency);
    end
end

% @brief Analyse une chaîne contenant un nombre avec préfixe SI
% @param txt Chaîne à analyser (ex: "2.4G" pour 2.4 GHz)
% @return Valeur numérique correspondante
% @example "2.4G" retourne 2.4e9
function val = parseSIprefix(txt)
    pattern = '([0-9.]+)\s*([a-zA-Z]?)';
    tokens = regexp(txt, pattern, 'tokens', 'once');
    if isempty(tokens)
        val = str2double(txt);
        return;
    end
    baseVal = str2double(tokens{1});
    switch lower(tokens{2})
        case 'g', val = baseVal * 1e9;  % Giga
        case 'm', val = baseVal * 1e6;  % Mega
        case 'k', val = baseVal * 1e3;  % kilo
        case 'm', val = baseVal * 1e-3; % milli
        case 'u', val = baseVal * 1e-6; % micro
        case 'n', val = baseVal * 1e-9; % nano
        case 'p', val = baseVal * 1e-12; % pico
        otherwise, val = baseVal;
    end
end