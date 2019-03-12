function best_pos = search_best_samp_point(insig,symlen)
%search_best_samp_point searching the best sampling point
%  the point with the max energy is the best sampling point 
siglen = length(insig);
siglen = floor(siglen/symlen)*symlen;
sig = insig(1:siglen);
eng_sig = reshape(abs(sig),symlen,[])';
[~,best_pos] = max(sum(eng_sig));
end

