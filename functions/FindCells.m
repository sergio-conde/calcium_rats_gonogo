function n_cells =  FindCells(F,F_shuf,K,reg,str3)
n_cells = [];
for i = 1:size(F_shuf,1)
    tmp_K = squeeze(mean(K(i,:,:),2));
    if F(i) > prctile(F_shuf(i,:),97.5)
        n_cells = [n_cells i];
    end
%     st1 = sprintf('Cell_%d',i);
    if strcmpi(str3,'yes')
        st = sprintf('Cell-%d',i);
        figure
        subplot(1,2,1)
        histogram(F_shuf(i,:),10);
        hold on
        line([F(i) F(i)],ylim)
        title(st);
        subplot(1,2,2)
        tmp = 90*(reg-1);
        plot(0:0.066:5.9,smooth(tmp_K(tmp+1:tmp+90),7),'LineWidth',2)
        
        title(st);
%         saveas(gcf,st1,'png');
%         close all
    end
end