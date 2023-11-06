function [New_Parcellation] = f_AddRegionNames(parcellation)
% Version 1.0 Patrick Doran   03/31/2022
% This function is essentially a dictionary that converts abbreviated names
% of Allen regions to full names. If adds a list of full names to the
% parcellation structure, which only has abbreviated names before this
% fucntion is used. 
New_Parcellation = parcellation;
LeftValidFull = {};
RightValidFull = {};

for x = 1:length(parcellation.LeftValid)
    switch char(parcellation.LeftValid(x))
        case 'MOB'
            LeftValidFull(x) = cellstr('Main Olfactory Bulb');
        case 'FRP'
            LeftValidFull(x) = cellstr('Frontal Pole');
        case 'MOs'
            LeftValidFull(x) = cellstr('Secondary Motor Area');
        case 'PL'
            LeftValidFull(x) = cellstr('Prelimbic Area');
        case 'ACAd'
            LeftValidFull(x) = cellstr('Dorsal Anterior Cingulate Area');
        case 'RSPv'
            LeftValidFull(x) = cellstr('Ventral Retrosplenial Area');
        case 'RSPd'
            LeftValidFull(x) = cellstr('Dorsal Retrosplenial Area');
        case 'RSPagl'
            LeftValidFull(x) = cellstr('Lateral Agranular Retrosplenial Area');
        case 'VISC'
            LeftValidFull(x) = cellstr('Visceral Area');
        case 'SSs'
            LeftValidFull(x) = cellstr('Supplemental Somatosensory Area');
        case 'TEa'
            LeftValidFull(x) = cellstr('Temporal Association Areas');
        case 'AUDd'
            LeftValidFull(x) = cellstr('Dorsal Auditory Area');
        case 'AUDp'
            LeftValidFull(x) = cellstr('Primary Auditory Area');
        case 'AUDpo'
            LeftValidFull(x) = cellstr('Posterior Auditory Area');
        case 'AUDv'
            LeftValidFull(x) = cellstr('Ventral Auditory Area');
        case 'VISli'
            LeftValidFull(x) = cellstr('Laterointermediate Area');
        case 'VISpor'
            LeftValidFull(x) = cellstr('Postrhinal Area');
        case 'VISpl'
            LeftValidFull(x) = cellstr('Posterolateral Visual Area');
        case 'VISl'
            LeftValidFull(x) = cellstr('Lateral Visual Area');
        case 'VISal'
            LeftValidFull(x) = cellstr('Anterolateral Visual Area');
        case 'VISp'
            LeftValidFull(x) = cellstr('Primary Visual Area');
        case 'MOp'
            LeftValidFull(x) = cellstr('Primary Motor Area');
        case 'SSp-n'
            LeftValidFull(x) = cellstr('Primary Somatosensory Area: Nose');
        case 'SSp-m'
             LeftValidFull(x) = cellstr('Primary Somatosensory Area: Mouth');
        case 'SSp-un'
             LeftValidFull(x) = cellstr('Primary Somatosensory Area: Unassigned');
        case 'SSp-bfd'
              LeftValidFull(x) = cellstr('Primary Somatosensory Area: Barrel Field');
        case 'SSp-tr'
              LeftValidFull(x) = cellstr('Primary Somatosensory Area: Trunk');
        case 'SSp-ll'
              LeftValidFull(x) = cellstr('Primary Somatosensory Area: Lower Limb');
        case 'SSp-ul'
             LeftValidFull(x) = cellstr('Primary Somatosensory Area: Upper Limb');
        case 'VISpm'
            LeftValidFull(x) = cellstr('Posteromedial Visual Area');
        case 'VISrl'
            LeftValidFull(x) = cellstr('Rostrolateral Visual Area');
        case 'VISa'
            LeftValidFull(x) = cellstr('Anterior Visual Area');
        case 'VISam'
            LeftValidFull(x) = cellstr('Anteromedial Visual Area');
        otherwise
            fprintf('You need to include %s in the switch!',char(parcellation.LeftValid(x)))
    end
end

for x = 1:length(parcellation.RightValid)
    switch char(parcellation.RightValid(x))
        case 'MOB'
            RightValidFull(x) = cellstr('Main Olfactory Bulb');
        case 'FRP'
            RightValidFull(x) = cellstr('Frontal Pole');
        case 'MOs'
            RightValidFull(x) = cellstr('Secondary Motor Area');
        case 'PL'
            RightValidFull(x) = cellstr('Prelimbic Area');
        case 'ACAd'
            RightValidFull(x) = cellstr('Dorsal Anterior Cingulate Area');
        case 'RSPv'
            RightValidFull(x) = cellstr('Ventral Retrosplenial Area');
        case 'RSPd'
            RightValidFull(x) = cellstr('Dorsal Retrosplenial Area');
        case 'RSPagl'
            RightValidFull(x) = cellstr('Lateral Agranular Retrosplenial Area');
        case 'VISC'
            RightValidFull(x) = cellstr('Visceral Area');
        case 'SSs'
            RightValidFull(x) = cellstr('Supplemental Somatosensory Area');
        case 'TEa'
            RightValidFull(x) = cellstr('Temporal Association Areas');
        case 'AUDd'
            RightValidFull(x) = cellstr('Dorsal Auditory Area');
        case 'AUDp'
            RightValidFull(x) = cellstr('Primary Auditory Area');
        case 'AUDpo'
            RightValidFull(x) = cellstr('Posterior Auditory Area');
        case 'AUDv'
            RightValidFull(x) = cellstr('Ventral Auditory Area');
        case 'VISli'
            RightValidFull(x) = cellstr('Laterointermediate Area');
        case 'VISpor'
            RightValidFull(x) = cellstr('Postrhinal Area');
        case 'VISpl'
            RightValidFull(x) = cellstr('Posterolateral Visual Area');
        case 'VISl'
            RightValidFull(x) = cellstr('Lateral Visual Area');
        case 'VISal'
            RightValidFull(x) = cellstr('Anterolateral Visual Area');
        case 'VISp'
            RightValidFull(x) = cellstr('Primary Visual Area');
        case 'MOp'
            RightValidFull(x) = cellstr('Primary Motor Area');
        case 'SSp-n'
            RightValidFull(x) = cellstr('Primary Somatosensory Area: Nose');
        case 'SSp-m'
             RightValidFull(x) = cellstr('Primary Somatosensory Area: Mouth');
        case 'SSp-un'
             RightValidFull(x) = cellstr('Primary Somatosensory Area: Unassigned');
        case 'SSp-bfd'
              RightValidFull(x) = cellstr('Primary Somatosensory Area: Barrel Field');
        case 'SSp-tr'
              RightValidFull(x) = cellstr('Primary Somatosensory Area: Trunk');
        case 'SSp-ll'
              RightValidFull(x) = cellstr('Primary Somatosensory Area: Lower Limb');
        case 'SSp-ul'
             RightValidFull(x) = cellstr('Primary Somatosensory Area: Upper Limb');
        case 'VISpm'
            RightValidFull(x) = cellstr('Posteromedial Visual Area');
        case 'VISrl'
            RightValidFull(x) = cellstr('Rostrolateral Visual Area');
        case 'VISa'
            RightValidFull(x) = cellstr('Anterior Visual Area');
        case 'VISam'
            RightValidFull(x) = cellstr('Anteromedial Visual Area');
        otherwise
            fprintf('You need to include %s in the switch!',char(parcellation.LeftValid(x)))
    end
end
New_Parcellation.LeftValidFull = LeftValidFull;
New_Parcellation.RightValidFull = RightValidFull;

end
