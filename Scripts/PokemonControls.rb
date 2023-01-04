module Input
  C  = 13
  A  = 14
  #F3    = 20
  SHIFT  = 21
  CTRL  = 22
  ALT    = 23
  #F4    = 24
  F5     = 25
  F6     = 26
  F7     = 27
  F8     = 28
  F9     = 29
  LeftMouseKey  = 38
  RightMouseKey = 40
  PAGEUP = L
  PAGEDOWN = R
  ITEMKEYS      = [Input::F5,Input::F6,Input::SHIFT]
  ITEMKEYSNAMES = [_INTL("F5"),_INTL("F6"),_INTL("Shift")]

  def self.getstate(button)
    self.pressex?(button)
  end
end

module Mouse
  module_function

  # Returns the position of the mouse relative to the game window.
  def getMousePos(catch_anywhere = false)
    return nil unless System.mouse_in_window || catch_anywhere
    return Input.mouse_x, Input.mouse_y
  end
end