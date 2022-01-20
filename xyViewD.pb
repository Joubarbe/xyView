DeclareModule xyView
  UseModule xyView_Common : EnableExplicit

  ;{ STRUCTURES / PROTOTYPES
  Prototype __callback_setup()
  Prototype __callback_window_events(event.i)
  Prototype __callback_input_events()
  Prototype __callback_update(delta_time.f)
  Prototype __callback_render()
  ;}

  ;{ CONSTANTS
  
  ;}

  ;{ GLOBALS
  
  ;}

  ;{ DECLARES
  Declare SetCallbacks(*setup.__callback_setup = #PB_Ignore, 
                       *window_events.__callback_window_events = #PB_Ignore, 
                       *input_events.__callback_input_events = #PB_Ignore, 
                       *update.__callback_update = #PB_Ignore, 
                       *render.__callback_render = #PB_Ignore)
  Declare StartLoopInFullScreen(window_title.s = "")
  Declare StartLoopInWindowed(width.i, height.i, window_title.s = "", show_window_controls.b = #True)
  Declare StartLoopInBorderless(width.i, height.i, window_title.s = "")
  Declare ShowDebugBar()
  Declare HideDebugBar()
  Declare SetDebugBarText(text.s)
  Declare.s GetDebugBarText()
  Declare.i GetWindow()
  Declare.b IsFullScreen()
  Declare.i GetMainDesktopWidth()
  Declare.i GetMainDesktopHeight()
  ;}
EndDeclareModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 26
; Folding = -
; EnableXP