clear all;
clc;
freqsets = 2402:2480;
rela_freqsets = 12e6:1e6:90e6;
fs = 200e6;
symrate = 1e6;
symlen = fs/symrate;
sps = fs/symrate;
span = 96;
rolloff = 0.4;
h = rcosdesign(rolloff,span,sps);
w = blackman(length(h));
flt = h.*w';
%load('flt.mat');
%flt = flt(1:2:end);
fid = fopen('E:\BaiduNetdiskDownload\usrp_samples_real（电话语音）.pcm','r','b');
bursts_info = load('burst_info_flted.txt');
%%% frqId   start  end  length   snr
%bursts_info = bursts_info(bursts_info(:,1) >= 73 | bursts_info(:,1) <= 22 ,:);
bursts_info = bursts_info(bursts_info(:,4) > 76000,:);
bursts_info = bursts_info(bursts_info(:,4) < 90000,:);
%bursts_info = sortrows(bursts_info,2);
fot = fopen('usrp_samples_real_电话语音_demo.dat','w','b');
for i = 1:size(bursts_info,1)
    info = bursts_info(i,:);
    freq_id = info(1);
    otfrq = freqsets(freq_id);
    bgp = info(2) - 4000;
    frq = rela_freqsets(freq_id);
    snr_eng = info(5);
    %siglen = 125000*5;
    siglen = 100000;
    fseek(fid,bgp*2,'bof');
    sig = fread(fid,siglen,'int16','l')'; 
    bd = func_ddc(sig,frq,fs,flt);
    sig = bd(round(length(flt)/2):end);

    smooth_len = 4000;
    [burst_bg,burstlen] = searchburstinfo(sig,smooth_len);
    if burstlen < 7000
        continue;
    end
    [head_bits,burst_acu_pos] = demo_edr_head(sig,burst_bg,symlen);
    if isequal(head_bits(1:5),[0 1 0 1 0])  || isequal(head_bits(1:5),[1 0 1 0 1])
    burst_ed = burst_bg + burstlen-1;
    payload_sig = sig(burst_acu_pos + 126*symlen : burst_ed);
    payload_bits = demo_edr_payload_4pidqpsk(payload_sig,symlen);
    demobits = [head_bits payload_bits];
    fwrite(fot,otfrq,'int16','l');
    fwrite(fot,bgp + burst_acu_pos -1,'int32','l');
    fwrite(fot,round(snr_eng),'int16','l');
    fwrite(fot,length(demobits),'int16','l');
    fwrite(fot,demobits,'char');
    end
end
fclose('all');
    
    %%
   