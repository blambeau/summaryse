$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'summaryse'
require 'yaml'

# This is left.yaml
left = YAML.load <<-Y
  hobbies:
    - ruby
    - rails
  dependencies:
    - {name: rspec, version: '2.6.4', for: [ runtime ]}
Y

# This is right.yaml
right = YAML.load <<-Y
  hobbies:
    - ruby
    - music
  dependencies:
    - {name: rails, version: '3.0',   for: [ runtime ]}
    - {name: rspec, version: '2.6.4', for: [ test    ]}
Y

# This is merge.yaml
merge = YAML.load <<-M
  hobbies: 
    :union
  dependencies: 
    - [name, version]
    - for: :union
M

puts [ left, right ].summaryse(merge).to_yaml
