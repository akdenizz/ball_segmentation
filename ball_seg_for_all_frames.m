videoFReader = vision.VideoFileReader('ball.avi', ...
    'VideoOutputDataType', 'double');

videoPlayer = resizePlayer;

v = VideoWriter("result.avi");
open(v);

while ~videoFReader.isDone

    videoFrame = videoFReader();
    frame = segmentation_process(videoFrame);
    videoPlayer(frame);
    writeVideo(v, frame);
end

close(v)
release(videoPlayer)
release(videoFReader)


function frame=segmentation_process(videoFrame)

    Ihsv = rgb2hsv(videoFrame);
    hue = Ihsv(:,:,1);
    BW = hue >= 0.1 & hue < 0.15;
    SE = strel('disk', 7);
    BW = imopen(BW,SE);
    mask = bwareaopen(BW,5000);
    props = regionprops('table',mask,'Centroid','MajorAxisLength');

    alphaBlending = vision.AlphaBlender;
    alphaBlending.Operation = 'Highlight selected pixels';

    frame = alphaBlending(videoFrame, mask);

    numObj = length(props.MajorAxisLength);

    str = [num2str(numObj),' object(s) detected'];
    
    frame = insertText(frame,[20 20], str, 'textColor',[1 1 0],...
        'FontSize',18);
    
    frame = insertShape(frame, 'Circle', ...
        [props.Centroid, props.MajorAxisLength/2]) ;
    
end

function [videoPlayer]=resizePlayer
    r = groot;
    scrPos = r.ScreenSize;%  Retrieve the screen size in pixels
    %  Size/position is always a 4-element vector: [x0 y0 dx dy]
    dx = scrPos(3); dy = scrPos(4);
    videoPlayer = vision.VideoPlayer('Position',[dx/8, dy/8, dx*(3/4), dy*(3/4)]);
end