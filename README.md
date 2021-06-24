# hinter

Hinter aims to help developers to figure why some block of code is slow, from a rails console.
For now it handle sql query analysis and show you where your queries are slow, or too many.

# How to use it

## Basic usage

```ruby
result = Hinter.watch do
	# some_code
end
```

![example](/assets/example.png)

```ruby
result.queries
result.top_query
result.top_queries(42)
```

![top_query](/assets/top_query.png)

## Advanced usage

```ruby
result = Hinter.new(
  file_pattern: my_file_pattern,
  watch_dir: /\/app\//,
  warning_time: 1,
  critical_time: 5,
).watch do
  # some_code
end

result = Hinter.watch(my_file_pattern) do
	# some_code
end
```

- **"file_pattern"** file_pattern to_watch
- **"watch_dir"** dir watched
- **"warning_time"** max query time seconds before warning color
- **"critical_time"** max query time seconds before critical color
