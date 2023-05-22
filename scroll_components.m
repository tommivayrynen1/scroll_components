
function f = scroll_components(data,varargin)

% INPUTS:
% DATA.trial{1} (chan x time)
%.fsample
%.invW
%.chanlocs
% OPTIONAL : ylimits - Default (min max) for each channel separately.

% Spectrum is calculated using m_3dPeriodogram. 10 Factor downsampling is
% used to decrease computational load for fast sampled input signal.

    addpath(genpath('eeglab14_1_2b'))
  
    ognargin = nargin;
    raw = data.trial{1};
    srate = data.fsample;
    invW = data.invW; 
    chanlocs = data.chanlocs;
    
    draw = downsample(raw',10)'; % Just quick way to calculate, ALIASING may occur.
    [pr,fr] = m_3dPeriodogram(draw,0.95,length(draw),srate/10);
    t = [1:length(raw)]./srate;

    switch ognargin
        case 1
            lims(:,1) = min(raw') % separate limits for each channel.
            lims(:,2) = max(raw')
        case 2
            lims(:,1) = repmat(varargin{1}(1),[size(raw,1),1]);
            lims(:,2) = repmat(varargin{1}(2),[size(raw,1),1]);
        case 3
            lims(:,1) = repmat(varargin{1}(1),[size(raw,1),1]);
            lims(:,2) = repmat(varargin{1}(2),[size(raw,1),1]);
    end

    f = figure('Position',[320         638        2047        1063]);    
    % Create panels
    ax=axes(f,'position',[0.1300,0.1100,0.7750,0.5])
    topo=axes(f,'position',[.55 .67 .35 .25]);box on 
    powerax=axes(f,'position',[.13 .67 .35 .25]);box on 
    
    % replace zoomed iwht topo
    set(f,'CurrentAxes',ax)
    p = uipanel(f,'Position',[0 0 1 0.035]);
    c = uicontrol(p,'Style','slider');    
    c.Position = [500 10 1000 15]
    c.Min = 0;c.Max = 1;
    
    if size(raw,1)==1
        c.SliderStep = [1 1];
    else
        c.SliderStep = [1/(size(raw,1)-1) 1/(size(raw,1)-1)];
    end
    set(c,'Callback',@SliderChangeFunction);

    %% Initial plot
    plot(ax,t,raw(1,:),'Color','k');ylim(ax,lims(1,:));xlim(ax,[0 t(end)]);xlabel(ax,'Time /s')
    set(f,'CurrentAxes',topo)
    topoplot(invW(:,1),chanlocs,'electrodes','on','conv','on','numcontour',0,'shading','interp','maplimits',[-50 50]);colorbar
    hand=get(topo,'Children');
    hand(6).FaceColor=[1 1 1];
    p3 = plot(powerax,fr,pr(:,1),'Color','k');ylim(powerax,[0 1]);xlim(powerax,[0 (srate/10)/2]);xlabel(powerax,'Frequency / Hz');ylabel(powerax,'Power a.u.')%;ylim(zoomed,get(zoomed,'YLim'));xlim(zoomed,[1 round(size(raw,2)/50)])
    a=annotation('textbox',[.92 .65 .3 .3],'String',sprintf('Component: %i / %i',1,size(raw,1)),'FitBoxToText','on');

    %% UPDATE
    function SliderChangeFunction(hObject,eventdata)
        delete(a)
        slidervalues = linspace(0,1,size(raw,1));
        [~,ind2plot]=min(abs((hObject.Value - slidervalues)));
        a=annotation('textbox',[.92 .65 .3 .3],'String',sprintf('Component: %i / %i',ind2plot,size(raw,1)),'FitBoxToText','on');
        cla

        plot(ax,t,raw(ind2plot,:),'Color','k');ylim(ax,lims(ind2plot,:));xlim(ax,[0 t(end)]);xlim(ax,[0 t(end)]);xlabel(ax,'Time /s')
        set(f,'CurrentAxes',topo)
        topoplot(invW(:,ind2plot),chanlocs,'electrodes','on','conv','on','numcontour',0,'shading','interp');colorbar
        hand=get(topo,'Children');
        hand(6).FaceColor=[1 1 1];
        p3 = plot(powerax,fr,pr(:,ind2plot),'Color','k');ylim(powerax,[0 1]);xlim(powerax,[0 (srate/10)/2]);xlabel(powerax,'Frequency / Hz');ylabel(powerax,'Power a.u.')%;ylim(zoomed,get(zoomed,'YLim'));xlim(zoomed,[1 round(size(raw,2)/50)])
    end


end
