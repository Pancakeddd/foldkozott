setmetatable {}, {
  __call: (args) =>
    for _, v in pairs args
      require "data.#{v}"
    
}