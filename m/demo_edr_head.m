function [head_bits,burst_acu_pos] = demo_edr_head(sig,burst_bg,symlen)
%demo_edr_head demodulate the edr access and header syms
%  demodulate the edr access and header syms
    sig_acs = sig(burst_bg - symlen : burst_bg - symlen + symlen*141-1);
    difsig = sig_acs(symlen+1:end).*conj(sig_acs(1:end-symlen));
    im_difsig = imag(difsig);
    best_pos = search_best_samp_point(im_difsig,symlen);
    demo_syms = im_difsig(best_pos:symlen:end);
    eng_threshold = mean(abs(demo_syms))/2;
    symbg = 1;
    for i = 1 :20
        if abs(demo_syms(i)) >  eng_threshold
            symbg = i;
            break;
        end
    end
    if length(demo_syms) < (symbg + 123)
        head_bits= zeros(1,10);
        burst_acu_pos = -1;
        return;
    end
    %edp = min(length(demo_syms),symbg + 125);
    head_syms =  demo_syms( symbg : symbg + 123);
    head_bits = head_syms > 0;
    burst_acu_pos = burst_bg + best_pos + (symbg-1)*symlen -1 -symlen/2 ;
end