## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add valkey-objects

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install valkey-objects

## Usage

```ruby
require "valkey/objects"

## Valkey Object Classes
class X
  include ValkeyObjects
  value :myValue
  counter :myCounter
  list :myList
  set :mySet
  hash_key :myHash
  sorted_set :mySortedSet
  def initialize k
    ### must have an @id
    @id = k
  end
end

## Valkey Object Instances
@user = X.new("id")

### simple value
@user.myValue.value = "Alice"
@user.myValue.value #=> "Alice"

### simple counter
@user.myCounter.increment
@user.myCounter.decrement
@user.myCounter.increment 1
@user.myCounter.decrement 2
@user.myCounter.to_i #=> -1

### lists
@user.myList << "item"
@user.myList << "this"
@user.myList[1] #=> "this"
@user.myList[1] = "next"
@user.myList.shift
@user.myList.to_a #=> ["next"]
@user.myList.knn #=> values as KNN object

### sets
@user.mySet << "one"
@user.mySet << "two"
@user.mySet.members
@user.mySet.knn #=> members as KNN object

### hashes
@user.myHash[:key] = "value"
@user.myHash[:key] #=> "value"
@user.myHash.to_h

### sorted sets
@user.mySortedSet["entry"] = 100
@user.mySortedSet["entry"] #=> 100
@user.mySortedSet.incr("entry", 1.1)
@user.mySortedSet.decr("entry", 2)
@user.mySortedSet.members
@user.mySortedSet.knn #=> members as KNN object

## KNN objects
knn.hood("query") => [{ string: "entry string", distance: 1 }, ...]
knn.rank("query") => [{ string: "entry string", distance: 1, similarity: 0.8 }, ...]
knn["query"] => "entry"
```
