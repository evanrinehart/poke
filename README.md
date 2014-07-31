poke is a concurrency primitive with the following semantics

- agent may be either working or sleeping
- if agent is poked while sleeping, it begins working
- if agent is poked while working, nothing happens
- when agent finishes working, it begins sleeping
- the action of poking never blocks

To create a process which can be poked (with a SIG_ALRM) require the gem and
make a class with Poke as the parent class. Then define an on_poke method
which will be executed when a SIG_ALRM occurs.


```ruby
require 'poke'

class Beezlebub < Poke

  def on_poke
    # do my bidding.
    #
    # during this work, poking has no effect.
    #
    # poking works again after this action completes.
  end

end

Beezlebub.new # never returns
```

Within the on_poke callback you can set an alarm to poke you after a number
of seconds pass. You have at most one alarm set at a time. Setting the alarm
cancels a previous alarm if it was set already.


```ruby
require 'poke'

class Beezlebub < Poke

  def initialize
    @telescope = Telescope.new
    @ship_speed = 3.0
    super
  end

  def on_poke
    # do my bidding.
    
    eta = @telescope.how_far("ship") / @ship_speed

    # auto poke in eta seconds
    wake_after eta

    # note that I can't be poked right now, even by
    # my own alarm, so we can write the action in isolation
  end

end

Beezlebub.new # never returns
```

## Relevance

### What is the point of a procedure which can only be running at most once?
If it is guaranteed to be running at most once, now you have serialized
the process. A serialized process can't interfere with itself. This makes
it easier to reason about correctness of the process.

### What is the difference between using this and simply running a script?
If you have concurrent requests, each of which may run this script, then you
will have multiple instances of the script running at a time. See previous
question on why that is bad. If you want only one such script running at a time
you now need serialization. Having a pokable demon running solves the
serialization.

### The way poke works, you are guaranteed to miss some pokes when throughput ramps up. What's up with that?
The use case I have in my head involves processing unprocessed messages. As
long as my demon does not lock up or crash without reviving, messages will get
processed next time it wakes up.

### Why don't you just make a cron job poll once a minute?
That would be unresponsive. Each request that emits messages can optionally
issue a poke to attempt to immediately handle the new message.

### Why don't you poll once a second?
Not as unresponsive as a cron job, but now we have issues if the processing
takes more than a second. I will begin running over myself.

### Busy loop!
Like all polling solutions its a waste of CPU and network.

### Why don't you lock a unix semaphore on run so a second instance of the script can't run?
Too many games to ensure the semaphore doesn't get stuck locked due to
an abnormal termination of the script.

### Problems of this class can be nicely solved using a redis-based job queue server.
Maybe they can.
