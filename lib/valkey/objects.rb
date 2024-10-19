# frozen_string_literal: true

require_relative "objects/version"

require 'redis-client'
require 'json'
require 'ruby-duration'

module VK
  def self.included(x)
    x.extend VK
  end

  def self.extended(x)
    xx = x.name.gsub("::", "-")
    define_method(:value) { |k| define_method(k.to_sym) { V.new(%[#{xx}:value:#{k}:#{@id}]) } };
    define_method(:counter) { |k| define_method(k.to_sym) { C.new(%[#{xx}:counter:#{k}:#{@id}]); } };
    define_method(:hashkey) { |k| define_method(k.to_sym) { H.new(%[#{xx}:hash:#{k}:#{@id}]); } };
    define_method(:sortedset) { |k| define_method(k.to_sym) { S.new(%[#{xx}:sortedset:#{k}:#{@id}]); } };
    define_method(:set) { |k| define_method(k.to_sym) { G.new(%[#{xx}:set:#{k}:#{@id}]); } };
    define_method(:queue) { |k| define_method(k.to_sym) { Q.new(%[#{xx}:queue:#{k}:#{@id}]); } };
    define_method(:place) { |k| define_method(k.to_sym) { P.new(%[#{xx}:place:#{k}:#{@id}]); } };
    define_method(:pipe) { |k| define_method(k.to_sym) { B.new(%[#{xx}:pipe:#{k}:#{@id}]); } };
    define_method(:toggle) { |k| define_method(k.to_sym) { T.new(%[#{xx}:toggle:#{k}:#{@id}]); } };
  end

  def id
    @id
  end

  module AGO
    class Error < StandardError; end
    class Clock
      def initialize t
        @t = AGO.now
        @s = @t.to_i - t.to_i
        @t = Time.new(t.to_i).utc
        @d = Duration.new(@s.abs)
      end
      def to_i
        @s
      end
      def to_s *s
        if s[0]
          @d.format(s[0])
        else
          @d.format('%w %~w %d %~d %H:%M:%S')
        end
      end
    end
    def self.now
      Time.now.utc
    end
    def self.[] k
      Clock.new(k)
    end
  end
  
  def self.clock *t
    if t[0]
      AGO[t[0]]
    else
      AGO.now
    end
  end
  
  def self.redis
    RedisClient.config(host: "127.0.0.1", port: 6379, db: 0).new_client
  end
  
  class O
    attr_reader :key
    def initialize k
      @key = k
    end
  end

  class T < O
    def value
      VK.redis.call("GET", key) == 'true' ? true : false  
    end
    def value= x
       VK.redis.call("SET", key, "#{x.to_s}")
    end
    def value!
      if self.value
        self.value = false
      else
        self.value = true
      end
    end
  end
  
  class B < O
    def on &b
      pubsub = VK.redis.pubsub
      pubsub.call("SUBSCRIBE", key)
      Process.detach( fork do
                        loop do
                          if m = pubsub.next_event(0)
                            cn, ty, na, id = key.split(":")
                            if m[0] == "message"
                              b.call({ stub: na, object: cn.gsub("-", "::"), type: ty, id: id, event: m[0], data: JSON.parse(m[2]) })
                            else
                              ap({ stub: na, object: cn.gsub("-", "::"), type: ty, id: id, event: m[0], data: m[2] })
                            end
                          end
                        end
                      end
                    );
    end
    def << x
      if x.class == String
        VK.redis.call("PUBLISH", key, JSON.generate({ input: x }))
      elsif x.class == Array
        VK.redis.call("PUBLISH", key, JSON.generate({ inputs: x }))
      elsif x.class == Hash
        VK.redis.call("PUBLISH", key, JSON.generate(x))
      end
    end
  end
  
  class V < O
    def value
      VK.redis.call("GET", key)
    end
    def value= x
      VK.redis.call("SET", key, x)
    end
  end
  
  class C < O
    def incr n
      VK.redis.call("SET", key, value + n.to_f)
    end
    def decr n
      VK.redis.call("SET", key, value + n.to_f)
    end    
    def value
      VK.redis.call("GET", key).to_f
    end
    def value= n
      VK.redis.call("SET", key, n.to_f)
    end
  end
  
  class H < O
    def [] k
      VK.redis.call("HGET", key, k);
    end
    def []= k,v
      VK.redis.call("HMSET", key, k, v);
    end
  end
  
  class Q < O
    def value &b
      VK.redis.call("LRANGE", key, 0, -1, 'WITHSCORES').each_with_index { |e, i| b.call(i, e) }
    end
    def length
      VK.redis.call("LLEN", key)
    end      
    def << i
      VK.redis.call("RPUSH", key, i)
    end
    def front
      VK.redis.call("LPOP", key)
    end
  end
  
  class S < O
    def value &b
      VK.redis.call("ZREVRANGE", key, 0, -1, 'WITHSCORES').each_with_index { |e, i| b.call(i, e) }
    end
    def [] k
      VK.redis.call("ZSCORE", key, k).to_f;
    end
    def []= k,v
      VK.redis.call("ZADD", key, v, k).to_f;
    end      
    def poke k, n
      VK.redis.call("ZINCRBY", key, n.to_f, k);
    end
  end

  class G < O
    def value &b
      VK.redis.call("SMEMBERS", key).each_with_index { |e, i| b.call(i, e) }
    end
    def length
      VK.redis.call("SCARD", key)
    end
    def << i
      VK.redis.call("SADD", key, i)
    end
    def rm i
      VK.redis.call("SREM", key, i)
    end      
    def & k
      VK.redis.call("SINTER", key, k.key)
    end
    def | k
      VK.redis.call("SUNION", key, k.key)
    end      
    def [] k
      r, h = Regexp.new(k), {}
      VK.redis.call("SMEMBERS", key).each { |e| if m = r.match(e); h[e] = m; end; }
      return h
    end
  end
  
  class P < O
    def value &b
      VK.redis.call("ZRANGE", key, 0, -1).each_with_index { |e, i| b.call(i, e) };
    end
    def add i, lon, lat
      VK.redis.call("GEOADD", key, lon, lat, i)
    end
    def [] i
      x = VK.redis.call("GEOPOS", key, i)[0];
      return { longitude: x[0], latitude: x[1] }
    end
    def distance a, b
      VK.redis.call("GEODIST", key, a, b, 'm').to_f;
    end
    def radius lon, lat, r
      h = {}
      VK.redis.call("GEORADIUS", key, lon, lat, r, 'm', 'WITHDIST').each { |e| h[e[0]] = e[1].to_f };
      return h
    end
  end
  def self.flushdb!
    VK.redis.call("FLUSHDB")
  end
  def self.[] k
    VK.redis.call("KEYS", k)
  end
end




