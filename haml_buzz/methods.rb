
def method_missing(name, *args)
  puts "You called #{name}"
  puts args[0]
  if name.to_s =~ /build_reviews/
    method = "build_#{args[0]}_reviews"
    send method.to_sym, "bb"
  elsif name =~ /extract_reviews/
    send "extract_#{args[0]}_reviews".to_sym args
  else
    super
  end
end

def build_bb_reviews(*args)
  puts "You are in build reviews for bb"
  puts "args #{args[0]}"
end

build_reviews("bb")

