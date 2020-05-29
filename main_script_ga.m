close all
clc
clear
delete(gcf)


autoplay = false;   %false = human, true = controller/NN;
label = 'xywind'; %label for data folder/files. no special characters
save_data = false;
% % save_data = menu('Save data?','Yes','No');
% save_video = menu('Save video?','Yes','No')-1 == 0;
save_video = false;
fall_animation = false;

if save_data
    foldername = strcat('D:\Drive\Lab docs\Flappybird\FlappyData2\',datestr(now,'yyyy-mm-dd-HH-MM-SS'),'_',label);
    mkdir(foldername)
    
end

%Pre-Game
load('Tube_Data_v8.mat')
tube_ind = 1;

[MainCanvas,Score,Bird,GAME,FlyKeyStatus,Flags,SinYPos,SinY,SinYRange,MainCanvasHdl,BirdSpriteHdl,Sprites,TubeSpriteHdl,FloorSpriteHdl,ScoreInfoForeHdl,ScoreInfoBackHdl,ShowFPS,total_frame_update,SHOWFPS_FRAMES,var_text_handle,CloseReq,fps_text_handle,BeginInfoHdl,ScoreInfoHdl,GameOverHdl,TUBE,FlyKeyValid,FlyKeyNames,MainFigureHdl] = flappybird1();

game_counter = 0;
Best = 0;
score_mat = [];

x_sep = 144;
wind_toggle = 1;
wind_speed = wind_mat(1);
wind_ind = 1;
grav_ind = 1;
GAME.GRAVITY = grav_mat(1);
target_frac = 0.5; %IMPORTANT FOR P CONTROL

%For controller
pop = 1;
if autoplay
    pop = 10;
    elitism = 0.2;
    randbehv= 00;
    m_rate = 0.1;
    m_range = 0.5;
    [w2 scores_ga fitness_mat dely_mat gens] =  initialize_ga(pop);
    w3 = load('D:\Drive\Lab docs\Flappybird\FlappyData2\2020-05-28-14-50-23_constwindspeed_pretrain_ga\constwindspeed_pretrain_ga_gen5_weights.txt');
    w = reshape(w3,[3 6 10]);
end



for p = 1:50
    if autoplay
        gens = gens + 1
    else
        ShowFPS = false;
    end
    
    for j = 1:pop
        if autoplay
            w_j= w(:,:,j);
            w1 = w_j(1:2,:);
            w2 = w_j(3,:)';
        end
        %         w1  = w1_all(:,(j*6-5):(j*6));
        %             w2  = w2_all((j*6-5):(j*6));
        
        i=0;
        save_counter = save_data;
        game_counter = game_counter + 1;
        [TubeLayer Bird Score Flags SinYPos MainCanvas TubeFirstCData TubeFirstAlpha BeginInfoHdl ScoreInfoHdl ScoreInfoBackHdl ScoreInfoForeHdl GameOverHdl Tubes TubeSpriteHdl ShowFPS CurrentFrameNo collide fall_to_bottom gameover stageStartTime c FPS_lastTime frame_updated] = flappybird2(GAME,Sprites,MainCanvasHdl,BeginInfoHdl,ScoreInfoHdl,ScoreInfoBackHdl,ScoreInfoForeHdl,GameOverHdl,FloorSpriteHdl,x_sep,tube_mat_z(tube_ind:tube_ind+3),TubeSpriteHdl,ShowFPS,fps_text_handle,var_text_handle,Bird);
        %Data to record
        dat = zeros(1e6,9);    F=[];    i=0;
        start = false; %start recording data only after the player jumps first time
        tic
        jump_tic = toc;
        tube_col_no = 1;
        
        
        while 1
            [MainCanvas,Score,Bird,stageStartTime,CurrentFrameNo,GAME,FlyKeyStatus,Flags,SinYPos,SinY,SinYRange,Tubes,MainCanvasHdl,fall_to_bottom,BirdSpriteHdl,Sprites,TubeSpriteHdl,gameover,FloorSpriteHdl,ScoreInfoForeHdl,ScoreInfoBackHdl,ShowFPS,total_frame_update,SHOWFPS_FRAMES,var_text_handle,CloseReq,fps_text_handle,FPS_lastTime,BeginInfoHdl,ScoreInfoHdl,GameOverHdl,Best,frame_updated,FlyKeyValid,FlyKeyNames,MainFigureHdl] = flappybird3(MainCanvas,Score,Bird,stageStartTime,CurrentFrameNo,GAME,FlyKeyStatus,Flags,SinYPos,SinY,SinYRange,Tubes,MainCanvasHdl,fall_to_bottom,BirdSpriteHdl,Sprites,TubeSpriteHdl,gameover,FloorSpriteHdl,ScoreInfoForeHdl,ScoreInfoBackHdl,ShowFPS,total_frame_update,SHOWFPS_FRAMES,var_text_handle,CloseReq,fps_text_handle,FPS_lastTime,BeginInfoHdl,ScoreInfoHdl,GameOverHdl,Best,frame_updated,FlyKeyValid,FlyKeyNames,MainFigureHdl,tube_col_no,x_sep,wind_speed);
            if tube_col_no ~= find(Tubes.ScreenX == min(Tubes.ScreenX(Tubes.ScreenX > 0))) %If you passed the current tube
                Score = Score + 1;
                tube_ind = tube_ind + 1;
                Tubes.VOffset(tube_col_no) = tube_mat_z(tube_ind+3);
                if mod(sum(score_mat)+Score,2) == 1
                    wind_ind = wind_ind+1;
                    wind_speed = wind_mat(wind_ind);
                end
                if mod(sum(score_mat)+Score,2) == 0
                    grav_ind = grav_ind+1;
%                     GAME.GRAVITY = 0.1356*0.5;
                    GAME.GRAVITY = grav_mat(grav_ind);
%                     GAME.GRAVITY;
                end
                
            end
            %
%             if FlyKeyStatus
                start = true;
%             end
            
            if start
                next_tube = find(Tubes.ScreenX == min(Tubes.ScreenX(Tubes.ScreenX > 12))); %24 is width of the tube
                tube_col_no = find(Tubes.ScreenX == min(Tubes.ScreenX(Tubes.ScreenX > 0))); %FOR COLLISION PURPOSES
                i=i+1; %frame number
                %Record data
                dat(i,:)=[toc Bird.ScreenPos(2) FlyKeyStatus tube_ind next_tube Tubes.ScreenX(next_tube) Tubes.VOffset(next_tube) wind_speed GAME.GRAVITY];
                Tube_YPos = [128 177] - (Tubes.VOffset(next_tube)-1);
                target=(target_frac*Tube_YPos(1)+(1-target_frac)*Tube_YPos(2));
                DelY = Bird.ScreenPos(2)-target;
                if save_video
                    F= [F getframe(gcf)];
                end
                
                
                if autoplay
                    [FlyKeyStatus fitness_i] = compute_ga(Tubes.ScreenX(next_tube),DelY,w1,w2,Bird,jump_tic);
                    if Flags.PreGame
                        FlyKeyStatus = 1;
                    end
                end
                % i1 = Tubes.ScreenX(next_tube);
                % i2 = dely;
                %                 if Dely > 0
                %                     jump_toc = toc;
                %                     if jump_toc - jump_tic > 0.133 %min time in seconds between jumps.  equals to 7.5 Hz, which is max I could press the button.
                %                         FlyKeyStatus = 1;
                %                         jump_tic = toc;
                %                     end
                %                 end
            end
            %         end
            
            %             if autoplay && Flags.PreGame
            %             end
            if Score == 250
                gameover = true;
            end
            
            if gameover
                
                if save_counter %save data
                    if Score > Best
                        Best = Score;
                    end
                    Fname = strcat(label,'_game',num2str(game_counter),'_score',num2str(Score),'.txt');
                    Sname = strcat(label,'_games_summary.txt');
                    score_mat(game_counter) = Score;
                    save_counter = false;
                    dat(i+1:end,:)=[];
                    dlmwrite(strcat(foldername,'\',Fname),dat);
                    dlmwrite(strcat(foldername,'\',Sname),score_mat);
                    if autoplay
                        scores_ga(gens,j) = Score
                        
                        
                        fitness_mat(gens,j) = fitness_i;
                        dely_mat(gens,j) = DelY;
                    end
                    
                    
                    
                    
                    if mod(game_counter,10) == 0 | game_counter == 1 && Score < 100
                    if save_video
                        disp('saving video  data for current game')
                        Vname = strcat(label,'_game',num2str(game_counter),'_VideoData.avi');
                        writerObj = VideoWriter(strcat(foldername,'\',Vname));
                        writerObj.FrameRate = 65;
                        writerObj.Quality = 40; %
                        open(writerObj);
                        for i=1:length(F)
                            frame = F(i) ;
                            writeVideo(writerObj, frame);
                        end
                        close(writerObj);
                    end
                    end
                end
                if ~fall_animation
                    break
                elseif fall_to_bottom
                    score_report = {sprintf('Score: %d', Score), sprintf('Best: %d', Best),sprintf('Space: Continue'),sprintf('Esc: Close')};
                    set(ScoreInfoHdl, 'Visible','on', 'String', score_report);
                    set(GameOverHdl, 'Visible','on');
                    if FlyKeyStatus
                        FlyKeyStatus = false;
                        break
                    end
                end
            end
            if CloseReq
                break
            end
        end
    end
    
    
    if CloseReq
        delete(gcf)
        break
    end
    %Make next gen here.
    
    if autoplay
        
        disp(strcat('Gen',num2str(gens),' Scores'))
        scores_ga(gens,:)
        
        if save_data
            Sname2 = strcat(label,'_gens_summary.txt');
            dlmwrite(strcat(foldername,'\',Sname2),scores_ga);
            if mod(gens,10) == 0 | gens == 1
                disp('saving weights...')
                w_name = strcat(label,'_gen',num2str(gens),'_weights.txt');
                dlmwrite(strcat(foldername,'\',w_name),w)
            end
        end
        
        
        n_children = pop - round(pop*elitism) - round(pop*randbehv);
        fittest = determine_fittest(fitness_mat(gens,:),n_children,dely_mat(gens,:))
        w_new = breeding_ga(w,pop,elitism,randbehv,m_rate,m_range,fittest,n_children);
        w = w_new;
    end
    %delete
    %     if gens == 1
    %         delete(gcf)
    %         break
    %     end
    
end