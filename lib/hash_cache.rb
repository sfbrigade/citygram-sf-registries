class HashCache
  attr_reader :cache

  def initialize
    @cache = {}
  end

  def fetch(key, &payload)
    return @cache[key] if @cache.has_key? key

    result = yield payload

    unless result.nil?
      @cache[key] = result
    end
  end
end
