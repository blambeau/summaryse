$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'summarize'
require 'yaml'

h1 = YAML.load <<-CFG
hobbies:
  - ruby
  - music
dependencies:
  - {name: rails, version: '3.0',   for: [ runtime ]}
  - {name: rspec, version: '2.6.4', for: [ test ]}
CFG

h2 = YAML.load <<-CFG
hobbies:
  - ruby
  - rails
dependencies:
  - {name: rspec, version: '2.6.4', for: [ runtime ]}
CFG

aggregations = {
  "hobbies" => :union,
  "dependencies" => [ 
    ["name", "version"], 
    { "for" => :union }
  ]
}
puts [h1, h2].summarize(aggregations).to_yaml

