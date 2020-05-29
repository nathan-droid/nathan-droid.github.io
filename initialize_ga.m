function [w scores_ga fitness_mat dely_mat gens] =  initialize_ga(pop)
w = rand(3,6,pop);
gens = 0;
scores_ga = zeros(1,pop);
fitness_mat= zeros(1,pop);
dely_mat = zeros(1,pop);
end