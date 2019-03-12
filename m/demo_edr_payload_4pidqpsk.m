function payload_bits = demo_edr_payload_4pidqpsk(sig,symlen)
%demo_edr_payload_4pidqpsk demodulate the edr payload
%  demodulate the edr payload
    syncsyms = [3 0 3 0 3 0 0 3 3 3];%
    dif_star_map = [3 2 0 1];
    best_smp = search_best_samp_point(sig,symlen);
    payload_sym = sig(best_smp:symlen:end);
    eng_threshold = mean(abs(payload_sym))/2;
    symed = 1;
    for i = 0 :20
        if abs(payload_sym(end-i)) >  eng_threshold
            symed = i;
            break;
        end
    end
    payload_sym = payload_sym(1:end -symed);
    
    dif_payload_sym = payload_sym(2:end).*conj(payload_sym(1:end-1));
    dif_payload_sym =  conj(dif_payload_sym);
    dif_phase = angle(dif_payload_sym);
   % dif_phase(dif_phase < -7*pi/8) =  dif_phase(dif_phase < -7*pi/8) + pi;
    dif_phase = dif_phase/pi*4 + 3;
    demosyms = round(round(dif_phase)/2);
    demosyms(demosyms<0) = 0;
    sym_bg = 1;
    sch_std = 0;
    for i = 1:10
        if isequal(demosyms(i:i+9),syncsyms)
            sym_bg = i;
            sch_std = 1;
            break;
        end 
    end
    if sch_std ==0
        payload_bits = [];
        return;
    end
    demosyms = demosyms(sym_bg:end);
    demosyms = dif_star_map(demosyms+1);
    
    payload_bits = dec2bin(demosyms,2) - '0';
    payload_bits = reshape(payload_bits',1,[]);
end