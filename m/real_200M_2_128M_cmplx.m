clear all;
clc;
fid = fopen('sample_200M.pcm','r','b');
sig = fread(fid,'int16','l')';
fclose(fid);
load('tmpflt.mat');
fc = 50;
fs = 200;
bdsig = func_ddc(sig,fc,fs,tmpflt);
cmplx_200M = resample(bdsig,128,200);
fltlen = length(tmpflt);
cmplx_200M = cmplx_200M(fltlen : end - fltlen);
%cmplx_200M = cmplx_200M*exp(1j*pi/4);
r_sig = upsample(real(cmplx_200M),2,0) + upsample(imag(cmplx_200M),2,1);

plot(abs(r_sig*30));
fot = fopen('bluetooth_testsig.pcm','w','b');
fwrite(fot,r_sig,'int16','l');
fclose(fot);
fclose all;


