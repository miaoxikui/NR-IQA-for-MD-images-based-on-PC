clear;close all; clc;


load /home/student/spyder_workspace/IQA_in_PC_domain/MLIVE_features.mat  % name of variable is features_all
load /home/student/spyder_workspace/IQA_in_PC_domain/MLIVE_dmos.mat      % name of variable is  dmos_all

%load /home/student/spyder_workspace/IQA_in_PC_domain/MLIVE_features_multiscale_beta.mat  % name of variable is features_all
%load /home/student/spyder_workspace/IQA_in_PC_domain/MLIVE_dmos_multiscale_beta.mat      % name of variable is  dmos_all


feats = []
hist_fv = sqrt(features_all);   %%%% feature normalization    
feats = [feats hist_fv];
total_num = size(feats,1);

train_cnt = total_num * 0.8

dmos = dmos_all;
if size(dmos,1) == 1;
        dmos=dmos';
end

rand_index = randperm(total_num);


trainX =  feats(1:train_cnt+50,:);
trainY = dmos(1:train_cnt+50);

testX =  feats(train_cnt+1:total_num,:);
testY = dmos(train_cnt+1:total_num);

rand_index_train = rand_index(1:train_cnt)
rand_index_test = rand_index(train_cnt+1:total_num)

trainXX = feats(rand_index_train,:)
trainYY = dmos(rand_index_train);

testXX = feats(rand_index_test,:);
testYY = dmos(rand_index_test);

min_mse = 100.0
bestc =0.0;bestg=0.0;
for c = 600:10:700
   for g =10 :0.5 :20
       cmd =['-v 10 -c ' ,num2str(c),' -g ', num2str(g) , ' -s 3 -t 2 -p 0.1'];
       mse = svmtrain(trainYY,trainXX,cmd);
       if (mse < min_mse)
          min_mse = mse; bestc = c; bestg = g;
       end      
   end
   c
end


%%  train --
cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg) , ' -s 3 -t 2 -p 0.1'];
svr_model = svmtrain(trainYY,trainXX,cmd);



[pred_mos, accuracy, prob_esti] = svmpredict(testYY,testXX, svr_model);

srcc = IQAPerformance(pred_mos(:),testYY(:),'s')

krcc = corr(pred_mos(:),testYY(:),'type','Kendall')
plcc = IQAPerformance(pred_mos(:),testYY(:),'p')
rmse = IQAPerformance(pred_mos(:),testYY(:),'e')

results(1) = srcc; results(2) = krcc;
results(3) = plcc; results(4) = rmse;
min_mse
bestc
bestg

resultOnMLIVE = [pred_mos(:), testYY(:)];
save('resultOnMLIVE.mat','resultOnMLIVE')


