# Hinter

Hinter aims to help developers to figure why some block of code is slow, from a rails console. 
For now it handle sql query analysis and show you where your queries are slow, or too many.

# How to use it

## SQL Only

```ruby
# sql only
result = Hinter.watch do
  # some_code
end
```

![example](/assets/example.png)

```ruby
result.queries # get queries sort by time
result.top_query # display slow query
result.top_queries(42) # display n slow queries
```

![top_query](/assets/top_query.png)

```ruby
result.expand(114) # callstack of #114
```

![expand_callstack](/assets/expand_callstack)


## Ruby + SQL

```ruby
# does not work in console because block.source not avaialable
result = Hinter.new.watch(binding) do
	# some_code
end

# works in console
result = Hinter.new.watch(binding, source:
	<<~RUBY
		# some_code
	RUBY
)
```

![ruby_sql](/assets/ruby_sql.png)

```ruby
result.expand(12) # sql analysis of #12
```

![expand_12](/assets/expand_12.png)

```ruby
result.slow(1) # display lines > 1s
```

![slow](/assets/slow.png)


## Options

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