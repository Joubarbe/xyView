XIncludeFile "xyView_Common.pb"

Module xyView
  UseModule xyView_Common : EnableExplicit

  ;{ MACROS
  
  ;}

  ;{ STRUCTURES / PROTOTYPES
  Structure _screen
    width.i
    height.i
    window.i
    window_title.s
    display_mode.i
    show_debug_bar.b
    debug_bar_sprite.i
    debug_bar_text.s
    *callback_setup.__callback_setup
    *callback_window_events.__callback_window_events
    *callback_input_events.__callback_input_events
    *callback_update.__callback_update
    *callback_render.__callback_render
  EndStructure
  ;}

  ;{ CONSTANTS
  #DEBUG_BAR_FOREGROUND = $898987
  #DEBUG_BAR_BACKGROUND = $D0D0D0
  #DISPLAY_WINDOWED = 0
  #DISPLAY_BORDERLESS = 1
  #DISPLAY_FULLSCREEN = 2
  ;}

  ;{ GLOBALS
  Global view._screen
  ;}

  ;{ DECLARES
  
  ;}

  ;{ PROCEDURES
  ;- PRIVATE
  Procedure CreateDebugBar()
    view\debug_bar_sprite = CreateSprite(#PB_Any, view\width, view\height)
    StartDrawing(SpriteOutput(view\debug_bar_sprite))
    Box(0, 0, OutputWidth(), 20, #DEBUG_BAR_BACKGROUND)
    StopDrawing()
  EndProcedure
  
  Procedure UpdateDebugBar()
    Static fps.i, frame_refresh.i
    Define fps$
    
    fps + 1
    If ElapsedMilliseconds() > frame_refresh
      frame_refresh = ElapsedMilliseconds() + 1000
      fps$ = Str(fps) + " FPS"
      fps = 0
    EndIf
    
    StartDrawing(SpriteOutput(view\debug_bar_sprite))
    DrawText(2, 2, view\debug_bar_text, #DEBUG_BAR_FOREGROUND, #DEBUG_BAR_BACKGROUND)
    DrawText(OutputWidth() - TextWidth(fps$) - 2, 2, fps$, #DEBUG_BAR_FOREGROUND, #DEBUG_BAR_BACKGROUND)
    StopDrawing()
  EndProcedure
  
  Procedure MainLoop()
    Define.i event, frame_time, delta_time.f, mouse_released.b
    
    Repeat
      If view\display_mode <> #DISPLAY_FULLSCREEN
        Repeat
          ; Handle window events.
          event = WindowEvent()
          Select event
            Case #PB_Event_ActivateWindow, #PB_Event_LeftClick
              ReleaseMouse(#False) : mouse_released = #False
            Case #PB_Event_DeactivateWindow
              ReleaseMouse(#True) : mouse_released = #True
          EndSelect
          If event
            view\callback_window_events(event)
          EndIf
        Until event = 0
      EndIf
      
      ; Handle input events.
      If mouse_released = #False
        ExamineMouse() : ExamineKeyboard()
        If view\display_mode = #DISPLAY_WINDOWED And KeyboardReleased(#PB_Key_Escape)
          ReleaseMouse(#True) : mouse_released = #True
        EndIf
        view\callback_input_events()
      EndIf
      
      ; Update graphics.
      delta_time = (ElapsedMilliseconds() - frame_time) / 1000
      frame_time = ElapsedMilliseconds()
      view\callback_update(delta_time)
      
      ; Render graphics.
      ClearScreen(0)
      view\callback_render()
      If view\show_debug_bar
        UpdateDebugBar()
        DisplaySprite(view\debug_bar_sprite, 0, 0)
      EndIf
      
      FlipBuffers()
    ForEver
  EndProcedure
  
  Procedure Init(display_mode.i, width.i = 0, height.i = 0, window_title.s = "", show_window_controls.b = #True)
    If InitSprite() = 0 Or InitMouse() = 0 Or InitKeyboard() = 0
      DebuggerError("Initialization failed.") : End
    EndIf
    SetCallbacks(view\callback_setup, view\callback_window_events, view\callback_input_events, view\callback_update, view\callback_render)
    
    If display_mode = #DISPLAY_FULLSCREEN Or (width = 0 And height = 0)
      width = GetMainDesktopWidth()
      height = GetMainDesktopHeight()
    EndIf
    view\display_mode = display_mode
    view\width = width : view\height = height
    view\window_title = window_title
    
    Select display_mode
      Case #DISPLAY_FULLSCREEN
        OpenScreen(width, height, 32, window_title, #PB_Screen_SmartSynchronization)
      Case #DISPLAY_BORDERLESS
        view\window = OpenWindow(#PB_Any, 0, 0, width, height, window_title, #PB_Window_BorderLess | #PB_Window_ScreenCentered)
        OpenWindowedScreen(WindowID(view\window), 0, 0, width, height, #True, 0, 0)
      Case #DISPLAY_WINDOWED
        If show_window_controls
          view\window = OpenWindow(#PB_Any, 0, 0, width, height, window_title, #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_ScreenCentered)
        Else
          view\window = OpenWindow(#PB_Any, 0, 0, width, height, window_title, #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
        EndIf
        OpenWindowedScreen(WindowID(view\window), 0, 0, width, height, #True, 0, 0)
    EndSelect
    
    FlipBuffers() ; Avoids white screen during loading, if any.
    CreateDebugBar()
    view\callback_setup()
    
    MainLoop()
  EndProcedure
  
  Procedure DummySetupCallback() : EndProcedure
  Procedure DummyWindowEventsCallback(event.i) : EndProcedure
  Procedure DummyInputEventsCallback() : EndProcedure
  Procedure DummyUpdateCallback(delta_time.f) : EndProcedure
  Procedure DummyRenderCallback() : EndProcedure
  
  ;- PUBLIC
  Procedure SetCallbacks(*setup.__callback_setup = #PB_Ignore, 
                         *window_events.__callback_window_events = #PB_Ignore, 
                         *input_events.__callback_input_events = #PB_Ignore, 
                         *update.__callback_update = #PB_Ignore, 
                         *render.__callback_render = #PB_Ignore)
    
    If *setup = #PB_Ignore Or *setup = 0 : *setup = @DummySetupCallback() : EndIf
    If *window_events = #PB_Ignore Or *window_events = 0 : *window_events = @DummyWindowEventsCallback() : EndIf
    If *input_events = #PB_Ignore Or *input_events = 0 : *input_events = @DummyInputEventsCallback() : EndIf
    If *update = #PB_Ignore Or *update = 0 : *update = @DummyUpdateCallback() : EndIf
    If *render = #PB_Ignore Or *render = 0 : *render = @DummyRenderCallback() : EndIf
    
    view\callback_setup = *setup
    view\callback_window_events = *window_events
    view\callback_input_events = *input_events
    view\callback_update = *update
    view\callback_render = *render
  EndProcedure
  
  Procedure StartLoopInFullScreen(window_title.s = "")
    Init(#DISPLAY_FULLSCREEN, 0, 0, window_title)
  EndProcedure
  
  Procedure StartLoopInWindowed(width.i, height.i, window_title.s = "", show_window_controls.b = #True)
    Init(#DISPLAY_WINDOWED, width, height, window_title, show_window_controls)
  EndProcedure
  
  Procedure StartLoopInBorderless(width.i, height.i, window_title.s = "")
    Init(#DISPLAY_BORDERLESS, width, height, window_title)
  EndProcedure
  
  Procedure ShowDebugBar()
    view\show_debug_bar = #True
  EndProcedure
  
  Procedure HideDebugBar()
    view\show_debug_bar = #False
  EndProcedure
  
  Procedure SetDebugBarText(text.s)
    view\debug_bar_text = text
  EndProcedure
  
  Procedure.s GetDebugBarText()
    ProcedureReturn view\debug_bar_text
  EndProcedure
  
  Procedure.i GetWindow()
    ProcedureReturn view\window
  EndProcedure
  
  Procedure.b IsFullScreen()
    ProcedureReturn Bool(view\display_mode = #DISPLAY_FULLSCREEN)
  EndProcedure
  
  Procedure.i GetMainDesktopWidth()
    ExamineDesktops()
    ProcedureReturn DesktopWidth(0)
  EndProcedure
  
  Procedure.i GetMainDesktopHeight()
    ExamineDesktops()
    ProcedureReturn DesktopHeight(0)
  EndProcedure
  ;}
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 90
; FirstLine = 61
; Folding = -----
; Module generated by PBOrganizer