module Diagrammables

module EmptyModule
end

module ModuleWithExportedFunction
  export exportedFunction

  function exportedFunction()
  end
end

module ModuleWithExportedSubModules
  export SubmoduleOne, SubmoduleTwo

  module SubmoduleOne
  end

  module SubmoduleTwo
  end
end

end
