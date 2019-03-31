clear all;
clc;
prefix = [170 187 204 221];
freqsets = 2402:2480;
rela_freqsets = 12e6:1e6:90e6;
fs = 200e6;
symrate = 1e6;
%baseband sam rate is 10e6

span = 96;
rolloff = 0.4;
h = rcosdesign(rolloff,span,200);
w = blackman(length(h));
bd_edr_flt = h.*w';

load('flt.mat');%BLE filter
load('gfsk_bd_flt.mat');
%flt = flt(1:2:end);
fid = fopen('D:\BaiduNetdiskDownload\反复配对.pcm','r','b');
bursts_info = load('反复配对_wifi_flted.txt');
len_threshold = 64*200;
snr_threshold = 10;
bursts_info(bursts_info(:,4) < len_threshold ,:) = [];
bursts_info(bursts_info(:,5) < snr_threshold ,:) = [];
%%% frqId   start  end  length   snr
%bursts_info = bursts_info(bursts_info(:,1) >= 73 | bursts_info(:,1) <= 22 ,:);
%bursts_info = bursts_info(bursts_info(:,4) > 400000,:);
%bursts_info = sortrows(bursts_info,2);
fot = fopen('反复配对.dat','w','b');
for i = 1:size(bursts_info,1)
    info = bursts_info(i,:);
    snr_eng = info(5);
    freq_id = info(1);
    otfrq = freqsets(freq_id) - 2402;
    bgp = info(2) - 8000;
    
    
    frq = rela_freqsets(freq_id);
    siglen = info(4) + 24000;
    fseek(fid,bgp*2,'bof');
    insig = fread(fid,siglen,'int16','l')'; 
    bd = func_ddc(insig,frq,fs,flt);
    sig = bd(round(length(flt)/2):end);

    smooth_len = 4000;
    [burst_bg,burstlen] = searchburstinfo(sig,smooth_len);
    if burstlen < 68*200
        continue;
    end
    
     sig = sig(burst_bg:burst_bg + burstlen -1);
     sig = sig(1:20:end);
     symlen = 10;
    [demobits,burst_acu_pos] = demo_br_GFSK_dscrm(sig,symlen,gfsk_bd_flt);
    [rslt,demo_out] = judge_ble(demobits,freq_id);
    if rslt == 1 %ble
        datatype = 2;
        fwrite(fot,prefix,'uint8');
        fwrite(fot,otfrq,'uint8','l');
        fwrite(fot,round(snr_eng),'uint8','l');
        fwrite(fot,bgp + burst_bg -1,'int32','l');
        fwrite(fot,datatype,'uint8');
        fwrite(fot,length(demo_out),'int16','l');
        t_len = mod(length(demo_out) , 8);
        if t_len > 0
            demo_out = [demo_out,zeros(1,8 - t_len)];
        end
        fwrite(fot,demo_out,'ubit1');
    end
    if rslt == 0
        if length(demo_out) > (72 + 5 + 54 + 10 + 20) %%%% at least 20 symbols    
            bd = func_ddc(insig,frq,fs,bd_edr_flt);
            sig = bd(round(length(bd_edr_flt)/2):end);
            sig = sig(1:20:end);
            [rst,demo_bits] = demo_br_edr(sig,symlen,gfsk_bd_flt);
             if rst == -1
                 datatype = 0; %%% BR
                 fwrite(fot,prefix,'uint8');
        	     fwrite(fot,otfrq,'uint8','l');
        	     fwrite(fot,round(snr_eng),'uint8','l');
        	     fwrite(fot,bgp + burst_bg -1,'int32','l');
        	     fwrite(fot,datatype,'uint8');
                 fwrite(fot,length(demo_bits),'int16','l');         
                 t_len = mod(length(demo_bits) , 8);
                 if t_len > 0
                    demo_bits = [demo_bits,zeros(1,8 - t_len)];
                 end 
                 fwrite(fot,demo_bits,'ubit1');
             else
                 datatype = 1; %%% EDR
                 fwrite(fot,prefix,'uint8');
        	     fwrite(fot,otfrq,'uint8','l');
        	     fwrite(fot,round(snr_eng),'uint8','l');
        	     fwrite(fot,bgp + burst_bg -1,'int32','l');
        	     fwrite(fot,datatype,'uint8');
                 fwrite(fot,length(demo_bits),'int16','l');
                 t_len = mod(length(demo_bits) , 8);
                 if t_len > 0
                    demo_bits = [demo_bits,zeros(1,8 - t_len)];
                 end
                 fwrite(fot,demo_bits,'ubit1');
             end
        else
            datatype = 0; %%% BR
            fwrite(fot,prefix,'uint8');
            fwrite(fot,otfrq,'uint8','l');
       	    fwrite(fot,round(snr_eng),'uint8','l');
       	    fwrite(fot,bgp + burst_bg -1,'int32','l');
       	    fwrite(fot,datatype,'uint8');
            fwrite(fot,length(demo_out),'int16','l');
            t_len = mod(length(demo_out) , 8);
            if t_len > 0
                demo_out = [demo_out,zeros(1,8 - t_len)];
            end
            fwrite(fot,demo_out,'ubit1');
        end
    end
end
fclose('all');
    
%%
   
