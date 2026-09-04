module PokeBattle_SceneConstants
  USECOMMANDBOX = true # If true, expects the file Graphics/Pictures/Battle/battleCommand.png
  USEFIGHTBOX   = true # If true, expects the file Graphics/Pictures/Battle/battleFight.png

  # Text colors
  MESSAGEBASECOLOR        = Color.new(80,80,88)
  MESSAGESHADOWCOLOR      = Color.new(160,160,168)
  MENUBASECOLOR           = MESSAGEBASECOLOR
  MENUSHADOWCOLOR         = MESSAGESHADOWCOLOR
  BOXTEXTBASECOLOR        = Color.new(238,238,238)
  BOXTEXTSHADOWCOLOR      = Color.new(60,60,60)
  PPTEXTBASECOLOR         = MESSAGEBASECOLOR        # More than 1/2 of total PP
  PPTEXTSHADOWCOLOR       = MESSAGESHADOWCOLOR
  PPTEXTBASECOLORYELLOW   = Color.new(248,192,0)    # 1/2 of total PP or less
  PPTEXTSHADOWCOLORYELLOW = Color.new(144,104,0)
  PPTEXTBASECOLORORANGE   = Color.new(248,136,32)   # 1/4 of total PP or less
  PPTEXTSHADOWCOLORORANGE = Color.new(144,72,24)
  PPTEXTBASECOLORRED      = Color.new(248,72,72)    # Zero PP
  PPTEXTSHADOWCOLORRED    = Color.new(136,48,48)

  # HP bar colors
  HPCOLORGREEN        = Color.new(24,192,32)
  HPCOLORGREENDARK    = Color.new(0,144,0)
  HPCOLORYELLOW       = Color.new(248,176,0)
  HPCOLORYELLOWDARK   = Color.new(176,104,8)
  HPCOLORRED          = Color.new(248,88,40)
  HPCOLORREDDARK      = Color.new(168,48,56)

  # Exp bar colors
  EXPCOLORBASE       = Color.new(72,144,248)
  EXPCOLORSHADOW     = Color.new(48,96,216)

  # Position and width of HP/Exp bars
  HPGAUGE_X    = 102
  HPGAUGE_Y    = 40
  HPGAUGESIZE  = 96
  EXPGAUGE_X   = 6
  EXPGAUGE_Y   = 76
  EXPGAUGESIZE = 192

  # Coordinates of the top left of the player's data boxes
  PLAYERBOX_X   = Graphics.width - 244
  PLAYERBOX_Y   = Graphics.height - 192
  PLAYERBOXD1_X = PLAYERBOX_X - 12
  PLAYERBOXD1_Y = PLAYERBOX_Y - 20
  PLAYERBOXD2_X = PLAYERBOX_X
  PLAYERBOXD2_Y = PLAYERBOX_Y + 34

  # Coordinates of the top left of the foe's data boxes
  FOEBOX_X      = -16
  FOEBOX_Y      = 36
  FOEBOXD1_X    = FOEBOX_X + 12
  FOEBOXD1_Y    = FOEBOX_Y - 34
  FOEBOXD2_X    = FOEBOX_X
  FOEBOXD2_Y    = FOEBOX_Y + 20

  # Coordinates of the top left of the player's Safari game data box
  SAFARIBOX_X = Graphics.width - 232
  SAFARIBOX_Y = Graphics.height - 184

  # Coordinates of the party bars and balls of both sides
  # Coordinates are the top left of the graphics except where specified
  PLAYERPARTYBAR_X    = Graphics.width - 248
  PLAYERPARTYBAR_Y    = Graphics.height - 142
  PLAYERPARTYBALL1_X  = PLAYERPARTYBAR_X + 44
  PLAYERPARTYBALL1_Y  = PLAYERPARTYBAR_Y - 30
  PLAYERPARTYBALL_GAP = 32
  FOEPARTYBAR_X       = 248   # Coordinates of end of bar nearest screen middle
  FOEPARTYBAR_Y       = 114
  FOEPARTYBALL1_X     = FOEPARTYBAR_X - 44 - 30   # 30 is width of ball icon
  FOEPARTYBALL1_Y     = FOEPARTYBAR_Y - 30
  FOEPARTYBALL_GAP    = 32   # Distance between centres of two adjacent balls

  # Coordinates of the centre bottom of the player's battler's sprite
  # Is also the centre middle of its shadow
  PLAYERBATTLER_X   = 128
  PLAYERBATTLER_Y   = Graphics.height - 80
  PLAYERBATTLERD1_X = PLAYERBATTLER_X - 48
  PLAYERBATTLERD1_Y = PLAYERBATTLER_Y
  PLAYERBATTLERD2_X = PLAYERBATTLER_X + 32
  PLAYERBATTLERD2_Y = PLAYERBATTLER_Y + 16

  # Coordinates of the centre bottom of the foe's battler's sprite
  # Is also the centre middle of its shadow
  FOEBATTLER_X      = Graphics.width - 128
  FOEBATTLER_Y      = (Graphics.height * 3/4) - 112
  FOEBATTLERD1_X    = FOEBATTLER_X + 48
  FOEBATTLERD1_Y    = FOEBATTLER_Y
  FOEBATTLERD2_X    = FOEBATTLER_X - 32
  FOEBATTLERD2_Y    = FOEBATTLER_Y - 16

  # Centre bottom of the player's side base graphic
  PLAYERBASEX = PLAYERBATTLER_X
  PLAYERBASEY = PLAYERBATTLER_Y

  # Centre middle of the foe's side base graphic
  FOEBASEX    = FOEBATTLER_X
  FOEBASEY    = FOEBATTLER_Y

  # Coordinates of the centre bottom of the player's sprite
  PLAYERTRAINER_X   = PLAYERBATTLER_X
  PLAYERTRAINER_Y   = PLAYERBATTLER_Y - 16
  PLAYERTRAINERD1_X = PLAYERBATTLERD1_X
  PLAYERTRAINERD1_Y = PLAYERTRAINER_Y
  PLAYERTRAINERD2_X = PLAYERBATTLERD2_X
  PLAYERTRAINERD2_Y = PLAYERTRAINER_Y

  # Coordinates of the centre bottom of the foe trainer's sprite
  FOETRAINER_X      = FOEBATTLER_X
  FOETRAINER_Y      = FOEBATTLER_Y + 6
  FOETRAINERD1_X    = FOEBATTLERD1_X
  FOETRAINERD1_Y    = FOEBATTLERD1_Y + 6
  FOETRAINERD2_X    = FOEBATTLERD2_X
  FOETRAINERD2_Y    = FOEBATTLERD2_Y + 6

  # Default focal points of user and target in animations - do not change!
  FOCUSUSER_X   = 128   # 144
  FOCUSUSER_Y   = 224   # 188
  FOCUSTARGET_X = 384   # 352
  FOCUSTARGET_Y = 96    # 108, 98

  def self.pbSidePosition(index)
    return index / 2
  end

  def self.pbBattlerPosition(index, sideSize = 1)
    sideSize = 1 if !sideSize || sideSize < 1
    position = pbSidePosition(index)
    opposing = (index & 1) == 1
    if opposing
      case sideSize
      when 1
        return [FOEBATTLER_X, FOEBATTLER_Y]
      when 2
        positions = [
          [FOEBATTLERD1_X, FOEBATTLERD1_Y],
          [FOEBATTLERD2_X, FOEBATTLERD2_Y]
        ]
      else
        positions = [
          [FOEBATTLER_X + 72, FOEBATTLER_Y],
          [FOEBATTLER_X,      FOEBATTLER_Y - 16],
          [FOEBATTLER_X - 72, FOEBATTLER_Y - 32]
        ]
      end
    else
      case sideSize
      when 1
        return [PLAYERBATTLER_X, PLAYERBATTLER_Y]
      when 2
        positions = [
          [PLAYERBATTLERD1_X, PLAYERBATTLERD1_Y],
          [PLAYERBATTLERD2_X, PLAYERBATTLERD2_Y]
        ]
      else
        positions = [
          [PLAYERBATTLER_X - 72, PLAYERBATTLER_Y - 12],
          [PLAYERBATTLER_X,      PLAYERBATTLER_Y],
          [PLAYERBATTLER_X + 72, PLAYERBATTLER_Y + 16]
        ]
      end
    end
    return positions[position] || positions[-1]
  end

  def self.pbTrainerPosition(opposing, trainerIndex = 0, sideSize = 1)
    if opposing
      case sideSize
      when 1
        return [FOETRAINER_X, FOETRAINER_Y]
      when 2
        positions = [
          [FOETRAINERD1_X, FOETRAINERD1_Y],
          [FOETRAINERD2_X, FOETRAINERD2_Y]
        ]
      else
        positions = [
          [FOETRAINER_X + 52, FOETRAINER_Y],
          [FOETRAINER_X - 12, FOETRAINER_Y - 18],
          [FOETRAINER_X - 76, FOETRAINER_Y - 36]
        ]
      end
    else
      case sideSize
      when 1
        return [PLAYERTRAINER_X, PLAYERTRAINER_Y]
      when 2
        positions = [
          [PLAYERTRAINERD1_X, PLAYERTRAINERD1_Y],
          [PLAYERTRAINERD2_X, PLAYERTRAINERD2_Y]
        ]
      else
        positions = [
          [PLAYERTRAINER_X - 52, PLAYERTRAINER_Y - 6],
          [PLAYERTRAINER_X,      PLAYERTRAINER_Y],
          [PLAYERTRAINER_X + 52, PLAYERTRAINER_Y + 8]
        ]
      end
    end
    return positions[trainerIndex] || positions[0]
  end

  def self.pbDataBoxPosition(index, sideSize = 1)
    sideSize = 1 if !sideSize || sideSize < 1
    position = pbSidePosition(index)
    opposing = (index & 1) == 1
    if opposing
      case sideSize
      when 1
        return [FOEBOX_X, FOEBOX_Y]
      when 2
        positions = [
          [FOEBOXD1_X, FOEBOXD1_Y],
          [FOEBOXD2_X, FOEBOXD2_Y]
        ]
      else
        positions = [
          [FOEBOXD1_X + 8, FOEBOX_Y],
          [FOEBOX_X + 4,   FOEBOX_Y + 46],
          [FOEBOXD2_X,     FOEBOX_Y + 92]
        ]
      end
    else
      case sideSize
      when 1
        return [PLAYERBOX_X, PLAYERBOX_Y]
      when 2
        positions = [
          [PLAYERBOXD1_X, PLAYERBOXD1_Y],
          [PLAYERBOXD2_X, PLAYERBOXD2_Y]
        ]
      else
        positions = [
          [PLAYERBOXD1_X - 8, PLAYERBOX_Y - 52],
          [PLAYERBOX_X - 4,   PLAYERBOX_Y - 2],
          [PLAYERBOXD2_X,     PLAYERBOX_Y + 48]
        ]
      end
    end
    return positions[position] || positions[-1]
  end
end
