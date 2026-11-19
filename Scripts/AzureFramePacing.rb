module AzureFramePacing
  HIGH_RESOLUTION_TIMER = 2
  TIMER_ACCESS = 0x00100002  # SYNCHRONIZE | TIMER_MODIFY_STATE
  PHASE_MARGIN_NS = 300_000

  def self.reset
    @deadline = nil
  end

  def self.frozen=(frozen)
    @frozen = frozen
    reset
  end

  def self.timer
    return @timer unless @timer.nil?
    create_timer = Win32API.new("kernel32", "CreateWaitableTimerExW", "IIII", "L")
    @set_timer = Win32API.new("kernel32", "SetWaitableTimer", "LpIIII", "I")
    @wait_timer = Win32API.new("kernel32", "WaitForSingleObject", "LI", "I")
    @close_timer = Win32API.new("kernel32", "CloseHandle", "L", "I")
    handle = create_timer.call(0, 0, HIGH_RESOLUTION_TIMER, TIMER_ACCESS)
    @timer = handle != 0 ? handle : false
  rescue StandardError, LoadError
    @timer = false
  end
  private_class_method :timer

  def self.now
    Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
  end
  private_class_method :now

  def self.wait(nanoseconds)
    # A negative due time is an interval in 100 ns units.
    interval = [-(nanoseconds / 100).floor].pack("q<")
    return if @set_timer.call(@timer, interval, 0, 0, 0, 0) != 0 &&
              @wait_timer.call(@timer, 250) == 0
    release_timer
  end
  private_class_method :wait

  def self.release_timer
    @close_timer.call(@timer) if @timer
    @timer = false
    reset
  end
  private_class_method :release_timer

  # Return true when the engine should reset its frame limiter before drawing.
  def self.before_frame(rate, frame_count)
    return false if @frozen || !timer
    if @deadline && rate == @rate && frame_count == @last_frame
      @deadline += @period
      remaining = @deadline - now
      if remaining >= -@period
        wait(remaining) if remaining >= 100
        return false
      end
    end
    @rate = rate
    @period = 1_000_000_000.0 / rate
    reset
    return true
  end

  def self.after_frame(previous_frame, frame_count)
    return if @frozen || !@timer
    if frame_count == previous_frame + 1
      # The engine sets its origin before swapping buffers. Start just after
      # that point so its existing limiter has no coarse wait left to perform.
      @deadline ||= now + PHASE_MARGIN_NS
    else
      reset
    end
    @last_frame = frame_count
  end

  module GraphicsHooks
    def update
      previous_frame = frame_count
      frame_reset if AzureFramePacing.before_frame(frame_rate, previous_frame)
      result = super
      AzureFramePacing.after_frame(previous_frame, frame_count)
      return result
    end

    def frame_reset
      AzureFramePacing.reset
      super
    end

    def freeze
      AzureFramePacing.frozen = true
      super
    end

    def transition_KGC_SpecialTransition(*args)
      super
    ensure
      AzureFramePacing.frozen = false
    end
  end

  def self.install
    graphics = Graphics.singleton_class
    if graphics.ancestors.include?(GraphicsHooks)
      self.frozen = false
      return
    end
    config = defined?(CFG) ? CFG.to_hash : {}
    # Leave explicit engine timing overrides in control.
    return if config["fixedFramerate"].to_i != 0 || config["syncToRefreshrate"]
    graphics.prepend(GraphicsHooks)
    Kernel.at_exit { release_timer }
  end
end

AzureFramePacing.install if $MKXP && RUBY_PLATFORM.match?(/mingw|mswin/)
