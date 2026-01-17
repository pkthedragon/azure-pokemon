#70925035
begin
  class PBStatuses
    SLEEP     = 1
    POISON    = 2
    BURN      = 3
    PARALYSIS = 4
    FROZEN    = 5
    CRUSHED   = 6
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  else
  end
end