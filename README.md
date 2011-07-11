# Array#summaryse

    [sudo] gem install summaryse

## Links

* {http://rubydoc.info/github/blambeau/summaryse/master/frames} (read this file there!)
* {http://github.com/blambeau/summaryse} (source code)

## Summaryse's summary

Summaryse provides a core extension, namely Array#summaryse. Oh, sorry, I must 
add: "OMG, a core extension :-/". If you are aware of any compatibility issue, 
let me know!

So, what is Array#summaryse? Roughly, a way to aggregate values, including 
complex values like **arrays of hashes that contain hashes and array of hashes 
that...** A (complex) YAML configuration file typically yields such value. We 
start with such opinionated example first. 

## An opinionated example -- YAML merging

In many projects of mine including 
{https://github.com/blambeau/noe noe}, 
{https://github.com/blambeau/agora agora} or 
{https://github.com/blambeau/dbagile dbagile}, there is this need of being able 
to merge YAML files. Merging YAML files is complex because you need full control 
of how merging applies on specific tree nodes. Summaryse solves this.

    # This is left.yaml
    left = YAML.load ...      # syntactically wrong, but to avoid Yard's rewriting
      hobbies:
        - ruby
        - rails
      dependencies:
        - {name: rspec, version: '2.6.4', for: [ runtime ]}
    ...

    # This is right.yaml
    right = YAML.load ...
      hobbies:
        - ruby
        - music
      dependencies:
        - {name: rails, version: '3.0',   for: [ runtime ]}
        - {name: rspec, version: '2.6.4', for: [ test    ]}
    ...

    # This is merge.yaml
    merge = YAML.load ...
      hobbies: 
        :union
      dependencies: 
        - [name, version]
        - for: :union
    ...
    
    # Merge and re-dump
    [ left, right ].summaryse(merge).to_yaml
    
    # This is the (pretty-printed) result 
    hobbies:
      - ruby
      - rails
      - music
    dependencies:
      - {name: rspec, version: '2.6.4', for: [ runtime, test ]}
      - {name: rails, version: '3.0',   for: [ runtime       ]}

Below are examples of increasing usefulness and complexity.

## On simple values (integers, floats, ...)

Summarizing an array of simple values yields -> a simple value...

### Arithmetics & Algebra

    # :count, same as #size
    [1, 4, 12, 7].summaryse(:count) # => 4

    # :sum, same as #inject(:+)
    [1, 4, 12, 7].summaryse(:sum)   # => 24

    # :avg, same as #inject(:+)/size
    [1, 4, 12, 7].summaryse(:avg)   # => 6.0

Looks trivial? Don't stop here ;-)

### Array theory

    # :min, same as #min
    [1, 4, 12, 7].summaryse(:min)   # => 1

    # :max, same as #max
    [1, 4, 12, 7].summaryse(:max)   # => 12

    # :first, same as #first
    [1, 4, 12, 7].summaryse(:first) # => 1

    # :last, same as #last
    [1, 4, 12, 7].summaryse(:last)  # => 7

### Set theory

    # :union, same as #inject(:|)
    [ [1, 4], [12, 1, 7], [1] ].summaryse(:union)        # => [1, 4, 12, 7]

    # :intersection, same as #inject(:&)
    [ [1, 4], [12, 1, 7], [1] ].summaryse(:intersection) # => [1]

## On Hash-es

Summarizing an Array of Hash-es yields -> a Hash.

Previous section provided the base cases. You can use them on elements of hashes
by passing a ... Hash of course:

    [
      { :hobbies => [:ruby],  :size => 12 },
      { :hobbies => [:music], :size => 17 }
    ].summaryse(:hobbies => :union, :size => :max)   
    # => {:hobbies => [:ruby, :music], :size => 17}

And it works recursively, of course:

    [ 
      { :hobbies => {:day => [:ruby], :night => [:ruby] } },
      { :hobbies => {:day => [],      :night => [:sleep]} }
    ].summaryse(:hobbies => {:day => :union, :night => :union})
    # => {:hobbies => {:day => [:ruby], :night => [:ruby, :sleep]}}

### Specifying default behavior

By default, the returned hash only contains elements for which you have provided
a summarization heuristic. However, you can use a nil key to specify the default
behavior to use on others:

    [
      { :hobbies => [:ruby],  :size => 12 },
      { :hobbies => [:music], :size => 17 }
    ].summaryse(:hobbies => :union, nil => :first)
    # => {:hobbies => [:ruby, :music], :size => 12}

### Specifying with lambdas

When no default summarization function fit your needs, just pass a lambda. It 
will be called with the array of values on which aggregation must be done:

    [
      { :hobbies => [:ruby],  :size => 12 },
      { :hobbies => [:music], :size => 17 }
    ].summaryse(:hobbies => :union, :size => lambda{|a|
      a.join(', ')
    })
    # => {:hobbies => [:ruby, :music], :size => "12, 17"}

## On Arrays of Hash-es

Summarizing an Array of Array-s of Hash-es yields -> an Array of Hash-es

There is a subtelty here, as you have to specify the "by key", that is, what
hash elements form the summarization grouping terms.

    [ 
      [ { :name => :yard,      :for => [ :devel   ] },
        { :name => :summaryse, :for => [ :runtime ] } ],
      [ { :name => :summaryse, :for => [ :devel   ] }, 
        { :name => :treetop,   :for => [ :runtime ] } ]
    ].summaryse([ [:name], {:for => :union} ])
    # => [ {:name => :yard,      :for => [:devel]           },
    #      {:name => :summaryse, :for => [:devel, :runtime] },
    #      {:name => :treetop,   :for => [:runtime]         } ]

A quick remark: when merging arrays of hashes, #summaryse guarantees that the 
returned hashes are in order of encountered 'by key' values. That is, in the 
example above, yard comes before summaryse that comes before treetop because 
this is the order in which they have been seen initially.

# By the way, why this stupid name?

Just because summarize was already an {https://rubygems.org/gems/summarize existing gem}. 
Summaryse is also much less likely to cause a name clash on the Array class. And
I'm a french-speaking developer :-)

And why summarize, then? Because this is much inspired by (yet not equivalent to) 
{http://en.wikipedia.org/wiki/D_(data_language_specification)#Tutorial_D TUTORIAL D}'s 
summarization operator on relations. See my {https://github.com/blambeau/alf alf} 
project.

# Contribute, Versioning and so on.

As usual: the code is on {http://github.com/blambeau/summaryse github}, I follow
{http://semver.org/ semantic versioning} (the public API is almost everything but 
implementation details, that is, the method name, its recognized arguments and 
the semantics of the returned value), etc.

Now, frankly, you can also copy/paste the source code of this simple array 
extension in your own project. This tend to be much friendly and much simpler 
than using a gem, IMHO. Reuse by copy-pasting even has a name:
{http://revision-zero.org/reuse code scavenging}. 
 
