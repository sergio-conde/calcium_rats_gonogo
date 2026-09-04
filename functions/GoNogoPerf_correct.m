function [go_perf,nogo_perf,go_perf_shuf,nogo_perf_shuf] = GoNogoPerf_correct(class,class_shuf,test,test_shuf)


for i_iter = 1:size(class,1)
    tmp_test = test(i_iter,:);
    ind_go = find(tmp_test==2);
    ind_nogo = find(tmp_test==1);

    for i_time = 1:size(class,2)
        tmp_class = squeeze(class(i_iter,i_time,:));
        go = length(find(tmp_class(ind_go)' - tmp_test(ind_go)==0));
        nogo = length(find(tmp_class(ind_nogo)' - tmp_test(ind_nogo)==0));
        go_perf(i_iter,i_time) = go*100/length(ind_go);
        nogo_perf(i_iter,i_time) = nogo*100/length(ind_nogo);
    end
end

% shuf
for i_shuf = 1:size(class_shuf,4)
    for i_iter = 1:size(class_shuf,1)
        tmp_test = test_shuf(i_iter,:,i_shuf);
        ind_go = find(tmp_test==2);
        ind_nogo = find(tmp_test==1);

        for i_time = 1:size(class_shuf,2)
            tmp_class = squeeze(class_shuf(i_iter,i_time,:));
            go = length(find(tmp_class(ind_go)' - tmp_test(ind_go)==0));
            nogo = length(find(tmp_class(ind_nogo)' - tmp_test(ind_nogo)==0));
            go_perf_shuf(i_iter,i_time,i_shuf) = go*100/length(ind_go);
            nogo_perf_shuf(i_iter,i_time,i_shuf) = nogo*100/length(ind_nogo);
        end
    end
end