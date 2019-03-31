function [rst,demo_bits] = demo_br_edr(sig,symlen,fsk_bdflt)
%demo_br_edr demodulate br/edr sig
%  step zero: adjust the sampling rate
%  step one: discrim the signal as the fsk sig 
%  step two: searching the frame sync point
%  step three: judge if the sig is edr via the synchead
%  step four: demo the edr or return the br
%%%%%% step zero: 
sig = sig;   
% sig = adjust_samplerate(sig,symlen,fsk_bdflt);
%%%%%% step one: 
    difsig = sig(2:end).*conj(sig(1:end-1));
    fs_sig = angle(difsig);
    gfsk_bd = conv(fs_sig,fsk_bdflt);
    gfsk_bd = gfsk_bd - mean(gfsk_bd(10*symlen : (10 + 125)*symlen)); 
    best_pos = search_best_samp_point(gfsk_bd(10*symlen + 1 : (10 + 125)*symlen),symlen);
    demo_syms = gfsk_bd(best_pos:symlen:end);
   % plot(demo_syms,'*');
    demo_bits = demo_syms > 0;
%%%%% step two:
    [pos,demobits]  = searching_sync_bits_pos(demo_bits);
    if pos == -1 %%% sync not found
       rst = -1;
       demo_bits = demobits;
       return;
    end
%%%% step three:
    head_bits = demobits(1:126);%72+54
    burst_acu_pos = (pos - 1) * symlen + best_pos;
    payload_sig = sig(burst_acu_pos + 125*symlen : end);
    [rslt,payload_bits] = demo_edr_payload(payload_sig,symlen);
    if rslt == -1
        rst = -1;
        demo_bits = demobits;
        return;
    end
    rst = 1;
    demo_bits = [head_bits payload_bits];
end

function [sig_ot] = adjust_samplerate(sig,symlen,fsk_bdflt)
%% adjust the sample rate based on the fsk signal
    difsig = sig(2:end).*conj(sig(1:end-1));
    fs_sig = angle(difsig);
    gfsk_bd = conv(fs_sig,fsk_bdflt);
    l_edp = min(length(gfsk_bd) - 10 * symlen , 60 * symlen );
    gfsk_bd = gfsk_bd - mean(gfsk_bd(10*symlen : l_edp));
    fftlen = 4096;
    ft = abs(fft(abs(gfsk_bd(1:680)),fftlen));
    ftbg = round(750e3/10e6 * fftlen);
    fted = round(1250e3/10e6 * fftlen);
    [~,wz] = max(ft(ftbg:fted));
    smrate = (ftbg + wz -1 -1)/fftlen * 10e6;
    sig_ot = resample(sig,round(smrate/1000),1000);
end

function [pos,demo_bits]  = searching_sync_bits_pos(demobits)
    pos = -1 ;
    demo_bits = demobits;
    pronum = length(demobits) - 120;% 120 = 72 + 48
    for i = 1 : pronum
        tmp = demobits(i : i + 67);
        tmp_hd = sum(mod(tmp(1:5) + [1 0 1 0 1],2));
        tmp_tl = sum(mod(tmp(end-6:end) + [1 1 1 0 0 1 0],2));
        hdok = 0;
        tlok = 0;
        if tmp_hd == 5 || tmp_hd == 0
            hdok = 1;
        end
        if tmp_tl == 7 || tmp_tl == 0
            tlok = 1;
        end
        if (hdok + tlok) == 2    
                head = demobits(i + 72 : i + 72 + 47);
                head = reshape(head,3,[]);
                sm_hd = sum(mod(sum(head),3));
                tmp = demobits(i + 67 : i + 71);
                s_tail = sum(mod(tmp + [1 0 1 0 1],2)); 
                if (s_tail == 5 || s_tail == 0 ) && sm_hd ==0
                     pos = i;
                     demo_bits = demobits(i:end);
                     break;
                end
         end
    end
end

