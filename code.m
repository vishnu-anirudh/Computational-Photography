files = dir('F:\Computational Photography\footage\footage\*.PNG');
imgPath = 'F:\Computational Photography\footage\footage\';
imgType = '*.png'; % change based on image type
images  = dir([imgPath imgType]);




% 
 for idx = 1:length(images)
     Seq{idx} = (imread([imgPath images(idx).name])); 
    im1(:,:,idx)=Seq{idx};
% funM = @(block_struct) mean2(block_struct.data);
% funV = @(block_struct) std2(block_struct.data);
% blocMat=[10 10];
% clear img;
% imgM = blockproc(im1, blocMat, funM);
% imgV = blockproc(im1, blocMat, funV);
% meanIm(:,:,idx)=kron(imgM,ones(blocMat));
% varIm(:,:,idx)=kron(imgV,ones(blocMat));
 end
% 
% %Finding scene cut
for i=2:length(images)
    diff(i)=sum(sum((Seq{i}-Seq{i-1})/255));
    sceneCutFrame=find(diff>3500);
end


initial=[1 sceneCutFrame];
final=[sceneCutFrame-1 length(images)];

for seg=1:length(initial)
    meanFram(:,:,seg)=zeros(size(Seq{1}));
    for Fram1=initial(seg):final(seg)

        meanFram(:,:,seg)=meanFram(:,:,seg)+im2double(Seq{Fram1});            
    end
    meanFram(:,:,seg)=meanFram(:,:,seg)/(final(seg)-initial(seg)+1);
end

for seg=1:length(initial)
    %Seq1=CameraShake1(Seq,initial(seg),final(seg));
    for Fram1=initial(seg):final(seg)
        diffMean(Fram1)=mean2(im2double(Seq{Fram1}))-mean2(meanFram(:,:,seg));
        imTemp=im2double(Seq{Fram1})-(diffMean(Fram1));
        Seq{Fram1}=im2uint8(imTemp);
        
        
        smooth_med = medfilt2(Seq{Fram1},[1,7]);
        mask = abs(Seq{Fram1}-imsharpen(smooth_med,'Radius',3))>4;
        mask = uint8(mask);
       frame_mask = mask.*Seq{Fram1};
        enhanced_image = frame_mask+(1-mask).*smooth_med; 
        enhanced_image = imsharpen(enhanced_image);
        enhanced_image = medfilt2(enhanced_image,[1,3]);
        Seq{Fram1}=medfilt2(enhanced_image,[1,3]); 
    end

end

%Blotch Detection
count=0;

[Ir,Ic]=size(Seq{1});
% tic
for seg=1:length(initial)
    for N=initial(seg):final(seg)
        if N~=initial(seg)&&N~=final(seg)
      imTempPrev=(Seq{N-1});
      imTemp=(Seq{N});
      imTempNext=(Seq{N+1});
    for r=1:Ir
        for c=2:Ic-1
            count=count+1;
            clear rankMat
          if c==283&&r==220
          ff='enter';
          end
            rankMat=double([imTempPrev(r,c-1) imTempPrev(r,c) imTempPrev(r,c+1) imTempNext(r,c-1) imTempNext(r,c) imTempNext(r,c+1)]); 
            if (abs(rankMat(1)-rankMat(4))>50 || abs(rankMat(2)-rankMat(5))>50 || abs(rankMat(3)-rankMat(6))>50)
                if abs(rankMat(1)-double(imTemp(r,c)))>40||abs(rankMat(2)-double(imTemp(r,c)))>40||abs(rankMat(3)-double(imTemp(r,c)))>40
                    imTemp(r,c)=(rankMat(1)+rankMat(2)+rankMat(3))/3;
                elseif abs(rankMat(4)-imTemp(r,c))>40||abs(rankMat(5)-imTemp(r,c))>40||abs(rankMat(6)-imTemp(r,c))>40
                    imTemp(r,c)=(rankMat(4)+rankMat(5)+rankMat(6))/3;
                end
%             elseif min(rankMat)-double(imTemp(r,c))>3 %The pixels with alomost the same intensity are not detected
%                 SROD(r,c,N)=min(rankMat)-imTemp(r,c);
%                 imTemp(r,c)=0.95*imTemp(r,c)+0.05*(rankMat(1)+rankMat(4))/2;
%             elseif max(rankMat)-double(imTemp(r,c))<3
%                 SROD(r,c,N)=imTemp(r,c)-max(rankMat);
%                 imTemp(r,c)=0.95*imTemp(r,c)+0.05*(rankMat(3)+rankMat(6))/2;
            else
                SROD(r,c,N)=0; 
                imTemp(r,c)=imTemp(r,c);
            end
            
        end
    end
    imNew(:,:,N)=imTemp;
        end
    end
end
% toc

%2222222 Median Filter - vertical artefact correction 2222222222222
% for medLine=530:580
%   smooth_med = medfilt2(Seq{medLine},[1,7]);
%   mask = abs(Seq{medLine}-imsharpen(smooth_med,'Radius',3,'Amount',1))>4;
%   mask = uint8(mask);
%   frame_mask = mask.*Seq{medLine};
%   enhanced_image = frame_mask+(1-mask).*smooth_med; 
%   enhanced_image = imsharpen(enhanced_image);
%   enhanced_image = medfilt2(enhanced_image,[1,3]);
%   Seq{medLine}=medfilt2(enhanced_image,[1,3]);
% end
%2222222 Median Filter - vertical artefact correction 2222222222222
