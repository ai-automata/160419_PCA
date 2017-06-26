% Copyright 2017 AI-Automata. All rights reserved.
% 
% This software is being made available for individual research use only.
% Any commercial use or redistribution of this software shall contact
% Jian-Feng Shi (jianfeng.shi@ai-automata.ca)
% 
% You may use this work subject to the following conditions:
% 
% 1. This work is provided "as is" by the copyright holder, with
% absolutely no warranties of correctness, fitness, intellectual property
% ownership, or anything else whatsoever.  You use the work
% entirely at your own risk.  The copyright holder will not be liable for
% any legal damages whatsoever connected with the use of this work.
% 
% 2. The copyright holder retain all copyright to the work. All copies of
% the work and all works derived from it must contain (1) this copyright
% notice, and (2) additional notices describing the content, dates and
% copyright holder of modifications or additions made to the work, if
% any, including distribution and use conditions and intellectual property
% claims.  Derived works must be clearly distinguished from the original
% work, both by name and by the prominent inclusion of explicit
% descriptions of overlaps and differences.
% 
% 3. The names and trademarks of the copyright holder may not be used in
% advertising or publicity related to this work without specific prior
% written permission. 
% 
% 4. In return for the free use of this work, you are requested, but not
% legally required, to do the following:
% 
% - If you become aware of factors that may significantly affect other
%   users of the work, for example major bugs or
%   deficiencies or possible intellectual property issues, you are
%   requested to report them to the copyright holder, if possible
%   including redistributable fixes or workarounds.
% 
% - If you use the work in scientific research or as part of a larger
%   software system, you are requested to cite the use in any related
%   publications or technical documentation. The work is based upon:
% 
%     Shi, J.F., Ulrich, S., and Ruel, S., (2017)
%     "Spacecraft Pose Estimation using Principal Component Analysis 
%      and a Monocular Camera".
%     AIAA Guidance, Navigation, and Controls Conference and Exhibit, 
%     Proceedings of the, Grapevine, Texas, January 9-13.
%     
%  
% This copyright notice must be retained with all copies of the software,
% including any modified or derived versions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage:
% IRCM -(RxCxM)-R-row pixel,C-col pixel,M-images
% pp   -(1  x1)-[2]-pNorm power
% mN1  -(N  x1)-training image bin mean
% GK1M -(K1xM)-training image bin eigenspace manifold [GKM;label_id]
% PKN  -(KxN )-eigen vector vectrix PNK=[e1 ... eK];PKN=PNK';
% kMtch-(1x1 )-found closest image ID index from GK1M set
% gtK1 -(Kx1 )-manifold from input image
% dGK2M-(K2xM)-[dnrm;gtK*ones(1,M)-GKM;ID]
%             -cntr-original image bin counter
%             -dnrm-norm of the delta displacement
% %stats
% stat.raw.MM     =MM;
% stat.raw.KK     =KK;
% stat.raw.fps    =fps;
% stat.raw.mN1    =mN1;
% stat.raw.PKN    =PKN;
% stat.raw.pp     =pp;
% stat.raw.pitch  =pitch;
% stat.raw.dGK2M  =dGK2M;
% stat.raw.GK1Mnew=GK1Mnew;
% stat.raw.GK1M   =GK1M;
% stat.dat.pose   =pose;
% stat.dltEstTme  =estTme2-estTme1      ;%sec;total pose estimation time
% stat.avgEstTme  =mean(pose(3,:))*1000 ;%ms; average pose estimation time
% stat.dltPose    =abs (pose(2,:)-pitch);%pitch error
% stat.avgdltPose =mean(stat.dltPose)   ;%average pose error       
% stat.maxdltPose =max (stat.dltPose)   ;%max pose error
% %remove outlier from delta pose
% stat.OLAngTol   =angTol;%angTol=45 deg normally
% stat.dltPoseNoOL=[stat.dltPose;stat.dat.pose];%delta pose no outlier
clear;clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run_typ=input('run type [0]-train,1-test:');%0-train,1-test
if isempty(run_typ);run_typ=0;
end%if run_typ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch run_typ
case 0;
  %load data
  load env1_y360.mat IRCM pp MM fps;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %set values
  KK_max=20;%number of principal components
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for KK=1:KK_max
    kTxt=num2str(KK);
    fleOut=['env1_y360_K' kTxt '.mat']
    %--------------------------------
    %training
    trnTme1=cputime;
    [mN1,GK1M,PKN]=L2_img_pca_trn(IRCM,KK,[1:MM],pp);
    trnTme2=cputime;
    dTrnTme_sec=trnTme2-trnTme1%sec training time
    %--------------------------------
    save(fleOut); 
  end%for KK
case 1;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  M_new =101 %number of training data to use
  KK_Max=20;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fle   ='env1_y360';
  flgPst=1 ;%compute post test interpolation and processing
  angTol=45;%deg
  fps   =30;%frames/sec
  %loop over all K
  for KK=1:KK_Max
    %create file name
    kTxt =num2str(KK);
    fleIn=[fle '_K' kTxt '.mat'];
    %compute pose
    [MM,pitch,pose,stat]=L3_img_pca_tst ...
                        (M_new,fle,flgPst,angTol,fps,fleIn);
    %plot data
    plot([1:MM]/fps,pitch,pose(1,:)/fps,pose(2,:),'ro');
    grid on;xlabel('Time (s)');ylabel('Pitch Angle (deg)');
    legend('Truth','PCA','Location','NorthWest');
  end%for KK  
end%switch run_typ
