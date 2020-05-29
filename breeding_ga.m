function w_new = breeding_ga(w_old,pop,elitism, randbehv,m_rate,m_range,fittest,n_children)
% w_pre=w_old(:) %Resize old weights to prepare for crossover 
% w_post = zeros(size(w_pre)); %Prepare array for next gen.
w_new = zeros(size(w_old));
j = 0;

%Make elite birds
for k = 1:round(pop*elitism)
    j = j +1;
    w_new(:,:,j) = w_old(:,:,fittest(k));
end

%Make random birds
% for k = 1:round(pop*randbehv)
%     j = j+1;
%     w_new(:,:,j) = rand(3,6);
% end

%Breed the rest of birds in pop
for k = 1:n_children/2
    p1 = w_old(:,:,fittest(2*k-1));
    p1=p1(:)'; %Reshape to make crossover easier
    p2 = w_old(:,:,fittest(2*k));
    p2=p2(:)';
    crosspoint = round((17-1).*rand(1) + 1); %rand between 1 and 17
    c1 = [p1(1:crosspoint) p2(crosspoint+1:end)]; %children
    c2 = [p2(1:crosspoint) p1(crosspoint+1:end)];
    
    %Mutate
    for m = 1:length(c1)
        if rand() > (1-m_rate)
            c1(m) = c1(m) + m_range*(2*rand()-1);
        end
        if rand() > (1-m_rate)
            c2(m) = c2(m) + m_range*(2*rand()-1);
        end
        
    end
   
    j=j+1;
    w_new(:,:,j) = reshape(c1,[3 6]);
    j=j+1;
    w_new(:,:,j) = reshape(c2,[3 6]);
end


end
