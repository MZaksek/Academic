% MECH 6318
% Fall 2021
% Group 11 Final Project

clc;
close all;
clear all;


%% Problem Definition

% Define maximum distance bot can travel. If optimial route exceeds this
% value, code returns error message.
max_distance = 9;

locations = [   % Defines points for each delivery point
    3,3;
    5,7;
    8,6;
    5,11;
    8,8;
    6,9;
    5,13;
    1,12;
    6,11];


n = length(locations);  % Total number of locations


% Automatically create distances matrix, assuming distance between
% each location is a straight line
distances = zeros(n);
for i = 1:n-1
    for j = i+1:n
        
        distances(i, j) = sqrt((locations(i,1)-locations(j,1))^2+(locations(i,2)-locations(j,2))^2);
        
        distances(j, i) = distances(i, j);
        
    end
end


% Alternatively, distance matrix can be constructed manually, if
% distances between each location are provided. Just uncomment section
% below and fill out distances matrix

clear distances;
distances = [
    0,1.1,1.1,1.5,1.4,1.4,1.9,1.4,1.7;
    1.1,0,0.5,0.65,0.5,0.45,1.1,1.8,0.75;
    1.1,0.5,0,1.1,0.35,0.65,1.5,2.2,0.7;
    1.5,0.65,1.1,0,0.85,0.4,0.75,1.8,0.4;
    1.4,0.5,0.35,0.85,0,0.5,1.2,2.1,0.45;
    1.4,0.45,0.65,0.4,0.5,0,0.8,1.8,0.35;
    1.9,1.1,1.5,0.75,1.2,0.8,0,2.2,0.75;
    1.4,1.8,2.2,1.8,2.1,1.8,2.2,0,2.1;
    1.7,0.75,0.7,0.4,0.45,0.35,0.75,2.1,0];


%% Ant Colony Algorithm Parameters

max_iterations = 50;   % Maximum number of iterations

total_ants = 50;    % Total number of ants

Q = 1;  % Constant; affects initial pheromone levels

tau0 = 10*Q/(n*mean(distances(:)));	% Initial pheromone

alpha = 1;    % Relative weight of pheremone

beta = 1; % Relative weight of heuristic (distance) information

rho = 0.05; % Pheremone evaporation rate

eta = 1./distances; % Heuristic information matrix; defines attractiveness
                    % of move based on travel distance

tau = tau0 * ones(n,n);

ant_route = [];

shortest_distance = inf;

                    
%% Ant Colony Optimization Algorithm

% Begin each iteration
for iteration = 1:max_iterations
    
    
    % Move each individual ant
    for k = 1:total_ants
        
        
        % Randomize next point for ant to travel to
        ant_route_temp = randi([1 n]);
        
        
        % Compute each step each individual ant takes
        % Start loop at 2, since starting point is known
        for step = 2:n
            
            
            last_location = ant_route_temp(end);
            
            
            % Numerator of probability function
            P = tau(last_location,:).^alpha .* eta(last_location,:).^beta;
            
            
            % Probability of traveling to space ant is currently on is zero
            P(ant_route_temp) = 0;
            
            
            % Incorporates denominator of probability function
            P = P/sum(P);
            
            
            % Compute, using probability function, the next point to
            % travel to
            j = find(rand <= cumsum(P), 1, 'first');
            
            
            % Concatenate route matrices, for each ant
            ant_route_temp = [ant_route_temp j];
            
            
        end
        
        
        % Concatenate route matrices, for each iteration
        ant_route = [ant_route;ant_route_temp];
        
        
        % Compute distance traveled by each ant
        
        % Make each route round trip, returining to starting position
        route = [ant_route_temp ant_route_temp(1)];
        
        % Initialize route distance to zero for each ant
        route_distance = 0;
        
        for x = 1:n
            
            % Compute total distance traveled for ant from distances matrix
            route_distance = route_distance + distances(route(x),route(x+1));
            
        end
        
        
        % Update best route if computed route is shorter than previous
        % shortest
        
        if route_distance < shortest_distance
            shortest_distance = route_distance;
            shortest_route = route;
        end
        
        
    end
    
    % Update pheremones
    for m = 1:total_ants
        
        ant_route_temp = ant_route(n*(iteration - 1) + m,:);
        
        % Make route round trip, returining to starting position
        ant_route_temp = [ant_route_temp ant_route_temp(1)];
        
        
        % Initialize route distance to zero for each ant
        route_distance = 0;
        
        for x = 1:n
            
            % Compute total distance traveled for ant from distances matrix
            route_distance = route_distance + distances(route(x),route(x+1));
            
        end
        
        
        for q = 1:n
            
            tau(ant_route_temp(q),ant_route_temp(q+1)) = tau(ant_route_temp(q),ant_route_temp(q+1)) + Q/route_distance;
            
        end
        
    end
    
    
    % Pheremone evaporation
    tau = (1-rho)*tau;
    
    
    % Store shortest distances in matrix
    shortest_distance_matrix(iteration) = shortest_distance;
    
end


if shortest_distance > max_distance
    fprintf(2,'Error: Total distance of optimal route exceeds\nthe maximum allowable distance. Try selecting\nfewer locations for this trip\n')
end


%% Plot points with optimal route

optimal_route_points = zeros(n+1,2);

for i = 1:n+1
    optimal_route_points(i,1) = locations(shortest_route(i),1);
    optimal_route_points(i,2) = locations(shortest_route(i),2);
end


figure;
plot(optimal_route_points(:,1),optimal_route_points(:,2),'-o');
title('Plot of Optimal Route');
xlabel('X Axis');
ylabel('Y Axis');



%% Plot shortest distance vs iteration number

figure;
plot(1:max_iterations,shortest_distance_matrix);
title('Plot of Current Optimal Route Distance Per Iteration');
xlabel('Iteration');
ylabel('Shortest Distance (km)');