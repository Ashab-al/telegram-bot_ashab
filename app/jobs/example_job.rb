class ExampleJob < ApplicationJob
  queue_as :default

  def perform
    # Simulates a long, time-consuming task
    # Will display current time, milliseconds included
    p "hello from ExampleJob #{Time.now().strftime('%F - %H:%M:%S.%L')}"
  end

end