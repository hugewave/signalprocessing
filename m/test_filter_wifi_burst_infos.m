clear all;
clc;
bursts_info = load('反复配对_flt_closed.txt');
bursts_info = sortrows(bursts_info,2);
bursts_flt_wifi = [];
i = 1;
while i < size(bursts_info,1)
    info = bursts_info(i,:);
    bgp_thr = info(2) + 40000;
    edp_thr = info(3) + 40000;
    rgn = min(25,(size(bursts_info,1) - i ));
    for k = 1:rgn % wifi band is less than 20
        %if bursts_info(i+k,2) < bgp_thr || bursts_info(i+k,3) < edp_thr
        if bursts_info(i+k,2) < bgp_thr
            continue;
        else
            break;
        end
    end
    infos = bursts_info(i:i+k-1,:);
    if k >  2 
        %f_infos = infos(:,1);
        [st_infos,findx] = sortrows(infos,1);
        f_infos = st_infos(:,1);
        %[f_infos,findx] = sort(f_infos);
%         f_dists = pdist(f_infos);
%         Z = squareform(f_dists);
%         Z = sort(Z);
%         Z = Z(1:3,:);
%         Z = sum(Z);
%         [~,poss] = find(Z <=3);
        Z = [ 3 (f_infos(2:end) - f_infos(1:end-1))'];
        p = 1;
        st = 0;
        del_num = 0;
        del_poss = [];
        while p<=k 
            if st == 0
                if Z(p) > 2
                    st = 1;
                    l_bgp = p;
                    p = p +1;
                else
                    p = p +1;
                end
            else %st ==1 
                if Z(p) <= 2
                    p = p + 1;
                else
                    l_edp = p - 1;
                    st = 0;
                    l_len = l_edp - l_bgp + 1;
                    if l_len >=2    
                    if l_len > 4
                        del_poss = [del_poss (findx(l_bgp:l_edp)' + i -1)];
                        %bursts_info(findx(l_bgp:l_edp) + i -1,:) = []; % delete all
                        del_num = del_num + l_len;
                    else
                        %对于个数小数3的粘连，如果最大的值非常突出，比其它的大3倍，就保留，否则，就全舍弃
                        l_engs = st_infos(l_bgp:l_edp,5);
                        ssl_engs = sort(l_engs);
                        [v,wz] = max(l_engs);
                        if (abs(ssl_engs(end)-ssl_engs(end-1)) < 3)
                             %bursts_info(findx(l_bgp:l_edp) + i -1,:) = []; % delete all
                             del_poss = [del_poss (findx(l_bgp:l_edp)' + i -1)];
                             del_num = del_num + l_len;
                        else
                         xx = 1:l_len;
                         xx(wz) = [];  %save the bigest
                         xx = findx(xx)' + l_bgp -1;
                         del_poss = [del_poss (xx + i -1)];
                         %bursts_info(xx + i -1,:) = []; 
                         del_num = del_num + l_len -1;
                        end
                    end
                    end
                end
            end
        end
        
        if st == 1
                    l_edp = p - 1;
                    l_len = l_edp - l_bgp + 1;
                    if l_len > 4
                        %bursts_info(findx(l_bgp:l_edp) + i -1,:) = []; % delete all
                        del_poss = [del_poss (findx(l_bgp:l_edp)' + i -1)];
                        del_num = del_num + l_len;
                    else if l_len >=2
                        %对于个数小数3的粘连，如果最大的值非常突出，比其它的大3倍，就保留，否则，就全舍弃
                        l_engs = st_infos(l_bgp:l_edp,5);
                        ssl_engs = sort(l_engs);
                        [v,wz] = max(l_engs);
                        if (abs(ssl_engs(end)-ssl_engs(end-1)) < 3)
                             %bursts_info(findx(l_bgp:l_edp) + i -1,:) = []; % delete all
                             del_poss = [del_poss (findx(l_bgp:l_edp)' + i -1)];
                             del_num = del_num + l_len;
                        else
                         xx = 1:l_len;
                         xx(wz) = [];  %save the bigest
                         xx = findx(xx)' + l_bgp -1;
                         del_poss = [del_poss (xx + i -1)];
                         %bursts_info(xx + i -1,:) = []; 
                         del_num = del_num + l_len -1;
                        end
                        end
                    end
        end
        bursts_info(del_poss,:) = [];
        if del_num == k      
        else
            i = i + 1;
        end

    else
        if k == 1
            i = i + 1;
        else if k == 2
            if abs(infos(1,1) - infos(2,1)) > 1
               i = i +2;
            else
                 if abs(infos(1,5) - infos(2,5)) > 3
                     if infos(1,5) > infos(2,5) 
                         bursts_info(i+1,:) = [];
                     else
                         bursts_info(i,:) = [];
                     end
                     i = i + 1;
                 else
                      bursts_info((i:i+1),:) = [];
                end
            end
            end
        end
   
  %      bursts_flt_wifi = [bursts_flt_wifi;info];
  %      i = i+1;
    end
end
%bursts_info = bursts_flt_wifi;
miniumlen = 60*200;
bursts_info = bursts_info(bursts_info(:,4) > miniumlen,:);
fid = fopen('反复配对_wifi_flted.txt','w');
for i = 1:size(bursts_info,1)
    fprintf(fid,'%10d   %10d   %10d  %10d   %4.2f\r\n',bursts_info(i,:));  
end
fclose('all');
% bursts_info = sortrows(bursts_info,2);
% 
% bursts_info = bursts_info(bursts_info(:,1) >= 73 | bursts_info(:,1) <= 22 ,:);
% bursts_info = bursts_info(bursts_info(:,end) > 400000,:);
