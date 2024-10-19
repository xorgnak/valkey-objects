# ValKey Objects
Based upon the redis-objects library, VK allows for ValKey backed ruby objects.

## installation
```
gem install valkey-objects
```

## usage

### simple
```
require 'valkey/objects'
class ValKey
  # 1. include valkey-objects layer
  include VK
  # 2. stitch your object together.
  value :myvalue
  counter :mycounter
  hashkey :myhash
  sortedset :mysortedset
  set :myset
  queue :myqueue
  place :myplace
  pipe :mypipe
  toggle :mytoggle
  # 3. define @id in initialize.
  def initialize k
    @id = k
  end
  # other stuff...
end

@x = ValKey.new("My Special Valkey object.")
@x.mypipe.on { |msg| puts %[MSG]; ap msg }
@x.mypipe << "Pipe Connected!"
@x.myvalue.value = "Hello, World"
@x.mycounter.value = 1.2345
@x.myhash[:key] = "Value"
@x.mysortedset["my other key"] = 9.8
@x.mysortedset.poke "my key", @x.mysortedset["my other key"]
@x.mysortedset.value { |i, e| puts %[Sorted Sets: i: #{i} e: #{e}] }
@x.myset << "my member"
@x.myset << "my new member"
h = @x.myset[/ new /]
@x.myset.value { |i, e| puts %[Sets: i: #{i} e: #{e}] }
@x.myplace.add "Palermo", 13.361389, 38.115556
@x.myplace.add "Catania", 15.087269, 37.502669
distance = @x.myplace.distance "Palermo", "Catania"
places = @x.myplace.radius 15.087269, 37.502669, 5000
@x.myplace.value { |i, e| puts %[Places: i: #{i} e: #{e}] }
```

### advanced
```
class Game
  include VK
  sortedset :points
  def initialize k
    @id = k
  end
  def score p, h={ points: 1 }
    self.points.poke p, h[:points]
  end
end

@game = Hash.new { |h,k| h[k] = Game.new(k) }
```

### modular
```
module X
  @@X = Hash.new { |h,k| h[k] = Ex.new(k) }
  class Ex
    include VK
    set :stuff
    pipe :ear
    def initialize k
      @id = k
    end
  end
  def self.keys
    @@X.keys
  end
  def self.[] k
    if !@@X.has_key?(k)
      @@X[k].ear.on { |msg| puts "MSG[#{k}]:"; ap msg }
    end
    @@X[k]
  end
end

X['Aaa'].ear << %[A]
X['Bbb'].ear << %[B]
X['Ccc'].ear << %[C]

```
