function helloEmpty()

%% setting parameters

% set frame size
nfft = 2048;
dataPath = '../data/hello/';
fileNames = {'', 'Shift', 'FrameHalf', 'VocoderHalf', 'ResampleTwice', 'Noise'};

methods = {'time', 'fourier', 'chroma', 'chroma aligned', 'chroma aligned dtw'};
score = [];

for k=1:length(fileNames)
    [s, fs] = audioread([dataPath 'hello' fileNames{k} '.wav']);
    a(k, :) = s(fs:2*fs); 
end