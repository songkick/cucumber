Given /there is (?:one|an?) ([^ ]+)$/ do |entity_type| #"
  Factory(entity_type.underscore.to_sym)
end