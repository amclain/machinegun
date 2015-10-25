require 'cuba'
require './output'

Cuba.define do
  on get do
    res.write output
  end
end

run Cuba
