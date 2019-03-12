clear all;
clc;
fid = fopen('1.pcm','r','b');
bgp = 220195;
step = 125000*6;
siglen = 62500;
fs = 200e6;
fftlen = 1024;
fseek(fid,bgp*2,'bof');
fid_rslt = fopen('hopinfo.txt','w');
while feof(fid) ~=1
   sig = fread(fid,siglen*2,'int16','l')'; 
   if feof(fid)
       break;
   end
   search_results = freq_domain_sig_search(sig,fs,fftlen);
   if ~isempty(search_results)
   search_results = search_results(search_results(:,2)<1e6,:);
       if ~isempty(search_results)
            [v,idx] = sort(search_results(:,3),'descend');
            search_results = search_results(idx,:);
            num_rslt = size(search_results,1);
            ot_rslt = round(search_results(1,:));
            fprintf(fid_rslt,'%10d   %10d    %10d   %10d   \r\n',bgp,ot_rslt(1),ot_rslt(2),ot_rslt(3));
       end
   end
   bgp = bgp + step;
   fseek(fid,bgp*2,'bof');
end
fclose(fid_rslt);

sig = fread(fid,'int16','l')';
fclose(fid);

%[fc,bw,peak_2_avg] = single_hop_est(sig,fs,fftlen);