watir_rails_variables = %w[app localhost host ignore_exceptions middleware port server server_thread].freeze

def server_thread
  Watir::Rails.instance_variable_get(:@server_thread)
end

RSpec.configure do |c|
  c.before do
    watir_rails_variables.each do |variable|
      Watir::Rails.instance_variable_set("@#{variable}", nil)
    end
  end

  c.after do
    if server_thread && server_thread.alive?
      # Windows can't kill stopped thread apparently
      server_thread.wakeup if server_thread.stop?
      server_thread.kill
      server_thread.join
    end
  end
end
