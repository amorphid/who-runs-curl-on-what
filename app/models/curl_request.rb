class CurlRequest < ApplicationRecord
  def increment_count
    self.count += self.count + 1
  end
end
