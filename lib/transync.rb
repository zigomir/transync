require_relative 'transync/sync/translation_sync'
require_relative 'transync/sync/init'
require_relative 'transync/sync/sync_util'
require_relative 'transync/runner'

module Transync

  def self.run(mode)
    if mode == 'x2g' or mode == 'g2x'
      Transync::Runner.sync(mode)
    end

    if mode == 'init'
      Transync::Runner.init
    end

    if mode == 'test'
      Transync::Runner.test
    end

    if mode == 'update'
      Transync::Runner.update
    end
  end

end
