claude.md

valkey-objects
===============

Short description
-----------------
valkey-objects is a small Ruby gem that provides an object-oriented wrapper around a Valkey key-value store client, inspired by the redis-objects project. It lets you declare per-instance Valkey-backed primitives (value, counter, list, set, hash_key, sorted_set) directly on Ruby classes and work with them through simple, idiomatic instance accessors.

Key features
------------
- Declare Valkey-backed primitives at the class level and access them from instances
- Simple value storage
- Atomic counters
- Lists with array-like access and KNN helpers
- Sets and sorted sets with typical set semantics and KNN helpers
- Hash-like key/value storage
- Small, dependency-light wrapper suitable for embedding in apps

Installation
------------
Add to your Gemfile or install via gem:

    bundle add valkey-objects

or

    gem install valkey-objects

Usage
-----
Example (adapted from README):

    require "valkey/objects"

    class X
      include ValkeyObjects
      value :myValue
      counter :myCounter
      list :myList
      set :mySet
      hash_key :myHash
      sorted_set :mySortedSet

      def initialize k
        @id = k
      end
    end

    user = X.new("id")

    # value
    user.myValue.value = "Alice"
    user.myValue.value # => "Alice"

    # counter
    user.myCounter.increment
    user.myCounter.decrement
    user.myCounter.increment 1
    user.myCounter.decrement 2
    user.myCounter.to_i # => -1

    # list
    user.myList << "item"
    user.myList << "this"
    user.myList[1] # => "this"
    user.myList[1] = "next"
    user.myList.shift
    user.myList.to_a # => ["next"]
    user.myList.knn # => values as KNN object

    # set
    user.mySet << "one"
    user.mySet << "two"
    user.mySet.members
    user.mySet.knn # => members as KNN object

    # hash
    user.myHash[:key] = "value"
    user.myHash[:key] # => "value"
    user.myHash.to_h

    # sorted set
    user.mySortedSet["entry"] = 100
    user.mySortedSet["entry"] # => 100
    user.mySortedSet.incr("entry", 1.1)
    user.mySortedSet.decr("entry", 2)
    user.mySortedSet.members
    user.mySortedSet.knn # => members as KNN object

KNN helpers
-----------
The gem exposes KNN helper objects in several collection types (lists, sets, sorted sets). Typical KNN usage is:

    knn.hood("query")  # => [{ string: "entry string", distance: 1 }, ...]
    knn.rank("query")  # => [{ string: "entry string", distance: 1, similarity: 0.8 }, ...]
    knn["query"]       # => "entry"

API overview
------------
- value :name — simple key/value object with .value getter/setter
- counter :name — atomic counter with .increment, .decrement, .to_i
- list :name — ordered list with array accessors, push, shift, to_a, knn
- set :name — unordered unique members with <<, members, knn
- hash_key :name — hash-like storage accessible with [] and []=
- sorted_set :name — score-sorted set with []=, [], incr, decr, members, knn

Contributing
------------
Issues and PRs are welcome. Follow the repository's CONTRIBUTING guidelines (if present) and ensure tests pass and new behavior is covered by tests.

License
-------
This project is licensed under the GNU General Public License v3.0 (GPL-3.0). See LICENSE in the repository for details.

Maintainers
-----------
- Repository: https://github.com/xorgnak/valkey-objects

References
----------
- README.md in this repository for more examples and the canonical usage snippet.