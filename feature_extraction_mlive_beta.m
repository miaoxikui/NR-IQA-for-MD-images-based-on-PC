% work directory :/home/student/spyder_workspace/IQA_in_PC_domain
% work directory :/home/student/spyder_workspace/IQA_in_PC_domain
clear;clc;close all;
MLIVE_part1 = '/home/student/spyder_workspace/LIVE/LIVEmultidistortiondatabase/To_Release/Part1/blurjpeg'
MLIVE_part2 = '/home/student/spyder_workspace/LIVE/LIVEmultidistortiondatabase/To_Release/Part2/blurnoise'

MLIVE_part=[];
dmos_all = [];
dmos = [];
image_namelist =[];
features_all = [];
for part =1:1:2
    if (part ==1 )
        MLIVE_part = MLIVE_part1
        load /home/student/spyder_workspace/LIVE/LIVEmultidistortiondatabase/To_Release/Part1/Scores.mat
        load /home/student/spyder_workspace/LIVE/LIVEmultidistortiondatabase/To_Release/Part1/Imagelists.mat
        dmos = DMOSscores;
        image_namelist = distimgs;
    end
    if (part == 2)
        MLIVE_part = MLIVE_part2
        load /home/student/spyder_workspace/LIVE/LIVEmultidistortiondatabase/To_Release/Part2/Scores.mat
        load /home/student/spyder_workspace/LIVE/LIVEmultidistortiondatabase/To_Release/Part2/Imagelists.mat
        dmos = DMOSscores;
        image_namelist = distimgs;
    end
    dmos_all = [dmos_all dmos]


    cnt = 0;
    img_cnt = 225

    % LBP 
    R = 1; P = 8;
    lbp_type = { 'ri' 'u2' 'riu2' };
    y = 3;
    mtype = lbp_type{y};
    MAPPING = getmapping( P, mtype );

    scalenum = 5;
    beta = [0.0448,0.2856,0.3001,0.2363,0.1333]
    features =[]
    for i = 1:img_cnt
        cnt = cnt+1
        img_name = [MLIVE_part '/' image_namelist{i}];
        img_name
        img = imread(img_name);
        img = double(rgb2gray(img));
        feats = [];
        for itr_scale = 1:scalenum
            %%%%%%%%%%%%%%%%%%%%%%%%%
            % Calculate the gradient map
            %%%%%%%%%%%%%%%%%%%%%%%%%
            % dx = [3 0 -3; 10 0 -10;  3  0 -3]/16;
            % dy = [3 10 3; 0  0   0; -3 -10 -3]/16;
            dx = [1 0 -1; 1 0 -1; 1 0 -1]/3;
            dy = dx';
            Ix = conv2(img, dx, 'same');     
            Iy = conv2(img, dy, 'same');    
            gradientMap = sqrt(Ix.^2 + Iy.^2);

            PCmap = phasecong2(img,4,6);
            PCLBPMap = lbp(PCmap,R,P,MAPPING,'x');

            wLBPHist = [];
            weightmap = gradientMap;
            wintesity = weightmap(2:end-1, 2:end-1);
            wintensity = abs(wintesity);
            for k = 1:max(PCLBPMap(:))+1
                idx = find(PCLBPMap == k-1);
                kval = sum(wintensity(idx));
                wLBPHist = [wLBPHist kval];
            end
            wLBPHist = wLBPHist/sum(wLBPHist);
            beta(itr_scale)
            wLBPHist = wLBPHist.^beta(itr_scale)
            feats = [feats wLBPHist];

            img = imresize(img, 0.5);
        end
        features(end+1,:) = feats;  
        feats = [];
    end
    features_all = cat(1,features_all,features)
    image_namelist =[];
end
save('MLIVE_features_multiscale_beta.mat','features_all')
save('MLIVE_dmos_multiscale_beta.mat','dmos_all')




