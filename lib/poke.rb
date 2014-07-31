require 'thread'

class Poke

  def initialize
    @lock = Mutex.new
    @cond = ConditionVariable.new
    @wake_thread = nil

    Signal.trap 'ALRM' do
      @lock.synchronize do
        @cond.signal
      end
    end

    Thread.new do
      loop do
        @lock.synchronize do
          @cond.wait @lock
        end
        on_poke
      end
    end

    sleep
  end

  def wake_after seconds
    @lock.synchronize do
      @wake_thread.kill if @wake_thread
      @wake_thread = Thread.new do
        if seconds
          sleep seconds
        else
          sleep # forever
        end

        Process.kill 'ALRM', $$
      end
    end
  end

end


