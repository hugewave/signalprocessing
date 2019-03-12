function   symot = freq_err_corrct(syms,ef,symrate)
%freq_err_est 
%   
dfi = 2*pi*ef/symrate;
siglen = length(syms);
x = 0:1:siglen-1;
fc = exp(-1j*dfi*x);
symot = syms.*fc;
end