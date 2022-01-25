# Hinter

![hinter.png](/assets/hinter.png)

Console utility to help developers figure out why a block of code is slow:

* Show ruby usage
* Show active record usage

# Usage

## Installation

```ruby
gem "hinter", git: "https://github.com/Oxyless/hinter.git"
```

## Basic usage

### From code

```ruby
result = Hinter.new.watch(binding) do
	Log.count
	puts 42
	Brand.all.map(&:name)
	a = 45
end
```

### From rails console

Because ```block.source```is not available from console, so you have to comment evalued code.

```ruby
result = Hinter.new.watch(binding, source:
<<~RUBY
	Log.count
	puts 42
	Brand.all.map(&:name)
	a = 45
RUBY
)
```

### Result

![ruby_sql](/assets/ruby_sql_2.png)

### Expand SQL

```ruby
result.expand(12) # sql analysis of #12
```

![expand_12](/assets/expand_12.png)

### Display slow lines

```ruby
result.slow(1) # display lines > 1s
```

![slow](/assets/slow.png)


## Active record analysis

### Basic usage

```ruby
# sql only
result = Hinter.watch do
  # some_code
end
```

![example](/assets/example.png)

### Display top queries

```ruby
result.queries # get queries sort by time
result.top_query # display slow query
result.top_queries(42) # display n slow queries
```

![top_query](/assets/top_query.png)

### Expand callstack

```ruby
result.expand(114) # callstack of #114
```

![expand_callstack](/assets/expand_callstack.png)


## Options

### Usage

```ruby
result = Hinter.new(
	file_pattern: nil,
	warning_time: 1,
	critical_time: 5,
	warning_sql_call: 10,
	critical_sql_call: 100,
	round_time: 2,
	colors: true,
	watch_dir: /\/app\//,
	ignored: /(\/gems\/|\(pry\)|bin\/rails|hinter)/
).watch do
  # some_code
end
```
### Options list

- **"file_pattern"** file_pattern to\_watch as string
- **"warning_time"** max query time seconds before warning color
- **"critical_time"** max query time seconds before critical color
- **"warning_sql_call"** max same query call before warning color
- **"critical_sql_call"** max same query call before warning color
- **"round_time"** number of digit for time
- **"colors"** enable colors 
- **"watch_dir"** path watched
- **"ignored"** path ignored


# Compatibility

Rails 3, 4, 5, 6

# License

[http://opensource.org/licenses/MIT](http://opensource.org/licenses/MIT)