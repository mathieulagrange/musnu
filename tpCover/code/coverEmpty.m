function cover()

%% setting parameters

% set frame size
nfft = 2048;
% select number of songs
nSongs = 20;
% path to songs repository
dataPath= '/tmp/coversongs/covers32k/';
% extension of song files
extension = '.mp3';

%% building file list

% reference songs
fileNames1 = textread([dataPath 'list1.list'], '%s', 'delimiter', '\n');
% cover songs
fileNames2 = textread([dataPath 'list2.list'], '%s', 'delimiter', '\n');

fileNames = [fileNames1(1:nSongs) fileNames2(1:nSongs)]';
fileNames = fileNames(:);

%% decoding to wav if needed
%for k=1:length(fileNames), system(['lame --decode --quiet ' dataPath fileNames{k} '.mp3']); end

%% preparing data
methods = {'time', 'fourier', 'chroma', 'chroma aligned', 'chroma aligned dtw'};
score = [];

for k=1:length(fileNames)
    [s, fs] = audioread([dataPath  fileNames{k} extension]);
    a(k, :) = s(1:60*fs);
end
