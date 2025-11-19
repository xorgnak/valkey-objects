## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add valkey-objects

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install valkey-objects

## Usage

```ruby
require "valkey/objects"

class X
  include ValkeyObjects
  value :myValue
  counter :myCounter
  list :myList
  set :mySet
  hash_key :myHash
  sorted_set :mySortedSet
end

@user = X.new
@user.myValue.value = "Alice"
@user.myValue.value #=> "Alice"

@user.myCounter.increment
@user.myCounter.decrement
@user.myCounter.increment 1
@user.myCounter.decrement 2
@user.myCounter.to_i #=> -1

@user.myList << "item"
@user.myList << "this"
@user.myList[1] #=> "this"
@user.myList[1] = "next"
@user.myList.shift
@user.myList.to_a #=> ["next"]
@user.myList.knn #=> values as KNN object

@user.mySet << "one"
@user.mySet << "two"
@user.mySet.members
@user.mySet.knn #=> members as KNN object

@user.myHash[:key] = "value"
@user.myHash[:key] #=> "value"
@user.myHash.to_h
```
