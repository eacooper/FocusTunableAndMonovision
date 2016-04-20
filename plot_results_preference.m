clear all; close all;
addpath(genpath('./helper_functions'));

load('preference_data.mat')

% The columns of the matrix are as follows:
% Mode | Rank | UserID

% Where 0 -> normal, 1 -> normal+dof, 2 -> accomodation,
% 3 -> accomodation+dof, 4 -> monovision

% condition label strings
labels = {'Normal','Adaptive DOF','Adaptive Focus','Adaptive Focus + DOF','Monovision'};

subjects = unique(data(:,3));        % subject ID numbers

% for each user
for s = 1:length(subjects);
    
    % grab indices, for a single user
    subj_inds = data(:,3) == subjects(s);
    
    % compute mean, std, and sterr of ranks for each condition
    for c = 1:5
        
        mean_ranks(s,c)   = mean(data(data(:,1) == c-1 & subj_inds,2));
        std_ranks(s,c)    = std(data(data(:,1) == c-1 & subj_inds,2));
        sterr_ranks(s,c)  = std_ranks(c)./sqrt(numel(data(data(:,1) == c-1 & subj_inds,2))); %std/sqrt(number of measurements)
        
    end
    
end

% perform a friedman test on the mean ranks - user (row) is modeled as a
% nuisance factor, display mode (column) is the factor of interest
[p,table,stats] = friedman(mean_ranks,1);
display(['P value for Friedman test: ' num2str(p)]);

% determine which contrasts are significant
comp = multcompare(stats);

% individual subject plots and average plot
for s = 1:length(subjects)+1
    
    % chose correct figure panel
    if s <= length(subjects)
        figure(4); hold on;
        subplot(3,4,s); hold on;
    else
        figure(5); hold on;
    end
    
    % plot bars with mean and sterr
    for c = 1:5
        
        if s <= length(subjects)
            %individual subject plot panel
            bar(c,5 - mean_ranks(s,c),'facecolor',ColorIt(c));
            errorbar(c,5 - mean_ranks(s,c),sterr_ranks(s,c),'color',ColorIt(c));
        else
            % mean and stderr overall all subjects
            bar(c,5 - mean(mean_ranks(:,c)),'facecolor',ColorIt(c));
            errorbar(c,5 - mean(mean_ranks(:,c)),std(mean_ranks(:,c))./sqrt(length(subjects)),'color',ColorIt(c));
            x = unique(mean_ranks(:,c));
            for y = 1:length(x)
                for t = 1:sum(mean_ranks(:,c) == x(y))
                plot(c+(0.075*(t - ((1+sum(mean_ranks(:,c) == x(y)))/2))),5 - x(y),'o','color','k','markerfacecolor',ColorIt(c),'markersize',6);
                end
            end
        end
        
    end
    
    set(gca,'Xtick',[1:5],'Xticklabel',labels);
    set(findall(gcf,'-property','FontSize'),'FontSize',10)
    xlabel('Condition');
    set(gca,'labelfontsize',1.2);
    ylabel('Mean Ranking');
    ylim([0 4]);
    box on;
    set(gca,'YTick',0:4,'YTicklabel',5:-1:1);
    
end


