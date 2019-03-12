function bdsig = func_ddc(insig,fc,fs,flt)
%func_ddc ±äÆµºÍÂË²¨
%ÂË²¨º¯Êı
x = 1:length(insig);
dfi = 2*pi*fc/fs;
fc = exp(-1j*dfi*x);
dds = insig.*conj(fc);
bdsig = conv(dds,flt);
end

