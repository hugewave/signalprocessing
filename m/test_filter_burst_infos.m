clear all;
clc;
bursts_info = load('burst_info.txt');
bursts_info = sortrows(bursts_info,2);
bursts_flt_wifi = [];
i = 1;
while i < size(bursts_info,1)
    info = bursts_info(i,:);
    bgp_thr = info(2) + 30000;
    edp_thr = info(3) + 30000;
    for k = 1:25 % wifi band is less than 20
        if bursts_info(i+k,2) < bgp_thr || bursts_info(i+k,3) < edp_thr
        %if bursts_info(i+k,2) < bgp_thr
            continue;
        else
            break;
        end
    end
    if k > 6
        dif_infos = [];
        infos = bursts_info(i:i+k-1,:);
        for p = 0:k-1
                     tmpinfos = infos;
                     tmpinfos(p+1,:) = [];
                     distance = min(abs(tmpinfos(:,1) - infos(p+1,1)));
                     if distance >1 
                         dif_infos = [dif_infos;infos(p+1,:)];
                     end
        end
        bursts_flt_wifi = [bursts_flt_wifi;dif_infos];
        i = i + k;
%         infos = bursts_info(i+1:i+k-1,:);
%         infos = sortrows(infos,1);
%         if info(1) - 2 < infos(end,1) && info(1)+ 2 > infos(1,1)
%             distance = min(abs(infos(:,1) - info(1)));
%             if distance >1 
%                  bursts_flt_wifi = [bursts_flt_wifi;info];
%                  i = i + 1;  
%             else
%                  infos = bursts_info(i+1:i+k-1,:);
%                  for p = 1:k-1
%                      tmpinfos = infos;
%                      tmpinfos(p,:) = [];
%                      distance = min(abs(tmpinfos(:,1) - infos(p,1)));
%                      if distance >1 
%                          break;
%                      end
%                  end
%                  i = i + p -1;
%             end
%         else
%             bursts_flt_wifi = [bursts_flt_wifi;info];
%             i = i + 1;  
%         end
    else
        bursts_flt_wifi = [bursts_flt_wifi;info];
        i = i+1;
    end
end
bursts_info = bursts_flt_wifi;
miniumlen = 60*200;
bursts_info = bursts_info(bursts_info(:,4) > miniumlen,:);
fid = fopen('burst_info.txt','w');
for i = 1:size(bursts_info,1)
    fprintf(fid,'%10d   %10d   %10d  %10d   %4.2f\r\n',bursts_info(i,:));  
end
fclose('all');
% bursts_info = sortrows(bursts_info,2);
% 
% bursts_info = bursts_info(bursts_info(:,1) >= 73 | bursts_info(:,1) <= 22 ,:);
% bursts_info = bursts_info(bursts_info(:,end) > 400000,:);
