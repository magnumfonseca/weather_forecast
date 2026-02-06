class Response
  attr_reader :data, :errors, :meta

  def initialize(success:, data: nil, errors: [], meta: {})
    @success = success
    @data = data
    @errors = errors
    @meta = meta
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  def self.success(data:, meta: {})
    new(success: true, data: data, meta: meta)
  end

  def self.failure(errors:, meta: {})
    new(success: false, errors: Array(errors), meta: meta)
  end
end
