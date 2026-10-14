module AzureTimingFixture
  STATUS_PATH=File.join(Dir.pwd,"timing_runtime.status.txt")
  RATES=[44,88,110,132,176]

  def self.screen_signature(rate,frameskip)
    Graphics.frame_rate=rate
    Graphics.frameskip=frameskip
    screen=Game_Screen.new
    screen.start_tone_change(Tone.new(40,-20,12,8),44)
    screen.start_flash(Color.new(10,20,30,220),44)
    screen.start_shake(6,4,44)
    screen.weather(1,5,44)
    picture=screen.pictures[1]
    picture.show("",0,0,0,100,100,255,0)
    picture.move(44,0,88,44,150,75,128,1)
    timer=Game_System.new
    timer.timer_working=true
    timer.timer=44
    character=Game_Character.new
    character.instance_variable_set(:@wait_count,44)
    for i in 0...44
      screen.update
      timer.update
      character.update
    end
    original_step_event=Events.onStepTakenFieldMovement
    movement_steps=0
    begin
      Events.onStepTakenFieldMovement=Event.new
      mover=Game_Character.new
      mover.instance_variable_set(:@x,1)
      mover.instance_variable_set(:@real_x,0)
      while mover.moving? && movement_steps<100
        mover.update_move
        movement_steps+=1
      end
    ensure
      Events.onStepTakenFieldMovement=original_step_event
    end
    animation_updates=0
    animation_source=::Sprite.new
    animation_probe=SpriteAnimation.new(animation_source)
    animation_probe.instance_variable_set(:@_animation,Object.new)
    animation_probe.instance_variable_set(:@_animation_duration,5)
    animation_probe.define_singleton_method(:update_animation) { animation_updates+=1 }
    initial_frame=Graphics.frame_count
    for frame in 0...10
      Graphics.frame_count=frame
      animation_probe.update
    end
    animation_duration=animation_probe.instance_variable_get(:@_animation_duration)
    animation_probe.instance_variable_set(:@_animation,nil)
    animation_probe.dispose
    animation_source.dispose
    Graphics.frame_count=initial_frame
    tone=screen.tone
    flash=screen.flash_color
    return [
      tone.red,tone.green,tone.blue,tone.gray,
      flash.red,flash.green,flash.blue,flash.alpha,
      screen.shake,screen.weather_type,screen.weather_max,
      screen.instance_variable_get(:@weather_duration),
      picture.x,picture.y,picture.zoom_x,picture.zoom_y,
      picture.opacity,picture.blend_type,timer.timer,
      character.instance_variable_get(:@wait_count),movement_steps,
      animation_updates,animation_duration
    ].join(',')
  end

  def self.second_scaled_signature(rate,frameskip)
    Graphics.frame_rate=rate
    Graphics.frameskip=frameskip
    screen=Game_Screen.new
    screen.weather(1,3,rate)
    timer=Game_System.new
    timer.timer_working=true
    timer.timer=rate
    for i in 0...rate
      screen.update
      timer.update
    end
    return [timer.timer,screen.instance_variable_get(:@weather_duration),
            screen.weather_type,screen.weather_max].join(',')
  end

  def self.measure_updates(rate,frameskip)
    Graphics.frame_rate=rate
    Graphics.frameskip=frameskip
    Graphics.frame_reset
    frames=[(rate/8),4].max
    started=Process.clock_gettime(Process::CLOCK_MONOTONIC)
    for i in 0...frames; Graphics.update; end
    elapsed=Process.clock_gettime(Process::CLOCK_MONOTONIC)-started
    expected=frames.to_f/rate
    valid=(elapsed>=expected*0.45 && elapsed<=expected*3.0+0.1)
    return [frames,elapsed,expected,valid]
  end

  def self.write(rows)
    File.open(STATUS_PATH,"wb") {|file|
      for row in rows; file.write(row+"\r\n"); end
    }
  end

  def self.run
    unless Graphics.respond_to?(:frameskip=)
      write(["result=FAIL","error=Graphics.frameskip= is unavailable"])
      raise "Graphics.frameskip= is unavailable"
    end
    saved_game_temp=$game_temp
    saved_game_system=$game_system
    saved_rate=Graphics.frame_rate
    saved_frame_count=Graphics.frame_count
    rows=[]
    begin
      $game_temp=Game_Temp.new
      $game_system=Game_System.new
      logical_signatures={}
      scaled_signatures={}
      frameskip_logic_exact=true
      scaled_timer_exact=true
      paced_updates_valid=true
      for rate in RATES
        off=screen_signature(rate,false)
        on=screen_signature(rate,true)
        logical_signatures[rate]=off
        frameskip_logic_exact=false if off!=on
        scaled_off=second_scaled_signature(rate,false)
        scaled_on=second_scaled_signature(rate,true)
        scaled_signatures[rate]=scaled_off
        scaled_timer_exact=false if scaled_off!=scaled_on || scaled_off!="0,0,1,16.0"
        for frameskip in [false,true]
          measured=measure_updates(rate,frameskip)
          paced_updates_valid=false if !measured[3]
          rows.push("paced_#{rate}_#{frameskip ? 'on' : 'off'}_frames=#{measured[0]}")
          rows.push("paced_#{rate}_#{frameskip ? 'on' : 'off'}_seconds=#{measured[1]}")
          rows.push("paced_#{rate}_#{frameskip ? 'on' : 'off'}_expected=#{measured[2]}")
        end
      end
      base_signature=logical_signatures[44]
      logical_rate_exact=true
      for rate in RATES
        logical_rate_exact=false if logical_signatures[rate]!=base_signature
      end
      turbo_multipliers=RATES.map {|rate| rate.to_f/44 }
      playtime_seconds=RATES.map {|rate| rate/44.0 }
      message_quarter_seconds=RATES.map {|rate| (rate/4).to_f/rate }
      message_full_seconds=RATES.map {|rate| rate.to_f/rate }
      message_custom20_seconds=RATES.map {|rate| 20.0/rate }
      credits_slide_seconds=RATES.map {|rate| (CreditsFrequency*rate).to_f/rate }
      movement_animation_exact=base_signature.end_with?(",8,5,0")
      result=(logical_rate_exact && frameskip_logic_exact && scaled_timer_exact &&
              paced_updates_valid && movement_animation_exact)
      rows.unshift("credits_slide_seconds=#{credits_slide_seconds.join(',')}")
      rows.unshift("message_custom20_seconds=#{message_custom20_seconds.join(',')}")
      rows.unshift("message_full_seconds=#{message_full_seconds.join(',')}")
      rows.unshift("message_quarter_seconds=#{message_quarter_seconds.join(',')}")
      rows.unshift("playtime_seconds_per_wall_second=#{playtime_seconds.join(',')}")
      rows.unshift("turbo_multipliers=#{turbo_multipliers.join(',')}")
      rows.unshift("paced_updates_valid=#{paced_updates_valid}")
      rows.unshift("second_scaled_timers_exact=#{scaled_timer_exact && scaled_signatures.values.uniq.length==1}")
      rows.unshift("frameskip_logical_parity=#{frameskip_logic_exact}")
      rows.unshift("logical_rate_parity=#{logical_rate_exact}")
      rows.unshift("movement_animation_exact=#{movement_animation_exact}")
      rows.unshift("logical_signature=#{base_signature}")
      rows.unshift("rates=#{RATES.join(',')}")
      rows.unshift("scenarios=#{RATES.length*2}")
      rows.unshift("result=#{result ? 'PASS' : 'FAIL'}")
      rows.push("frame_skip_scope=render_scheduling_only")
      rows.push("turbo_scope=intentional_simulation_speed_multiplier")
      rows.push("fixed_44_playtime_policy=preserved")
      rows.push("probe_errors=none")
      write(rows)
      raise "Timing fixture failed" if !result
    rescue Exception
      write(["result=FAIL","error=#{$!.class}: #{$!.message}"])
      raise
    ensure
      Graphics.frameskip=false
      Graphics.frame_rate=saved_rate
      Graphics.frame_count=saved_frame_count
      Graphics.frame_reset
      $game_temp=saved_game_temp
      $game_system=saved_game_system
    end
    return true
  end
end

AzureTimingFixture.run
