clear;close all; clc;


%load /home/student/spyder_workspace/IQA_in_PC_domain/MLIVE_features.mat  % name of variable is features_all
%load /home/student/spyder_workspace/IQA_in_PC_domain/MLIVE_dmos.mat      % name of variable is  dmos_all

load /home/student/spyder_workspace/IQA_in_PC_domain/MLIVE_features_multiscale_beta.mat  % name of variable is features_all
load /home/student/spyder_workspace/IQA_in_PC_domain/MLIVE_dmos_multiscale_beta.mat      % name of variable is  dmos_all


feats = []
hist_fv = sqrt(features_all);   %%%% feature normalization    
feats = [feats hist_fv];

dmos = dmos_all;
if size(dmos,1) == 1;
        dmos=dmos';
end

trainX =  feats(1:360,:);
trainY = dmos(1:360);

testX =  feats(361:450,:);
testY = dmos(361:450);

min_mse = 100.0
bestc =0.0;bestg=0.0;
for c = 0:1:12
   for g = -10 :1 :5
       cmd =['-v 10 -c ' ,num2str(2^c),' -g ', num2str(2^g) , ' -s 3 -t 2 -p 1'];
       mse = svmtrain(trainY,trainX,cmd);
       mse
       if (mse < min_mse)
          min_mse = mse; bestc = 2^c; bestg = 2^g;
       end
       
   end
   c
end


%%  train --
cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg) , '-s 3 -t 2 -p 1'];
svr_model = svmtrain(trainY,trainX,cmd);



[pred_mos, accuracy, prob_esti] = svmpredict(testY,testX, svr_model);

srcc = IQAPerformance(pred_mos(:),testY(:),'s')

krcc = corr(pred_mos(:),testY(:),'type','Kendall')
plcc = IQAPerformance(pred_mos(:),testY(:),'p')
rmse = IQAPerformance(pred_mos(:),testY(:),'e')

results(1) = srcc; results(2) = krcc;
results(3) = plcc; results(4) = rmse;
min_mse
bestc
bestg