def set_mysqld_password(resource_name) # rubocop:disable all
  ChefSpec::Matchers::ResourceMatcher.new(:mysqld_password, :set, resource_name)
end
