module ApplicationHelper
  # prefix is generally api_key's token_prefix e.g. "tkn_usr_1zZe1R"
  # generated value is "tkn_usr_1zZe1R••••••••••••••••••••••••••••••••"
  def token_mask(prefix, length = 30)
    "#{prefix}#{'•' * length}"
  end
end
