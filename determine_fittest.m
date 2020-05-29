function fittest = determine_fittest(fitness,n_children,DelYs)
[best_fit fittest] = maxk(fitness,n_children);
if length(unique(best_fit)) ~= length(best_fit) %If there is a tie among the "fittest"
    %find the birds whose fitness equals the minimum
    %fitness
    
    %the number of birds without the minimum fitness is
    %length(unique(best_fit)) - 1;
    %The number of birds you need the secondary fitness
    %calc for is n_children - length(unique(best_fit))
    %+ 1
%     fitness = fitness_mat(gens,:);
    tie_birds = find(fitness == min(fitness));
    tiebreaker_n = n_children - length(unique(best_fit)) + 1;
    [a b] = mink(abs(DelYs(tie_birds)),tiebreaker_n);
    fittest(end-length(b)+1:end) = b;
end
end