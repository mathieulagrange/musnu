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

if ~exist('datasetPath', 'var')  || isempty(datasetPath), datasetPath = 'musicGenre'; end
if ~exist('dataFileName', 'var') || isempty(dataFileName), dataFileName = ['napping' date() '_' getenv('USER') getenv('USERNAME')]; end
if ~exist('displayStyle', 'var') || isempty(displayStyle), displayStyle = 'none'; end
if ~exist('playSound', 'var') || isempty(playSound), playSound = 1; end

fileNames = dir([datasetPath '/*wav']);
nbElements = length(fileNames);
idx=1:nbElements;

if ~nbElements
    disp(['Unable to find any wav files at given location:' datasetPath]);
    return
end

if exist([dataFileName '.csv'], 'file')
    data = csvread([dataFileName '.csv']);
    if size(data, 1)==nbElements
        locations = data(:, 1:2);
        colors = data(:, 3:end-1);
        idx = data(:, end);
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
    h = drawpoint(gca, 'position', [locations(k, 1), locations(k, 2)], 'color', colors(k, :));
    % Construct boundary constraint function
%     fcn = makeConstrainToRectFcn('impoint', [minLocations(1) maxLocations(1)], [minLocations(2) maxLocations(2)]);
    % Enforce boundary constraint function using setPositionConstraintFcn
%     setPositionConstraintFcn(h,fcn);
%     setColor(h, colors(k, :));
   % setString(h, fileNames(k).name(1:3));
   t.index = k;
   t.fileName = [datasetPath '/' fileNames(idx(k)).name];
    set(h, 'UserData', t) ;
end
axis square


function displaySound(hObject,~)

pos=get(gca,'CurrentPoint');

userData = get(figure(1), 'userdata');

t=findobj(gcf, 'type', 'images.roi.point');
for k=1:length(t)
    p(k, :) = t(k).Position;
    d(k) = norm(pos(1, 1:2)-p(k, :));
end
[~, i] = min(d);

tt = get(t(i), 'userdata');
[s, fs] = audioread(tt.fileName);

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
        t(i).Label = 'playing';
        playblocking(a);
        t(i).Label = '';
    end
end



function saveData(hObject,~)

userData = get(figure(1), 'userdata');

t=findobj(gcf, 'type', 'images.roi.point');
t=sort(t);

for k=1:length(t)
    fn = get(t(k), 'UserData');
    tt(k) = fn.index;
end

for k=1:length(t)
%     po = get(t(k), 'children');
%     po = po(1);
    p(k, :) = t(k).Position;
    color(k, :) = t(k).Color;
end

csvwrite([userData.dataFileName '.csv'], [p color tt']);
disp('saved')

