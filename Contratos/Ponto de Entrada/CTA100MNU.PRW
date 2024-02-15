

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ CTA100MNU    บAutor Everton Forti	 บ Data ณ 07/03/2023  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo: Manuten็ใo de Contratos, CAUวีES(CN8)                       นฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
*/

USER FUNCTION CTA100MNU()

	// local aRotina := {}
	
	// aAdd(aRotina, {"Gerar Pagamento Cau็๕es"    , "U_CAUCAO(1)", 0, 6, 0, nil})
	// aAdd(aRotina, {"Estornar Pagamento Cau็๕es" , "U_CAUCAO(2)", 0, 6, 0, nil})
	// aAdd(aRotina, {"Zerar Cau็๕es"              , "U_CAUCAO(3)", 0, 6, 0, nil})

	// Impressใo de dados de medi็๕es
	If Type("aRotina") == "A"
		aAdd(aRotina, {"Impr. Mapa Medi็๕es"          , "U_COCNTR02", 0, 8, 0, nil})
	EndIf
// return(aRotina)
Return

// User Function CAUCAO(nOpcao)

// if nOpcao == 1//Gerar Pagamento Cau็๕es
//     MsgInfo("Teste","Op็ใo 01")
// elseif  nOpcao == 2 //Estornar Pagamento Cau็๕es
//     MsgInfo("Teste","Op็ใo 02")
// elseif nOpcao == 3
//     MsgInfo("Teste","Op็ใo 03")
// endif

    
// RETURN
