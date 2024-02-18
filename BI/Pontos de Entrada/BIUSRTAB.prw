User Function BIUSRTAB   

Local aRet   := {}
Local cAlias := PARAMIXB[1] // Alias da tabela Fato / Dimensão que está sendo executada

If cAlias $ 'HLK/HLI/HLD/HLE/HLJ/HLL'
	aRet := {"SED","CTT"}
EndIf

Return aRet