clear all;
clc;
bursts_info = load('反复配对.txt');
bursts_info = sortrows(bursts_info,2);
bursts_flted  = [];
flt_condition = 62500;
for i = 1:79
    ch_ids = bursts_info(:,1);
    ch_i_pss = find(ch_ids == i);
    ch_i_infos = bursts_info(ch_i_pss,:);
    pos_info = ch_i_infos(:,2);
    dif_pos = pos_info(2:end) - pos_info(1:end-1);
    poss = find(dif_pos < flt_condition) + 1;
    ch_i_infos(poss,:) = []; 
    bursts_flted = [bursts_flted ;ch_i_infos];
end

fid = fopen('反复配对_flt_closed.txt','w');
for i = 1:size(bursts_flted,1)
    fprintf(fid,'%10d   %10d   %10d  %10d   %4.2f\r\n',bursts_flted(i,:));  
end
fclose('all');
