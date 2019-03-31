clear all;
clc;
freqsets = 2402:2480;
rela_freqsets = 12e6:1e6:90e6;
fs = 200e6;
symrate = 1e6;
%baseband sam rate is 10e6
span = 96;
rolloff = 0.4;
bd_edr_flt = rcosdesign(rolloff,span,10e6/1e6);
w = blackman(length(bd_edr_flt));
bd_edr_flt =bd_edr_flt.*w';
load('flt.mat');
load('gfsk_bd_flt.mat');
%flt = flt(1:2:end);
fid = fopen('E:\BaiduNetdiskDownload\�������.pcm','r','b');
bursts_info = load('�������_wifi_flted.txt');
len_threshold = 64*200;
snr_threshold = 10;
bursts_info(bursts_info(:,4) < len_threshold ,:) = [];
bursts_info(bursts_info(:,5) < snr_threshold ,:) = [];
%%% frqId   start  end  length   snr
%bursts_info = bursts_info(bursts_info(:,1) >= 73 | bursts_info(:,1) <= 22 ,:);
%bursts_info = bursts_info(bursts_info(:,4) > 400000,:);
%bursts_info = sortrows(bursts_info,2);
fot = fopen('�������.dat','w','b');
for i = 1:size(bursts_info,1)
    info = bursts_info(i,:);
    snr_eng = info(5);
    freq_id = info(1);
    otfrq = freqsets(freq_id);
    bgp = info(2) - 8000;
    
    
    frq = rela_freqsets(freq_id);
    siglen = info(4) + 24000;
    fseek(fid,bgp*2,'bof');
    sig = fread(fid,siglen,'int16','l')'; 
    bd = func_ddc(sig,frq,fs,flt);
    sig = bd(round(length(flt)/2):end);

    smooth_len = 4000;
    [burst_bg,burstlen] = searchburstinfo(sig,smooth_len);
    if burstlen < 68*200
        continue;
    end
     sig = sig(burst_bg:burst_bg + burstlen -1);
     sig = sig(1:20:end);
%     difsig = sig(2:end).*conj(sig(1:end-1));
%     fs_sig = angle(difsig);
%     gfsk_bd = conv(fs_sig,gfsk_bd_flt);
%     gfsk_bd = gfsk_bd - mean(gfsk_bd);
%     plot(gfsk_bd);
%     fs_sig = fs_sig;
     sig = conv(sig,bd_edr_flt);
     symlen = 10;
    [demobits,burst_acu_pos] = demo_br_GFSK_dscrm(sig,symlen,gfsk_bd_flt);
%     if isequal(head_bits(1:5),[0 1 0 1 0])  || isequal(head_bits(1:5),[1 0 1 0 1])
%     burst_ed = burst_bg + burstlen-1;
%     payload_sig = sig(burst_acu_pos + 126*symlen : burst_ed);
%     payload_bits = demo_edr_payload_8dpsk(payload_sig,symlen);
%     demobits = [head_bits payload_bits];
% %     fwrite(fot,otfrq,'int16','l');
% %     fwrite(fot,bgp + burst_acu_pos -1,'int32','l');
% %     fwrite(fot,length(demobits),'int16','l');
% %     fwrite(fot,demobits,'char');
%     
    fwrite(fot,otfrq,'int16','l');
    fwrite(fot,bgp + burst_bg -1,'int32','l');
    fwrite(fot,round(snr_eng),'int16','l');
    fwrite(fot,length(demobits),'int16','l');
    fwrite(fot,demobits,'char');
%     end
end
fclose('all');
    
    %%
   