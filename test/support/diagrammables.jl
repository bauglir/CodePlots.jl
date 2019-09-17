module Diagrammables

module EmptyModule
end

module ModuleWithExportedSubModules
  export SubmoduleOne, SubmoduleTwo

  module SubmoduleOne
  end

  module SubmoduleTwo
  end
end

end
