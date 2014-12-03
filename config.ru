require File.expand_path("../app", __FILE__)

$stdout.sync = true

use Rack::Logger
run Spreebot.new