# ValKey Objects
- Standard `gem install valkey-objects` and `bundle add valkey-objects` installation.
- Use `require 'valkey/objects'`.
- Example:
```
class Example
  include VK

  timestamp :myTimestamp
  toggle :myToggle
  value :myValue
  counter :myCounter
  hashkey :myHashKey
  sortedset :mySortedSet
  set :mySet
  queue :myQueue
  place :myPlace
  pipe :myPipe

  def initialize k
    @id = k
  end
  # whatever ...
end

@obj = Example.new("Object UUID")

## Deleting keys
@obj.myKey.expire seconds
@obj.myKey.expireAt Time.utc
@obj.myKey.delete!

@obj.myTimestamp.value! => set to utc epoch
@obj.myTimestamp.value => ...
@obj.myTimestamp.ago => seconds since
@obj.myTimestamp.to_time => Time object

@obj.myToggle.value = true or false
@obj.myToggle.value => ...
@obj.myToggle.value! => value = !value

@obj.myvalue = "A String"
@obj.myValue => "A string"

@obj.myCounter = number
@obj.myCounter => number
@obj.incr number
@obj.decr number

@obj.myHashKey[:stringKey] = "Another String"
@obj.myHashKey[:numberKey] = 1.23
@obj.myHashKey[:key] => value

@obj.mySortedSet.poke key, number
@obj.mySotredSet[key] => score
@obj.mySortedSet.value { |key, index| ... }

@obj.mySet << "obj"
@obj.mySet["o"] => ["obj", ...]
@obj.mySet.rm "obj"
@obj.mySet & @obj.otherSet
@obj.mySet | @obj.otherSet
@obj.mySet.value { |key, index| ... }

@obj.myQueue << "obj"
@obj.myQueue.length => 1
@obj.myQueue.front => "obj" && pop
@obj.myQueue.value { |key, index| ... }

@obj.myPlace "My Place", longitude, latitude
@obj.myPlace["My Place"] => { longitude: X, latitude: Y }
@obj.myPlace.distance "My Place", "Other Place"
@obj.myPlace.radius longitude, latitude, distance
@obj.myPlace.value { |key, index| ... }
```
