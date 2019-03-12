clear all;
clc;
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
fid = fopen('2.pcm','r','b');

bursts_info = load('burst_info.txt');
bursts_info = bursts_info(bursts_info(:,1) >= 73 | bursts_info(:,1) <= 22 ,:);
bursts_info = bursts_info(bursts_info(:,end) > 400000,:);
bursts_info = sortrows(bursts_info,2);

    bgp =215055;frq = 20e6;
    siglen = 125000*5;
    fseek(fid,bgp*2,'bof');
    sig = fread(fid,siglen,'int16','l')'; 
    fclose(fid);
    bd = func_ddc(sig,frq,fs,flt);
    sig = bd(length(flt):end);
    %%
    smooth_len = 4000;
    [burst_bg,burstlen] = searchburstinfo(sig,smooth_len);
    [head_bits,burst_acu_pos] = demo_edr_head(sig,burst_bg,symlen);
    %%
    burst_ed = burst_bg + burstlen-1;
    payload_sig = sig(burst_acu_pos + 126*symlen : burst_ed);
    best_smp = search_best_samp_point(payload_sig,symlen);
    payload_sym = payload_sig(best_smp:symlen:end);
    ef = freq_err_est(payload_sym,symrate);
    symot = freq_err_corrct(payload_sym,ef,symrate);
    plot(symot,'*');
    %%
    dif_payload_sym = payload_sym(2:end).*conj(payload_sym(1:end-1));
    plot(angle(dif_payload_sym)/pi,'*');
    %%
    difsig = symot(2:end).*conj(symot(1:end-1));
    plot(angle(difsig),'*');
    %%
    difsig = sig(symlen+1:end).*conj(sig(1:end-symlen));
    im_difsig = imag(difsig);
    plot(imag(difsig))
    %%
    acsymnum = 72;
    bgp = 30821;
    acsym = im_difsig(bgp:symlen:bgp + (acsymnum-1)*symlen);
    plot(acsym,'*');
    %%
    best_smp = search_best_samp_point(sig,symlen);
    syms = sig(best_smp:symlen:end);
    difsyms = syms(2:end).*conj(syms(1:end-1));
    plot(imag(difsyms),'*');
    %%
    plot(syms,'*');
    %%
    mo_sig = abs(sig);
    smslen = 4000;
    sms_flt = ones(1,smslen);
    mo_fltot = conv(mo_sig,sms_flt);
    div_mo = mo_fltot(smslen*2-1:end-smslen*2)./mo_fltot(smslen:end-smslen+1-smslen*2);
    [v wz1] = max(div_mo);
    [v wz2] = min(div_mo);
    d_pos = wz1 + length(flt)+2500;
    symnum = round((wz2-wz1)/200);
    difsig = sig(2:end).*conj(sig(1:end-1));
    difsig = sig(201:end).*conj(sig(1:end-200));
    plot(imag(difsig))
    sig_d = [zeros(1,floor(length(flt)/2)),sig];
    difsig = conv(difsig,flt);
    ps_sig = angle(difsig);
    tstsymnum = 20;
    %%
    pp = sig(178:200:end);
    pp = pp(293:2566);
    %tt = pp(1:2:end);
    tt = pp;
    ppp = tt.*tt.*tt.*tt.* tt.*tt.*tt.*tt;
    fftlen = 4096;
    ft = abs(fft(ppp,fftlen));
    ft = fftshift(ft);
    [v,wz] = max(ft);
    ef = (wz-(fftlen/2+1))/fftlen/8*1e6;
    %plot(ft);
    fs = 1e6;
    dfi = 2*pi*ef/fs;
    x = 0:length(pp)-1;
    ff = exp(-1j*dfi*x);
    es = pp.*ff;
    plot(es,'*');
    %%
    plot(pp(1:2:end),'*');
    %%
    plot(abs(pp));
    %%
    tstpos = d_pos + tstsymnum*200;
    stssig = ps_sig(tstpos:tstpos + tstsymnum*200-1);
    stssig = reshape(stssig,200,[])';
    [v,vsps] = max(sum(abs(stssig)));
    sm_phase = mod(tstpos+vsps-1,200);
    if sm_phase ==0
        sm_phase = 200;
    end
    ss_sig_d= sig_d(sm_phase:200:end);
    ss_sig_ps = ps_sig(sm_phase:200:end);
    threshold_v = max(abs(ss_sig_d))/3;
    bbgp = 1;
    smnum = 0;
    state = 0;
    for k = 1:length(ss_sig_d)
        if state == 0
            if abs(ss_sig_d(k)) > threshold_v
                state = 1;
                bbgp = k;
                smnum = 1;
            end
        else
            if abs(ss_sig_d(k)) > threshold_v
                smnum = smnum+1;
            else
                state = 0;
                break;
            end
        end
    end
    demosig = ss_sig_ps(bbgp:bbgp+smnum-1);
    demosym = demosig<0;
    plot(demosig,'*');
%%
fot = fopen('demosig.dat','w','b');
hopinfo = load('hopinfo.txt');
load('flt.mat');
hopnums = size(hopinfo,1);
siglen = 125000;
fs = 200e6;
for i = 1:hopnums
    info = hopinfo(i,:);
    bgp = info(1);frq = info(2);
    dfi = frq/fs*2*pi;
    x = 1:siglen;
    ff = exp(-1j*x*dfi);
    fseek(fid,bgp*2,'bof');
    sig = fread(fid,siglen,'int16','l')'; 
    sig = sig.*ff;
    sig = conv(sig,flt);
    mo_sig = abs(sig);
    smslen = 4000;
    sms_flt = ones(1,smslen);
    mo_fltot = conv(mo_sig,sms_flt);
    div_mo = mo_fltot(smslen*2-1:end-smslen*2)./mo_fltot(smslen:end-smslen+1-smslen*2);
    [v wz1] = max(div_mo);
    [v wz2] = min(div_mo);
    d_pos = wz1 + length(flt)+2500;
    symnum = round((wz2-wz1)/200);
    difsig = sig(2:end).*conj(sig(1:end-1));
    sig_d = [zeros(1,floor(length(flt)/2)),sig];
    difsig = conv(difsig,flt);
    ps_sig = angle(difsig);
    tstsymnum = 20;
    tstpos = d_pos + tstsymnum*200;
    stssig = ps_sig(tstpos:tstpos + tstsymnum*200-1);
    stssig = reshape(stssig,200,[])';
    [v,vsps] = max(sum(abs(stssig)));
    sm_phase = mod(tstpos+vsps-1,200);
    if sm_phase ==0
        sm_phase = 200;
    end
    ss_sig_d= sig_d(sm_phase:200:end);
    ss_sig_ps = ps_sig(sm_phase:200:end);
    threshold_v = max(abs(ss_sig_d))/3;
    bbgp = 1;
    smnum = 0;
    state = 0;
    for k = 1:length(ss_sig_d)
        if state == 0
            if abs(ss_sig_d(k)) > threshold_v
                state = 1;
                bbgp = k;
                smnum = 1;
            end
        else
            if abs(ss_sig_d(k)) > threshold_v
                smnum = smnum+1;
            else
                state = 0;
                break;
            end
        end
    end
    demosig = ss_sig_ps(bbgp:bbgp+smnum-1);
    demosym = demosig<0;
    plot(demosig,'*');
    freq = frq/1e6-10+2400;
    fwrite(fot,freq,'int16','l');
    fwrite(fot,smnum,'int16','l');
    fwrite(fot,demosym,'char');
    %demosym(1:40)
    %demosym;
  %  plot(ps_sig);
  %  syms = ps_sig(d_pos:200:d_pos + symnum*200-1);
%     plot(syms(1:100),'*');
%     plot(ps_sig);
%     plot(div_mo);
%     plot(real(sig));
    
end
fclose('all');
%%
