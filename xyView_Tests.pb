XIncludeFile "xyView.pb"

EnableExplicit

Procedure OnSetup()
  
EndProcedure

Procedure OnWindowEvents(event.i)
  If event = #PB_Event_CloseWindow
    End
  EndIf
EndProcedure

Procedure OnInputEvents()
  If KeyboardReleased(#PB_Key_Escape)
    End
  EndIf
EndProcedure

Procedure OnUpdate(delta_time.f)
  
EndProcedure

Procedure OnRender()
  
EndProcedure

xyView::SetCallbacks(#PB_Ignore, @OnWindowEvents(), @OnInputEvents())
xyView::ShowDebugBar()
xyView::SetDebugBarText("debug custom information")

; xyView::StartLoopInWindowed(500, 300, "title")
xyView::StartLoopInFullScreen("title")
; xyView::StartLoopInBorderless(500, 300, "title")
; xyView::StartLoopInBorderless(xyView::GetMainDesktopWidth(), xyView::GetMainDesktopHeight(), "title")
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 28
; Folding = -
; EnableXP