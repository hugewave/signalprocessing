function [rslt,payload_bits] = demo_edr_payload(sig,symlen)
%demo_edr_payload_8dpsk demodulate the edr payload
%  demodulate the edr payload
%  the difference of the dqpsk and d8psk is that qpsk only use the left two
%  bits
% rslt :-1--> failure  1-->qp  2 --> 8p
    syncsyms = [6 0 6 0 6 0 0 6 6 6];
    dif_star_map = [7 5 4 0 1 3 2 6];
    best_smp = search_best_samp_point(sig,symlen);
    payload_sym = sig(best_smp:symlen:end);
    eng_threshold = mean(abs(payload_sym))/2;
    symed = 1;
    for i = 0 : length(payload_sym)
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
    sync_found = 0;
    sym_bg = 1;
    for i = 1:10
        if isequal(demosyms(i:i+9),syncsyms)
            sym_bg = i;
            sync_found = 1;
            break;
        end 
    end
    
    if sync_found == 0
        rslt = -1;
        payload_bits = [];
        return;
    end
    
    demosyms = demosyms(sym_bg:end);
    demosyms = dif_star_map(demosyms+1);
    sig_type = classify_qp_8p(demosyms);
    payload_bits = dec2bin(demosyms,3) - '0';
    if sig_type ==1
        rslt = 1;
       % payload_bits = payload_bits(:,1:2);
    else
    rslt = 2;  
    end
    payload_bits = reshape(payload_bits',1,[]);
end

function  rslt = classify_qp_8p(demosyms)
%% qpsk only use the 1 2 4 7
tmp = demosyms(11:end);
totalnum = length(tmp);
qpsknum = length(find(tmp == 1)) + length(find(tmp == 2)) + length(find(tmp == 4)) + length(find(tmp == 7));
if qpsknum/totalnum > 0.95
    rslt = 1;
else
    rslt = 2;
end
end