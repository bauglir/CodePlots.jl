using CodePlots
using CodePlots: MemberMap, MemberMapConfig, PlantUML, render

PlantUML(MemberMap(CodePlots, MemberMapConfig( ; exportedOnly = false)))
