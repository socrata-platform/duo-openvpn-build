# Encoding: UTF-8

if defined?(ChefSpec)
  ChefSpec.define_matcher(:apt_update)

  %i(periodic update).each do |a|
    define_method("#{a}_apt_update") do |name|
      ChefSpec::Matchers::ResourceMatcher.new(:apt_update, a, name)
    end
  end
end
