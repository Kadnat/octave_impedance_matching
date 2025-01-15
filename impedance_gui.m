%% Interface graphique d'adaptation d'impédance
% @file impedance_gui.m
% @brief Interface permettant de saisir les paramètres et visualiser les résultats
% @author nathanael blavo ballarin

% @brief Crée et affiche l'interface graphique principale
function impedance_gui()
    fig = figure('Name','Impedance Matching GUI','NumberTitle','off','Position',[100 100 300 250]);

    uicontrol(fig,'Style','text','String','Real(Z):','Position',[10 160 70 20]);
    realField = uicontrol(fig,'Style','edit','Position',[80 160 100 20]);

    uicontrol(fig,'Style','text','String','Imag(Z):','Position',[10 130 70 20]);
    imagField = uicontrol(fig,'Style','edit','Position',[80 130 100 20]);

    uicontrol(fig,'Style','text','String','Z0 (Ω):','Position',[10 100 70 20]);
    z0Field = uicontrol(fig,'Style','edit','Position',[80 100 100 20]);

    uicontrol(fig,'Style','text','String','ZLoad (Ω):','Position',[10 70 70 20]);
    zloadField = uicontrol(fig,'Style','edit','Position',[80 70 100 20]);

    uicontrol(fig,'Style','text','String','Freq (prefixed):','Position',[10 40 90 20]);
    freqField = uicontrol(fig,'Style','edit','Position',[100 40 100 20]);

    % Boutton calcul
    uicontrol(fig,'Style','pushbutton','String','Calculer','Position',[190 140 80 30], ...
        'Callback', @(~,~) onCompute());

    function onCompute()
        rVal = str2double(get(realField,'String'));
        iVal = str2double(get(imagField,'String'));
        z0Val = parseSIprefix(get(z0Field,'String'));
        zLoad = parseSIprefix(get(zloadField,'String'));
        freqVal = parseSIprefix(get(freqField,'String'));

        close(fig);
        zSource = rVal + 1i*iVal;
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
