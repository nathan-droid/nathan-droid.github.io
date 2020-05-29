function [MainCanvas,Score,Bird,stageStartTime,CurrentFrameNo,GAME,FlyKeyStatus,Flags,SinYPos,SinY,SinYRange,Tubes,MainCanvasHdl,fall_to_bottom,BirdSpriteHdl,Sprites,TubeSpriteHdl,gameover,FloorSpriteHdl,ScoreInfoForeHdl,ScoreInfoBackHdl,ShowFPS,total_frame_update,SHOWFPS_FRAMES,var_text_handle,CloseReq,fps_text_handle,FPS_lastTime,BeginInfoHdl,ScoreInfoHdl,GameOverHdl,Best,frame_updated,FlyKeyValid,FlyKeyNames,MainFigureHdl] = flappybird3(MainCanvas,Score,Bird,stageStartTime,CurrentFrameNo,GAME,FlyKeyStatus,Flags,SinYPos,SinY,SinYRange,Tubes,MainCanvasHdl,fall_to_bottom,BirdSpriteHdl,Sprites,TubeSpriteHdl,gameover,FloorSpriteHdl,ScoreInfoForeHdl,ScoreInfoBackHdl,ShowFPS,total_frame_update,SHOWFPS_FRAMES,var_text_handle,CloseReq,fps_text_handle,FPS_lastTime,BeginInfoHdl,ScoreInfoHdl,GameOverHdl,Best,frame_updated,FlyKeyValid,FlyKeyNames,MainFigureHdl,tube_col_no,x_sep,wind_speed);
    %% -- Game Logic --
    % Main Game
    set(gcf,'KeyPressFcn', @stl_KeyPressFcn, ...
            'WindowKeyPressFcn', @stl_KeyDown,...
            'WindowKeyReleaseFcn', @stl_KeyUp,...
            'CloseRequestFcn', @stl_CloseReqFcn);
% TUBE.H_SPACE = ones(n_tube,1)*160;

            loops = 0;
            curTime = toc(stageStartTime);
            while (curTime >= ((CurrentFrameNo) * GAME.FRAME_DURATION) && loops < GAME.MAX_FRAME_SKIP)
                
                if FlyKeyStatus  % If left key is pressed
                    if ~gameover
                        Bird.SpeedY = -2.5; % -2.5;  
                        FlyKeyStatus = false;
                        Bird.LastHeight = Bird.ScreenPos(2);
                        if Flags.PreGame
                            Flags.PreGame = false;
                            set(BeginInfoHdl, 'Visible','off');
                            set(ScoreInfoBackHdl, 'Visible','on');
                            set(ScoreInfoForeHdl, 'Visible','on');
                            Bird.ScrollX = 0;
                        end
                    else
                        if Bird.SpeedY < 0
                            Bird.SpeedY = 0;
                        end
                    end
                end
                if Flags.PreGame
                    processCPUBird;
                else
                    processBird;
                    Bird.ScrollX = Bird.ScrollX + 1;
                    if ~gameover
%                         scrollTubes(1);
                        scrollTubes(wind_speed);
                        
                    end
                end
%                 addScore;
                Bird.CurFrame = 3 - floor(double(mod(CurrentFrameNo, 9))/3);
                collide = isCollide();
                if collide
                    gameover = true;
                end
                CurrentFrameNo = CurrentFrameNo + 1;
                loops = loops + 1;
                frame_updated = true;
                
                % If the bird has fallen to the ground
                if Bird.ScreenPos(2) >= 200-5;
                    Bird.ScreenPos(2) = 200-5;
                    gameover = true;
                    if abs(Bird.Angle - pi/2) < 1e-3
                        fall_to_bottom = true;
                        FlyKeyStatus = false;
                    end
                end
                
            end
            %% Redraw the frame if the world has been processed
            if frame_updated
                %         drawToMainCanvas();
                set(MainCanvasHdl, 'CData', MainCanvas(1:200,:,:));
                %         Bird.Angle = double(mod(CurrentFrameNo,360))*pi/180;
                if fall_to_bottom
                    Bird.CurFrame = 2;
                end
                refreshBird();
                refreshTubes();
                if (~gameover)
                    refreshFloor(CurrentFrameNo);
                end
                curScoreString = sprintf('%d',(Score));
                set(ScoreInfoForeHdl, 'String', curScoreString);
                set(ScoreInfoBackHdl, 'String', curScoreString);
                drawnow;
                frame_updated = false;
                c = toc(stageStartTime);
                if ShowFPS
                    total_frame_update = total_frame_update + 1;
                    varname = 'collide';%'Mario.curFrame';
                    if mod(total_frame_update,SHOWFPS_FRAMES) == 0 % If time to update fps
%                         set(fps_text_handle, 'String',sprintf('FPS: %.2f',SHOWFPS_FRAMES./(c-FPS_lastTime)));
                        set(fps_text_handle, 'String',sprintf('WindSpeedX: %.4f',wind_speed));

                        FPS_lastTime = toc(stageStartTime);
                    end
                    set(var_text_handle, 'String', sprintf('WindSpeedY = %.4f', 0.1356-GAME.GRAVITY));
                end
            end
            if fall_to_bottom

%                 score_report = {sprintf('Score: %d', Score)};
%                 set(ScoreInfoHdl, 'Visible','on', 'String', score_report);
%                 set(GameOverHdl, 'Visible','on');
%                 save sprites2.mat Best -append
                if FlyKeyStatus
%                     FlyKeyStatus = false;
                        return
%                     break; %THIS SHOULD BE RETURN 
                end
            end
            
            if CloseReq
%                 delete(MainFigureHdl);
%                 clear all;
                return;
            end
%         end
%% --- Graphics Section ---
%% Game Logic


    function processBird()
        Bird.ScreenPos(2) = Bird.ScreenPos(2) + Bird.SpeedY;
        Bird.SpeedY = Bird.SpeedY + GAME.GRAVITY;
        if Bird.SpeedY < 0
            Bird.Angle = max(Bird.Angle - pi/10, -pi/10);
        else
            if Bird.ScreenPos(2) < Bird.LastHeight
                Bird.Angle = -pi/10; %min(Bird.Angle + pi/100, pi/2);
            else
                Bird.Angle = min(Bird.Angle + pi/30, pi/2);
            end
        end
    end
    function processCPUBird() % Process the bird when the game is not started
        Bird.ScreenPos(2) = SinY(SinYPos);
        SinYPos = mod(SinYPos, SinYRange)+1;
    end
    function drawToMainCanvas()
        % Draw the scrolls and sprites to the main canvas
        
        % Redraw the background
        MainCanvas = Sprites.Bkg.CData(:,:,:,InGameParams.CurrentBkg);

        TubeFirstCData = TubeLayer.CData(:, 1:GAME.RESOLUTION(2), :);
        TubeFirstAlpha = TubeLayer.Alpha(:, 1:GAME.RESOLUTION(2), :);
        % Plot the first half of TubeLayer
        MainCanvas(TubeFirstAlpha) = ...
            TubeFirstCData (TubeFirstAlpha);
    end
    function scrollTubes(offset)
        Tubes.ScreenX = Tubes.ScreenX - offset;
        if Tubes.ScreenX(Tubes.FrontP) <=-26
%             x_mean_sep
            Tubes.ScreenX(Tubes.FrontP) = max(Tubes.ScreenX)+x_sep;         
%             Tubes.VOffset(Tubes.FrontP) = 
            redrawTube(Tubes.FrontP);
            Tubes.FrontP = mod((Tubes.FrontP),3)+1; %Switch to drawing the next tube.
            Flags.NextTubeReady = true;
        end
    end
    function refreshTubes()
        % Refreshing Scheme 1: draw the entire tubes but only shows a part
        % of each
        for i = 1:3 %5/12
%             for i = n_tube
            set(TubeSpriteHdl(i), 'XData', Tubes.ScreenX(i) + [0 26-1]);
        end
    end 
    function refreshFloor(frameNo)
        offset = mod(frameNo, 24);
        set(FloorSpriteHdl, 'XData', -offset);
    end
    function redrawTube(i)
        set(TubeSpriteHdl(i), 'YData', -(Tubes.VOffset(i)-1));
        %below added by Dhruva
        set(TubeSpriteHdl(i),'CData',Sprites.TubGap.CData,...
                'AlphaData',Sprites.TubGap.Alpha);
    end
%% --- Math Functions for handling Collision / Rotation etc. ---
    function collide_flag = isCollide()
        collide_flag = 0;
        Tubes.ScreenX(tube_col_no)-5;
        if Bird.ScreenPos(1) >= Tubes.ScreenX(tube_col_no)-5 && ... %ie. if the bird has reached the x-position of the FrontP tube
                Bird.ScreenPos(1) <= Tubes.ScreenX(tube_col_no)+6+25
            
        else
            return; %ie. if the bird has NOT yet reached the x-position of the FrontP tube, return to main game loop
        end
%         Tubes.VOffset(tube_col_no)
%         GapY = GapY - (Tubes.VOffset(Tubes.FrontP)-1);    % The upper and lower bound of the GAP, 0-based
% Gaps(Gap_i,:);
%                 GapY = Gaps(Gap_i,:) - (Tubes.VOffset(tube_col_no)-1);    % The upper and lower bound of the GAP, 0-based
        GapY = [128 177] - (Tubes.VOffset(Tubes.FrontP)-1);    % The upper and lower bound of the GAP, 0-based

        if Bird.ScreenPos(2) < GapY(1) || Bird.ScreenPos(2) > GapY(2)-4 %Make collion on top more strict
%                     if Bird.ScreenPos(2) < GapY(1)+4 || Bird.ScreenPos(2) > GapY(2)-4

            collide_flag = 1;
%             Bird.ScreenPos(2)
%             GapY
        end
        return;
    end   
    function addScore()
%         if Tubes.ScreenX(Tubes.FrontP) < 40 && Flags.NextTubeReady
%                     if  Flags.NextTubeReady
        if Tubes.ScreenX(Tubes.FrontP) < 50 && Flags.NextTubeReady
            Flags.NextTubeReady = false;
            
            Score = Score + 1;
        end
    end
    function refreshBird()
        % move bird to pos [X Y],
        % and rotate the bird surface by X degrees, anticlockwise = +
        cosa = cos(Bird.Angle);
        sina = sin(Bird.Angle);
        xrotgrid = cosa .* Bird.XGRID + sina .* Bird.YGRID;
        yrotgrid = sina .* Bird.XGRID - cosa .* Bird.YGRID;
        xtransgrid = xrotgrid + Bird.ScreenPos(1)-0.5;
        ytransgrid = yrotgrid + Bird.ScreenPos(2)-0.5;
        set(BirdSpriteHdl, 'XData', xtransgrid, ...
            'YData', ytransgrid, ...
            'CData', Sprites.Bird.CDataNan(:,:,:, Bird.CurFrame));
    end
%% -- Display Infos --   
%% -- Callbacks --
   function stl_KeyUp(hObject, eventdata, handles)
        
       key = get(hObject,'CurrentKey');
        % Remark the released keys as valid
        FlyKeyValid = FlyKeyValid | strcmp(key, FlyKeyNames);
    end
    function stl_KeyDown(hObject, eventdata, handles)
        key = get(hObject,'CurrentKey');
        
        % Has to be both 'pressed' and 'valid';
        % Two key presses at the same time will be counted as 1 key press
        down_keys = strcmp(key, FlyKeyNames);
        FlyKeyStatus = any(FlyKeyValid & down_keys);
        FlyKeyValid = FlyKeyValid & (~down_keys);
    end
    function stl_KeyPressFcn(hObject, eventdata, handles)
        curKey = get(hObject, 'CurrentKey');
        switch true
            case strcmp(curKey, 'escape') 
                CloseReq = true;            
        end
    end
    function stl_CloseReqFcn(hObject, eventdata, handles)
        CloseReq = true;
    end
    

end
