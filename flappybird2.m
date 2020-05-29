function [TubeLayer Bird Score Flags SinYPos MainCanvas TubeFirstCData TubeFirstAlpha BeginInfoHdl ScoreInfoHdl ScoreInfoBackHdl ScoreInfoForeHdl GameOverHdl Tubes TubeSpriteHdl ShowFPS CurrentFrameNo collide fall_to_bottom gameover stageStartTime c FPS_lastTime frame_updated] = flappybird2(GAME,Sprites,MainCanvasHdl,BeginInfoHdl,ScoreInfoHdl,ScoreInfoBackHdl,ScoreInfoForeHdl,GameOverHdl,FloorSpriteHdl,x_sep,init_VOffsets,TubeSpriteHdl,ShowFPS,fps_text_handle,var_text_handle,Bird)
% The scroll layer for the tubes
    TubeLayer.Alpha = false([GAME.RESOLUTION.*[1 2] 3]);
    TubeLayer.CData = uint8(zeros([GAME.RESOLUTION.*[1 2] 3]));
    Bird.Angle = 0;
    Score = 0;
    %TubeLayer.Alpha(GAME.FLOOR_TOP_Y:GAME.RESOLUTION(1), :, :) = true;
    Flags.ResetFloorTexture = true;
    SinYPos = 1;
    Flags.PreGame = true;
    % Redraw the background
    MainCanvas = Sprites.Bkg.CData(:,:,:,1);
    TubeFirstCData = TubeLayer.CData(:, 1:GAME.RESOLUTION(2), :);
    TubeFirstAlpha = TubeLayer.Alpha(:, 1:GAME.RESOLUTION(2), :);
    % Plot the first half of TubeLayer
    MainCanvas(TubeFirstAlpha) = ...
        TubeFirstCData (TubeFirstAlpha);        set(MainCanvasHdl, 'CData', MainCanvas);
    set(BeginInfoHdl, 'Visible','on');
    set(ScoreInfoHdl, 'Visible','off');
    set(ScoreInfoBackHdl, 'Visible','off');
    set(ScoreInfoForeHdl, 'Visible','off');
    set(GameOverHdl, 'Visible','off');
    set(FloorSpriteHdl, 'CData',Sprites.Floor.CData);
    Tubes.FrontP = 1;              % 1-3
    Tubes.ScreenX= 205+x_sep*[0:2];
    % Tubes.ScreenX = [300 380 460]-2;
    %     Tubes.VOffset = ceil(rand(1,n_tube)*105);
    
    Tubes.VOffset = init_VOffsets;
%     Tubes.VOffset = tube_mat_z(1:3);
    for i = 1:3
        set(TubeSpriteHdl(i), 'XData', Tubes.ScreenX(i) + [0 26-1]);
    end
    for i = 1:3
        set(TubeSpriteHdl(i),'CData',Sprites.TubGap.CData,...
            'AlphaData',Sprites.TubGap.Alpha);
        set(TubeSpriteHdl(i), 'YData', -(Tubes.VOffset(i)-1));
    end
    if ShowFPS
        set(fps_text_handle, 'Visible', 'on');
        set(var_text_handle, 'Visible', 'on'); % Display a variable
    end
    CurrentFrameNo = double(0);
    collide = false;
    fall_to_bottom = false;
    gameover = false;
    stageStartTime = tic;
    c = stageStartTime;
    FPS_lastTime = toc(stageStartTime);
    frame_updated = false;
end