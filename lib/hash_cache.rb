class HashCache

  def initialize
    @cache = {}
  end

  def fetch(key, &payload)
    return @cache[key] if @cache.has_key? key

    @cache[key] = yield payload
  end
end