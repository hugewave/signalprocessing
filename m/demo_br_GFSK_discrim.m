function [head_bits,burst_acu_pos] = demo_br_GFSK_discrim(sig,burst_bg,burstlen,symlen)
%demo_br_GFSK_discrim demodulate the br/edr gfsk
%  demodulate the br/edr gfsk
    sig  = sig(burst_bg : burst_bg + burstlen );
    dif_sig = sig(2:end).*conj(sig(1:end-1));
    dscrm_sig = angle(dif_sig);
    plot(dscrm_sig);
    head_bits = dscrm_sig > 0;
    burst_acu_pos = -1;
end