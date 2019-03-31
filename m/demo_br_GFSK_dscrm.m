function [demo_bits,burst_acu_pos] = demo_br_GFSK_dscrm(sig,symlen,bd_flt)
%demo_br_GFSK_dscrm demodulate the br/edr gfsk
%  demodulate the br access and header syms
    difsig = sig(2:end).*conj(sig(1:end-1));
    fs_sig = angle(difsig);
    gfsk_bd = conv(fs_sig,bd_flt);
    l_edp = min(length(gfsk_bd) - 10 * symlen , 60 * symlen );
    gfsk_bd = gfsk_bd - mean(gfsk_bd(10*symlen : l_edp));
    fftlen = 4096;
    ft = abs(fft(abs(gfsk_bd(1:680)),fftlen));
    ftbg = round(750e3/10e6 * fftlen);
    fted = round(1250e3/10e6 * fftlen);
    [~,wz] = max(ft(ftbg:fted));
    smrate = (ftbg + wz -1 -1)/fftlen * 10e6;
    gfsk_bd = resample(gfsk_bd,round(smrate/1000),1000);
    best_pos = search_best_samp_point(gfsk_bd,symlen);
    demo_syms = gfsk_bd(best_pos:symlen:end);
   % plot(demo_syms,'*');
    demo_bits = demo_syms > 0;
    burst_acu_pos = -1;
%     fs_sig = fs_sig;
%     im_difsig = imag(difsig);
%    
%     
%     eng_threshold = mean(abs(demo_syms))/2;
%     symbg = 1;
%     for i = 1 :10
%         if abs(demo_syms(i)) >  eng_threshold
%             symbg = i;
%             break;
%         end
%     end
%     if length(demo_syms) < (symbg + 68) %%%% minimum access code is  68
%         head_bits= zeros(1,10);
%         burst_acu_pos = -1;
%         return;
%     end
%     %edp = min(length(demo_syms),symbg + 125);
%     head_syms =  demo_syms( symbg : symbg + 67);
%     head_bits = head_syms > 0;
%     burst_acu_pos = burst_bg + best_pos + (symbg-1)*symlen -1 -symlen/2 ;
end
