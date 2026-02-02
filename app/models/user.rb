class User < ApplicationRecord
  enum role: { employee: 0, admin: 1 }
end
