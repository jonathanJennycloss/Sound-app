classdef Sound_App_code < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        UIAxes                        matlab.ui.control.UIAxes
        RecordButton                  matlab.ui.control.Button
        PlotButton                    matlab.ui.control.Button
        ListencurrentButtonGroup      matlab.ui.container.ButtonGroup
        PauseButton                   matlab.ui.control.ToggleButton
        PlayButton                    matlab.ui.control.ToggleButton
        ResumeButton                  matlab.ui.control.ToggleButton
        RecordingLampLabel            matlab.ui.control.Label
        RecordingLamp                 matlab.ui.control.Lamp
        UIAxes2                       matlab.ui.control.UIAxes
        ListenPreviousButtonGroup     matlab.ui.container.ButtonGroup
        PauseButton_2                 matlab.ui.control.ToggleButton
        PlayButton_2                  matlab.ui.control.ToggleButton
        ResumeButton_2                matlab.ui.control.ToggleButton
        RecordingTimesEditFieldLabel  matlab.ui.control.Label
        RecordingTimesEditField       matlab.ui.control.NumericEditField
        SamplingFrequencyHzEditFieldLabel  matlab.ui.control.Label
        SamplingFrequencyHzEditField  matlab.ui.control.EditField
        FFTCurrentButton              matlab.ui.control.Button
        UIAxes3                       matlab.ui.control.UIAxes
        FFTPreviousButton             matlab.ui.control.Button
    end

    
    properties (Access = public)
        y % Audio data
        old_y % old data
        music % Audioplayer
        old_music % old audio
        Fs = 8192; %Hz
        old_Fs 
        time = 10; % time of recording
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: RecordButton
        function RecordButtonPushed(app, event)
            app.old_y = app.y;
            app.old_music = app.music;
            lamp = app.RecordingLamp;
            lamp.Color = 'red';
            recObj = audiorecorder;
            recordblocking(recObj,app.time);
            app.y = getaudiodata(recObj);
            %delay(time);
            lamp.Color = 'green';
            app.music = audioplayer(app.y, app.Fs);
            app.old_Fs = app.Fs;
        end

        % Button pushed function: PlotButton
        function PlotButtonPushed(app, event)
            plot(app.UIAxes, app.y);
            set(app.UIAxes, 'Color', 'black');
            plot(app.UIAxes2, app.old_y);
            set(app.UIAxes2, 'Color', 'magenta');
        end

        % Selection changed function: ListencurrentButtonGroup
        function ListencurrentButtonGroupSelectionChanged(app, event)
            selectedButton = app.ListencurrentButtonGroup.SelectedObject;
            
            if selectedButton == app.PlayButton
                play(app.music);
            elseif selectedButton == app.PauseButton
                pause(app.music)
            elseif selectedButton == app.ResumeButton
                resume(app.music)
            end
        end

        % Callback function
        function SamplingFrequencyHzSliderValueChanged(app, event)
            %app.SamplingFrequencyHzSlider.Value = 8192;
            app.Fs = app.SamplingFrequencyHzSlider.Value;
            %This has been deleted.
        end

        % Selection changed function: ListenPreviousButtonGroup
        function ListenPreviousButtonGroupSelectionChanged(app, event)
            selectedButton = app.ListenPreviousButtonGroup.SelectedObject;
            
            if selectedButton == app.PlayButton_2
                play(app.old_music);
            elseif selectedButton == app.PauseButton_2
                pause(app.old_music)
            elseif selectedButton == app.ResumeButton_2
                resume(app.old_music)
            end
        end

        % Value changed function: RecordingTimesEditField
        function RecordingTimesEditFieldValueChanged(app, event)
            app.time = app.RecordingTimesEditField.Value;
            
        end

        % Value changed function: SamplingFrequencyHzEditField
        function SamplingFrequencyHzEditFieldValueChanged(app, event)
            app.Fs = str2double(app.SamplingFrequencyHzEditField.Value);
            
        end

        % Button pushed function: FFTCurrentButton
        function FFTCurrentButtonPushed(app, event)
            len = length(app.y);
            df = app.Fs/len;
            freq = -app.Fs/2:df:app.Fs/2-df;
            fft_in = fftshift(fft(app.y))/length(fft(app.y));
            plot(app.UIAxes3, freq, abs(fft_in));
        end

        % Button pushed function: FFTPreviousButton
        function FFTPreviousButtonPushed(app, event)
            len = length(app.old_y);
            df = app.old_Fs/len;
            freq = -app.old_Fs/2:df:app.old_Fs/2-df;
            fft_in = fftshift(fft(app.old_y))/length(fft(app.old_y));
            plot(app.UIAxes3, freq, abs(fft_in));
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Current Recording')
            xlabel(app.UIAxes, 'no.samples')
            ylabel(app.UIAxes, 'Amplitude')
            app.UIAxes.Position = [140 30 284 243];

            % Create RecordButton
            app.RecordButton = uibutton(app.UIFigure, 'push');
            app.RecordButton.ButtonPushedFcn = createCallbackFcn(app, @RecordButtonPushed, true);
            app.RecordButton.BackgroundColor = [1 0 0];
            app.RecordButton.FontWeight = 'bold';
            app.RecordButton.Position = [33 427 100 22];
            app.RecordButton.Text = 'Record';

            % Create PlotButton
            app.PlotButton = uibutton(app.UIFigure, 'push');
            app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);
            app.PlotButton.BackgroundColor = [1 0.4118 0.1608];
            app.PlotButton.FontWeight = 'bold';
            app.PlotButton.Position = [33 41 100 22];
            app.PlotButton.Text = 'Plot';

            % Create ListencurrentButtonGroup
            app.ListencurrentButtonGroup = uibuttongroup(app.UIFigure);
            app.ListencurrentButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ListencurrentButtonGroupSelectionChanged, true);
            app.ListencurrentButtonGroup.Title = 'Listen - current';
            app.ListencurrentButtonGroup.Position = [32 135 100 105];

            % Create PauseButton
            app.PauseButton = uitogglebutton(app.ListencurrentButtonGroup);
            app.PauseButton.Text = 'Pause';
            app.PauseButton.Position = [1 52 100 22];
            app.PauseButton.Value = true;

            % Create PlayButton
            app.PlayButton = uitogglebutton(app.ListencurrentButtonGroup);
            app.PlayButton.Text = 'Play';
            app.PlayButton.Position = [1 31 100 22];

            % Create ResumeButton
            app.ResumeButton = uitogglebutton(app.ListencurrentButtonGroup);
            app.ResumeButton.Text = 'Resume';
            app.ResumeButton.Position = [1 10 100 22];

            % Create RecordingLampLabel
            app.RecordingLampLabel = uilabel(app.UIFigure);
            app.RecordingLampLabel.HorizontalAlignment = 'right';
            app.RecordingLampLabel.Position = [29 384 67 22];
            app.RecordingLampLabel.Text = 'Recording?';

            % Create RecordingLamp
            app.RecordingLamp = uilamp(app.UIFigure);
            app.RecordingLamp.Position = [111 386 18 18];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Previous Recording')
            xlabel(app.UIAxes2, 'no.samples')
            ylabel(app.UIAxes2, 'Amplitude')
            app.UIAxes2.Position = [184 283 327 166];

            % Create ListenPreviousButtonGroup
            app.ListenPreviousButtonGroup = uibuttongroup(app.UIFigure);
            app.ListenPreviousButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ListenPreviousButtonGroupSelectionChanged, true);
            app.ListenPreviousButtonGroup.Title = 'Listen - Previous';
            app.ListenPreviousButtonGroup.Position = [522 323 100 105];

            % Create PauseButton_2
            app.PauseButton_2 = uitogglebutton(app.ListenPreviousButtonGroup);
            app.PauseButton_2.Text = 'Pause';
            app.PauseButton_2.Position = [1 52 100 22];
            app.PauseButton_2.Value = true;

            % Create PlayButton_2
            app.PlayButton_2 = uitogglebutton(app.ListenPreviousButtonGroup);
            app.PlayButton_2.Text = 'Play';
            app.PlayButton_2.Position = [1 31 100 22];

            % Create ResumeButton_2
            app.ResumeButton_2 = uitogglebutton(app.ListenPreviousButtonGroup);
            app.ResumeButton_2.Text = 'Resume';
            app.ResumeButton_2.Position = [1 10 100 22];

            % Create RecordingTimesEditFieldLabel
            app.RecordingTimesEditFieldLabel = uilabel(app.UIFigure);
            app.RecordingTimesEditFieldLabel.HorizontalAlignment = 'right';
            app.RecordingTimesEditFieldLabel.Position = [25 283 107 22];
            app.RecordingTimesEditFieldLabel.Text = 'Recording Time (s)';

            % Create RecordingTimesEditField
            app.RecordingTimesEditField = uieditfield(app.UIFigure, 'numeric');
            app.RecordingTimesEditField.ValueChangedFcn = createCallbackFcn(app, @RecordingTimesEditFieldValueChanged, true);
            app.RecordingTimesEditField.BackgroundColor = [0.0745 0.6235 1];
            app.RecordingTimesEditField.Position = [29 251 100 22];
            app.RecordingTimesEditField.Value = 10;

            % Create SamplingFrequencyHzEditFieldLabel
            app.SamplingFrequencyHzEditFieldLabel = uilabel(app.UIFigure);
            app.SamplingFrequencyHzEditFieldLabel.HorizontalAlignment = 'right';
            app.SamplingFrequencyHzEditFieldLabel.Position = [25 351 142 22];
            app.SamplingFrequencyHzEditFieldLabel.Text = 'Sampling Frequency (Hz)';

            % Create SamplingFrequencyHzEditField
            app.SamplingFrequencyHzEditField = uieditfield(app.UIFigure, 'text');
            app.SamplingFrequencyHzEditField.ValueChangedFcn = createCallbackFcn(app, @SamplingFrequencyHzEditFieldValueChanged, true);
            app.SamplingFrequencyHzEditField.BackgroundColor = [0.0745 0.6235 1];
            app.SamplingFrequencyHzEditField.Position = [29 315 100 22];
            app.SamplingFrequencyHzEditField.Value = '8192';

            % Create FFTCurrentButton
            app.FFTCurrentButton = uibutton(app.UIFigure, 'push');
            app.FFTCurrentButton.ButtonPushedFcn = createCallbackFcn(app, @FFTCurrentButtonPushed, true);
            app.FFTCurrentButton.Position = [33 103 100 22];
            app.FFTCurrentButton.Text = 'FFT - Current';

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.UIFigure);
            title(app.UIAxes3, 'FFT of input audio')
            xlabel(app.UIAxes3, 'Frequency (Hz)')
            ylabel(app.UIAxes3, 'Amplitude')
            app.UIAxes3.Position = [423 30 199 243];

            % Create FFTPreviousButton
            app.FFTPreviousButton = uibutton(app.UIFigure, 'push');
            app.FFTPreviousButton.ButtonPushedFcn = createCallbackFcn(app, @FFTPreviousButtonPushed, true);
            app.FFTPreviousButton.Position = [33 71 100 22];
            app.FFTPreviousButton.Text = 'FFT - Previous';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Sound_App_code

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end