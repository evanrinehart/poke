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
