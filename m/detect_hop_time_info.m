clear all;
clc;
fid = fopen('doublehop_200m_real.pcm','r','b');
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
% p = 13364;
% symnum = 120;
% endp = p + 200*symnum;
% syms = ps_sig(p:200:endp-1);
% plot(syms,'*');
% %%
% bgp = 131749;
% step = 125000;
% siglen = 62500;
% fs = 200e6;
% fftlen = 1024;
% fseek(fid,bgp*2,'bof');
% fid_rslt = fopen('hopinfo.txt','w');
% while feof(fid) ~=1
%    sig = fread(fid,siglen*2,'int16','l')'; 
%    if feof(fid)
%        break;
%    end
%    search_results = freq_domain_sig_search(sig,fs,fftlen);
%    if ~isempty(search_results)
%    search_results = search_results(search_results(:,2)<1e6,:);
%        if ~isempty(search_results)
%             [v,idx] = sort(search_results(:,3),'descend');
%             search_results = search_results(idx,:);
%             num_rslt = size(search_results,1);
%             ot_rslt = round(search_results(1,:));
%             fprintf(fid_rslt,'%10d   %10d    %10d   %10d   \r\n',bgp,ot_rslt(1),ot_rslt(2),ot_rslt(3));
%        end
%    end
%    bgp = bgp + step;
%    fseek(fid,bgp*2,'bof');
% end
% fclose(fid_rslt);
% 
% sig = fread(fid,'int16','l')';
% fclose(fid);
% 
% %[fc,bw,peak_2_avg] = single_hop_est(sig,fs,fftlen);