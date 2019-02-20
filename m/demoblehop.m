clear all;
clc;
fid = fopen('onehop_200M.pcm','r','b');
sig = fread(fid,'int16','l')';
fs = 200e6;
fftlen = 1024;
