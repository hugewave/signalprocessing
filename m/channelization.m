%channelization
function y = channelization(coeff,x)

% number of channels
N=size(coeff,1);

% number of slices
M=ceil(length(x)/N);

% create polyphase input signals
x1=reshape(x,N,M);
x2 = [x(N/2+1:end), zeros(1,N/2)];
x2 = reshape(x2,N,M);

% apply channel filters
coeff = fliplr(coeff);
%x1 = flipud(x1);
%x2 = flipud(x2);
for i=1:N
    x1(i,:) = filter(coeff(i,:),1,x1(i,:));
    x2(i,:) = filter(coeff(i,:),1,x2(i,:));    
end
x2 = [x2(N/2+1:end,:);x2(1:N/2,:)];
% apply dft
x1 = ifft(x1,[],1)*N;
x2 = ifft(x2,[],1)*N;
y = zeros(size(x1,1),size(x1,2)*2);
y(:,1:2:end) = x1;
y(:,2:2:end) = x2;
end
