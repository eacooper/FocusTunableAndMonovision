clear all; close all;

% plotting set up
addpath(genpath('./helper_functions'));
set(0,'defaultfigurecolor',[1 1 1]);
set(0,'defaultfigurewindowstyle','docked');

% load data
load('performance_data.mat');

% The columns are as follows:
% (1) Correct? | (2) response time (s) | (3) T1 (viewing) distance | (4) T2 (target) relative distance | (5) sample number | (6) userID

exp_types = {'clarity','depth'};     % experiment types, clarity and depth

% list with name of each condition
conds = {'normal','normal_dof','focus','focus_dof','mono'};
labels = {'Normal','Adaptive DOF','Adaptive Focus','Adaptive Focus + DOF','Monovision'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for each experiment type, run this analysis
for exp = exp_types
    
    % select correct data structure
    switch exp{:}
        case 'clarity'
            data = data_clarity;
            
        case 'depth'
            data = data_depth;
    end
    
    subjects = unique(data.normal(:,6));        % subject ID numbers
    
    % for each observer and for all observer average...
    for s = 1:length(subjects)
        
        t1s     = unique(data.normal(:,3));     % how many target 1 distances were measured? we will plot each separately
        t2s     = unique(data.normal(:,4));     % what are the unique t2 distances?
        
        % for each t1 (viewing) distance
        for x1 = 1:length(t1s)
            
            % for each condition
            for c = 1:length(conds);
                
                subj_inds = data.(conds{c})(:,6) == subjects(s); % grab indices for this subject
                
                % for each t2 (target) distance, get average results for RT and accuracy
                for x2 = 1:length(t2s)
                    
                    % trials that contain this t1/t2 combo
                    trial_inds = data.(conds{c})(:,3) == t1s(x1) & data.(conds{c})(:,4) == t2s(x2);
                    
                    % median reaction time data
                    res.rt(s,c,x1,x2)      = median(data.(conds{c})(trial_inds & subj_inds,2));
                    res.rt_diff(s,c,x1,x2) = res.rt(s,1,x1,x2) - res.rt(s,c,x1,x2);             % versus normal
                    
                    % percent correct
                    res.pc(s,c,x1,x2)      = sum(data.(conds{c})(trial_inds & subj_inds,1))/sum(trial_inds & subj_inds);
                    res.pc_diff(s,c,x1,x2) = res.pc(s,c,x1,x2) - res.pc(s,1,x1,x2);             % versus normal
                    
                end
                
                % compute between subjects mean for each display mode / t1 distance combo, averaged over t2s 2:5 so the
                % bar plot matches the anova data
                bars.rt(s,c,x1) = mean(res.rt(s,c,x1,2:5));
                bars.pc(s,c,x1) = mean(res.pc(s,c,x1,2:5));
                
            end
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compute averages and ST error across subjects for bar plot
    for c = 1:length(conds)
        
        for x1 = 1:length(t1s)
            
            % bar heights - mean across subjects
            bardataRT(c,x1) = 1000*squeeze(mean(bars.rt(:,c,x1)));
            bardataPC(c,x1) = squeeze(mean(bars.pc(:,c,x1)));
            
            % standard error
            barerrRT(c,x1) = 1000*squeeze(std(bars.rt(:,c,x1)))/sqrt(length(subjects));
            barerrPC(c,x1) = squeeze(std(bars.pc(:,c,x1)))/sqrt(length(subjects));
            
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % make bar plot to visualize anova results
    figure(1); hold on;
    switch exp{:}
        case 'clarity'
            subplot(2,2,1); hold on; title('Visual Clarity RTs');
        case 'depth'
            subplot(2,2,3); hold on; title('Depth Judgment RTs');
    end
    
    [bar_xtick,hb,he] = errorbar_groups(bardataRT,barerrRT);
    for c = 1:5
        set(hb(c),'FaceColor',ColorIt(c))
    end
    
    ylim([700 1350]);
    
    switch exp{:}
        case 'clarity'
            subplot(2,2,2); hold on; title('Visual Clarity PCs');
        case 'depth'
            subplot(2,2,4); hold on; title('Depth Judgment PCs');
    end
    
    [bar_xtick,hb,he] = errorbar_groups(bardataPC,barerrPC);
    for c = 1:5
        set(hb(c),'FaceColor',ColorIt(c))
    end
    
    ylim([0.35 1]);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compute average results for each individual target across all
    % subjects for line plots
    res.rt_mean = squeeze(mean(res.rt,1));
    res.rt_se = squeeze(std(res.rt,[],1))/sqrt(length(subjects));
    
    res.rt_diff_mean = squeeze(mean(res.rt_diff,1));
    res.rt_diff_se = squeeze(std(res.rt_diff,[],1))/sqrt(length(subjects));
    
    res.pc_mean = squeeze(mean(res.pc,1));
    res.pc_se = squeeze(std(res.pc,[],1))/sqrt(length(subjects));
    
    res.pc_diff_mean = squeeze(mean(res.pc_diff,1));
    res.pc_diff_se = squeeze(std(res.pc_diff,[],1))/sqrt(length(subjects));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % make line plots
    
    % RT data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch exp{:}
        case 'clarity'
            figure(2); hold on;
            suptitle('Visual Clarity RTs');
        case 'depth'
            figure(3); hold on;
            suptitle('Depth Judgment RTs');
    end
    
    % for each viewing distance
    for t = 1:3
        
        subplot(1,3,t); hold on; title(['Fixation Distance of ' num2str(t1s(t)) ' D']);
        
        % plot each condition
        for c = 1:5
            h(c) = errorbar(t2s, 1000*squeeze(res.rt_mean(c,t,:)),1000*squeeze(res.rt_se(c,t,:)),...
                'marker','o','color',ColorIt(c),'markerfacecolor',ColorIt(c),'markersize',10);
        end
        
        % format plot
        if s == length(subjects)
            switch exp{:}
                case 'clarity'; ylim([700 1650]);
                case 'depth'; ylim([600 1300]);
            end
        end
        
        xlim([-0.6 0.6]); box on;
        set(gca,'XTick',[-0.5 -0.2 0 0.2 0.5]);
        ylabel('Reaction Time (ms)');
        xlabel('Relative Distance of Target (D)');
        pbaspect([1.2 1 1]);
        
        if t == 1;  legend(h,labels); end
        
    end
    
    
    % RT difference data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch exp{:}
        case 'clarity'
            figure(4); hold on;
            suptitle('Visual Clarity RTs versus Normal');
        case 'depth'
            figure(5); hold on;
            suptitle('Depth Judgment RTs versus Normal');
    end
    
    for t = 1:3
        
        subplot(1,3,t); hold on; title(['Fixation Distance of ' num2str(t1s(t)) ' D']);
        
        rectangle('Position',[-0.6,-500,1.2,500],'facecolor',[0.96 0.96 0.96],'edgecolor','none')
        plot([-0.6 0.6],[0 0],'k:');
        for c = 2:5
            h(c) = errorbar(t2s, 1000*squeeze(res.rt_diff_mean(c,t,:)),1000*squeeze(res.rt_diff_se(c,t,:)),...
                'marker','o','color',ColorIt(c),'markerfacecolor',ColorIt(c),'markersize',10);
        end
        
        ylim([-425 750]); xlim([-0.6 0.6]); box on;
        set(gca,'XTick',[-0.5 -0.2 0 0.2 0.5]);
        ylabel('Reaction Time Change (ms)');
        xlabel('Relative Distance of Target (D)');
        pbaspect([1.2 1 1]);
        
        if t == 1;  legend(h(2:end),labels{2:end})
            text(-0.59,50,'\bf \it faster')
            text(-0.59,-50,'\bf \it slower')
        end
        
    end
    
    
    % PC data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch exp{:}
        case 'clarity'
            figure(6); hold on;
            suptitle('Visual Clarity PCs');
        case 'depth'
            figure(7); hold on;
            suptitle('Depth Judgment PCs');
    end
    
    for t = 1:3
        
        subplot(1,3,t); hold on; title(['Fixation Distance of ' num2str(t1s(t)) ' D']);
        
        for c = 1:5
            h(c) = errorbar(t2s, 100*squeeze(res.pc_mean(c,t,:)),100*squeeze(res.pc_se(c,t,:)),...
                'marker','o','color',ColorIt(c),'markerfacecolor',ColorIt(c),'markersize',10);
        end
        
        ylim([0 100]); xlim([-0.6 0.6]); box on;
        set(gca,'XTick',[-0.5 -0.2 0 0.2 0.5]);
        ylabel('Percent Correct');
        xlabel('Relative Distance of Target (D)');
        pbaspect([1.2 1 1]);
        
        if t == 1;  legend(h,labels)
        end
        
    end
    
    
    % PC difference data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch exp{:}
        case 'clarity'
            figure(8); hold on;
            suptitle('Visual Clarity PCs versus Normal');
        case 'depth'
            figure(9); hold on;
            suptitle('Depth Judgment versus Normal');
    end
    
    for t = 1:3
        
        subplot(1,3,t); hold on; title(['Fixation Distance of ' num2str(t1s(t)) ' D']);
        
        rectangle('Position',[-0.6,-500,1.2,500],'facecolor',[0.96 0.96 0.96],'edgecolor','none')
        plot([-0.6 0.6],[0 0],'k:');
        for c = 2:5
            h(c) = errorbar(t2s, 100*squeeze(res.pc_diff_mean(c,t,:)),100*squeeze(res.pc_diff_se(c,t,:)),...
                'marker','o','color',ColorIt(c),'markerfacecolor',ColorIt(c),'markersize',10);
        end
        
        ylim([-38 38]); xlim([-0.6 0.6]); box on;
        set(gca,'XTick',[-0.5 -0.2 0 0.2 0.5]);
        ylabel('Percent Correct Change');
        xlabel('Relative Distance of Target (D)');
        pbaspect([1.2 1 1]);
        
        if t == 1;  legend(h(2:end),labels{2:end})
            text(-0.59,1,'\bf \it better')
            text(-0.59,-1,'\bf \it worse')
        end
        
    end
    
end

