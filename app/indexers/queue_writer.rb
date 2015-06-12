class QueueWriter
  def initialize(settings)
    @queue = Queue.new
  end

  attr_reader :queue

  def put(context)
    @queue << context.output_hash
  end
end
