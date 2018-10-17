function napping(datasetPath, dataFileName, locations, displayStyle, playSound)
% napping allows the naping of a set a wav files
%       datasetPath: path to a folder containing the wav files
%       fileName: name of csv file where locations and color code are
%       stored
%       locations: locations of elements as N-by-2 matrix
%       displayStyle: type of display 'none' (default), 'waveform',
%       'spectrogram'
%       playSound: play sound or not (default 1)

% Copyright: Mathieu Lagrange

if ~exist('datasetPath', 'var')  || isempty(datasetPath), datasetPath = '~/Desktop/environmentalSounds'; end
if ~exist('dataFileName', 'var') || isempty(dataFileName), dataFileName = ['napping' date() '_' getenv('USER') getenv('USERNAME')]; end
if ~exist('displayStyle', 'var') || isempty(displayStyle), displayStyle = 'none'; end
if ~exist('playSound', 'var') || isempty(playSound), playSound = 1; end

fileNames = dir([datasetPath '/*wav']);
nbElements = length(fileNames);

if ~nbElements
    disp(['Unable to find any wav files at given location:' datasetPath]);
    return
end

if exist([dataFileName '.csv'], 'file')
    data = csvread([dataFileName '.csv']);
    if size(data, 1)==nbElements
        locations = data(:, 1:2);
        colors = data(:, 3:end);
    end
end

if ~exist('locations', 'var')|| isempty(locations), locations = rand(nbElements, 2); end
if ~exist('colors', 'var'), colors = zeros(nbElements, 3); colors(:, 1)=1; end

minLocations = min(locations);
maxLocations = max(locations);

figure(1)
clf
set(gca,'ButtonDownFcn',@displaySound);
set(gcf,'WindowButtonUpFcn',@saveData);
%set(gcf,'DeleteFcn',@saveData);
userData.dataFileName = dataFileName;
userData.playSound = playSound;
userData.displayStyle = displayStyle;
userData.audioPlayer = audioplayer(0, 80);
set(gcf, 'Userdata', userData);

for k=1:nbElements
    h = impoint(gca, locations(k, 1), locations(k, 2));
    % Construct boundary constraint function
    fcn = makeConstrainToRectFcn('impoint', [minLocations(1) maxLocations(1)], [minLocations(2) maxLocations(2)]);
    % Enforce boundary constraint function using setPositionConstraintFcn
    setPositionConstraintFcn(h,fcn);
    setColor(h, colors(k, :));
   % setString(h, fileNames(k).name(1:3));
    set(h, 'UserData', [datasetPath '/' fileNames(k).name]) ;
end
axis square


function displaySound(hObject,~)

pos=get(gca,'CurrentPoint');

userData = get(figure(1), 'userdata');

t=findobj(gcf, 'type', 'hggroup');
for k=1:length(t)
    po = get(t(k), 'children');
    po = po(3);
    p(k, :) = [get(po, 'xdata')  get(po, 'ydata')];
    color(k, :) = get(po, 'MarkerFaceColor');
    d(k) = norm(pos(1, 1:2)-p(k, :));
end
[~, i] = min(d);

fileName = get(t(i), 'userdata');
[s, fs] = wavread(fileName);

switch(userData.displayStyle)
    case 'waveform'
        figure(2);
        plot(s);
    case 'spectrogram'
        figure(2);
        imagesc(log(abs(spectrogram(s, hanning(2048), 2048-512))));
        axis xy
    case 'spack'
        
end
figure(1);

if userData.playSound
    if isplaying(userData.audioPlayer)
        stop(userData.audioPlayer);
    else
        a=audioplayer(s, fs);
        userData.audioPlayer = a;
        set(figure(1), 'userData', userData);
        po = get(t(i), 'children');
        ms = get(po(3), 'MarkerSize');
        set(po(3), 'MarkerSize', 20)
        playblocking(a);
        set(po(3), 'MarkerSize', ms)
        set(t, 'visible', 'on');
    end
end



function saveData(hObject,~)

userData = get(figure(1), 'userdata');

t=findobj(gcf, 'type', 'hggroup');
t=sort(t);

for k=1:length(t)
    fn{k} = get(t(k), 'UserData');
end

for k=1:length(t)
    po = get(t(k), 'children');
    po = po(3);
    p(k, :) = [get(po, 'xdata')  get(po, 'ydata')];
    color(k, :) = get(po, 'MarkerFaceColor');
end

csvwrite([userData.dataFileName '.csv'], [p color]);
disp('saved')

