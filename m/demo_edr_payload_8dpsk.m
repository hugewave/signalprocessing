function payload_bits = demo_edr_payload_8dpsk(sig,symlen)
%demo_edr_payload_8dpsk demodulate the edr payload
%  demodulate the edr payload
    syncsyms = [6 0 6 0 6 0 0 6 6 6];
    dif_star_map = [7 5 4 0 1 3 2 6];
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
    dif_phase(dif_phase < -7*pi/8) =  dif_phase(dif_phase < -7*pi/8) + 2*pi;
    dif_phase = dif_phase/pi*4 + 3;
    demosyms = round(dif_phase);
    demosyms(demosyms<0) = 0;
    sym_bg = 1;
    for i = 1:10
        if isequal(demosyms(i:i+9),syncsyms)
            sym_bg = i;
            break;
        end 
    end
    demosyms = demosyms(sym_bg:end);
    demosyms = dif_star_map(demosyms+1);
    
    payload_bits = dec2bin(demosyms,3) - '0';
    payload_bits = reshape(payload_bits',1,[]);
end