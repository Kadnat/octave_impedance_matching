%% Interface graphique d'adaptation d'impédance
% @file impedance_gui.m
% @brief Interface permettant de saisir les paramètres et visualiser les résultats
% @author nathanael blavo ballarin

% @brief Crée et affiche l'interface graphique principale
function impedance_gui()
    % Create main figure with wider width (400 instead of 300)
    fig = figure('Name', 'Impedance Matching GUI', 'NumberTitle', 'off', 'Position', [100 100 400 250]);

    % Left column labels
    uicontrol(fig, 'Style', 'text', 'String', 'Load Real(Z):', 'Position', [20 160 80 20]);
    loadrealField = uicontrol(fig, 'Style', 'edit', 'Position', [110 160 120 20]);

    uicontrol(fig, 'Style', 'text', 'String', 'Load Imag(Z):', 'Position', [20 130 80 20]);
    loadimagField = uicontrol(fig, 'Style', 'edit', 'Position', [110 130 120 20]);

    uicontrol(fig, 'Style', 'text', 'String', 'Source Real(Z):', 'Position', [20 100 100 20]);
    sourcerealField = uicontrol(fig, 'Style', 'edit', 'Position', [110 100 120 20]);

    uicontrol(fig, 'Style', 'text', 'String', 'Source Imag(Z):', 'Position', [20 70 100 20]);
    sourceimagField = uicontrol(fig, 'Style', 'edit', 'Position', [110 70 120 20]);

    uicontrol(fig, 'Style', 'text', 'String', 'Z0 (Ω):', 'Position', [20 40 80 20]);
    z0Field = uicontrol(fig, 'Style', 'edit', 'Position', [110 40 120 20]);

    uicontrol(fig, 'Style', 'text', 'String', 'Freq :', 'Position', [20 10 80 20]);
    freqField = uicontrol(fig, 'Style', 'edit', 'Position', [110 10 120 20]);

    % Boutton calcul
    uicontrol(fig,'Style','pushbutton','String','Calculer','Position',[240 140 80 30], ...
        'Callback', @(~,~) onCompute());

    function onCompute()
        loadrVal = str2double(get(loadrealField,'String'));
        loadiVal = str2double(get(loadimagField,'String'));
        sourcerVal = str2double(get(sourcerealField,'String'));
        sourceiVal = str2double(get(sourceimagField,'String'));

        z0Val = parseSIprefix(get(z0Field,'String'));
        freqVal = parseSIprefix(get(freqField,'String'));


        close(fig);
        zLoad = loadrVal + 1i*loadiVal;
        zSource = sourcerVal + 1i*sourceiVal;
        impedance_matching(zSource, zLoad, z0Val, freqVal);
    end
end

% @brief Analyse une chaîne contenant un nombre avec préfixe SI
% @param txt Chaîne à analyser (ex: "2.4G" pour 2.4 GHz)
% @return Valeur numérique correspondante
% @example "2.4G" retourne 2.4e9
function val = parseSIprefix(txt)
    pattern = '([0-9.]+)\s*([a-zA-Z]?)';
    tokens = regexp(txt, pattern, 'tokens','once');
    if isempty(tokens)
        val = str2double(txt);
        return;
    end
    baseVal = str2double(tokens{1});
    switch lower(tokens{2})
        case 'k', val = baseVal * 1e3;
        case 'm', val = baseVal * 1e-3;
        case 'g', val = baseVal * 1e9;
        case 't', val = baseVal * 1e12;
        case 'u', val = baseVal * 1e-6;
        case 'n', val = baseVal * 1e-9;
        case 'p', val = baseVal * 1e-12;
        otherwise, val = baseVal;
    end
end
