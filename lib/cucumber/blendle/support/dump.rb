require 'json'

After do |scenario|
  next unless scenario.failed? && ENV['AUTO_DUMP'] != 'false'

  ENV['DUMP'] = 'true'
  dump(last_response.body)
end

# Dump a string/text to the clipboard or a file if the correct
# environment variable is set.
#
# Example:
#  $ bundle exec cucumber DUMP=cb
#
def dump(data)
  return unless ENV['DUMP']

  require 'mkmf'

  if %w(file tmp).include?(ENV['DUMP'])
    File.open('/tmp/dump', 'w') { |f| f << pretty_sorted_json(data) }
  elsif ENV['DUMP'] && find_executable0('pbcopy')
    IO.popen(['pbcopy'], 'w') { |f| f << pretty_sorted_json(data) }
  end
end

def pretty_sorted_json(data)
  hash = JSON.parse(data)
  hash = prettify_hash(hash)

  JSON.pretty_generate(hash)
rescue
  data
end

def prettify_hash(hash)
  hash.each do |k, v|
    if v.is_a?(Array)
      hash[k] = v.map { |a| a.is_a?(Hash) ? prettify_hash(a) : a }
    elsif v.is_a?(Hash)
      hash[k] = prettify_hash(v)
    end
  end

  hash = unshift_hash_key('_embedded', hash)
  hash = unshift_hash_key('_links', hash)
  hash['_links'] = unshift_hash_key('health', hash['_links']) if hash['_links']
  hash['_links'] = unshift_hash_key('api', hash['_links']) if hash['_links']
  hash['_links'] = unshift_hash_key('self', hash['_links']) if hash['_links']

  hash.sort.to_h
end

def unshift_hash_key(key, hash)
  return hash unless hash[key]

  data = hash.delete(key)
  { key => data }.merge(hash)
end
