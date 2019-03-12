function   ef = freq_err_est(syms,symrate)
%freq_err_est frequcy offset estimation
%   frequcy offset estimation
fftlen = 8192;
if length(syms) > fftlen
    syms = syms(1:fftlen);
end
sss = syms.*syms.*syms.*syms.*syms.*syms.*syms.*syms;
ft = abs(fft(sss,fftlen));
ft = fftshift(ft);
[~,pos] = max(ft);
ef = (pos-(fftlen/2+1))/fftlen*symrate/8;
end


