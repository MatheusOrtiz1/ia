User Function BIEXTGRV

Local cAlias   := PARAMIXB[1] // Alias da Fato ou Dimensão em gravação no momento
Local aRet     := PARAMIXB[2] // Array contendo os dados do registro para manipulação
Local lIsDim   := PARAMIXB[3] // Variável que indica quando está gravando em uma Dimensão (.T.) ou Fato (.F.)

//Local nPLivre0 := aScan(aRet, {|x| AllTrim(x[1]) == cAlias + "_LIVRE0"})
//Local nPLivre1 := aScan(aRet, {|x| AllTrim(x[1]) == cAlias + "_LIVRE1"})
//Local nPLivre2 := aScan(aRet, {|x| AllTrim(x[1]) == cAlias + "_LIVRE2"})
//Local nPLivre3 := aScan(aRet, {|x| AllTrim(x[1]) == cAlias + "_LIVRE3"})
//Local nPLivre4 := aScan(aRet, {|x| AllTrim(x[1]) == cAlias + "_LIVRE4"})
//Local nPLivre5 := aScan(aRet, {|x| AllTrim(x[1]) == cAlias + "_LIVRE5"})
//Local nPLivre6 := aScan(aRet, {|x| AllTrim(x[1]) == cAlias + "_LIVRE6"})
Local nPLivre7 := aScan(aRet, {|x| AllTrim(x[1]) == cAlias + "_LIVRE7"})
Local nPLivre8 := aScan(aRet, {|x| AllTrim(x[1]) == cAlias + "_LIVRE8"})
//Local nPLivre9 := aScan(aRet, {|x| AllTrim(x[1]) == cAlias + "_LIVRE9"})
//Local nPVRLMes := aScan(aRet, {|x| AllTrim(x[1]) == cAlias + "_VRLMES"})
//Local nPIndica := aScan(aRet, {|x| AllTrim(x[1]) == cAlias + "_INDICA"})

/*
If lIsDim 
	aRet[nPLivre0][2] := "Teste Livre Dimensão" 
	aRet[nPLivre1][2] := "Teste Livre Dimensão"
	aRet[nPLivre2][2] := "Teste Livre Dimensão"
	aRet[nPLivre3][2] := "Teste Livre Dimensão"
	aRet[nPLivre4][2] := "Teste Livre Dimensão"
	aRet[nPLivre5][2] := "Teste Livre Dimensão"
	aRet[nPLivre6][2] := "Teste Livre Dimensão"
	aRet[nPLivre7][2] := "Teste Livre Dimensão"
	aRet[nPLivre8][2] := "Teste Livre Dimensão"
	aRet[nPLivre9][2] := "Teste Livre Dimensão"
ElseIf cAlias == 'HLA' .And. (aRet[nPIndica][2] == '00000025' .Or. aRet[nPIndica][2] == '00000027' .Or. aRet[nPIndica][2] == '00000029')
	aRet[nPVRLMes][2] := 999
Else	
	aRet[nPLivre0][2] := 10
	aRet[nPLivre1][2] := 20
	aRet[nPLivre2][2] := 30
	aRet[nPLivre3][2] := 40
	aRet[nPLivre4][2] := 50
	aRet[nPLivre5][2] := Date()
	aRet[nPLivre6][2] := Date()
	aRet[nPLivre7][2] := Date()
	aRet[nPLivre8][2] := "Teste Livre Fato"
	aRet[nPLivre9][2] := "Teste Livre Fato"
EndIf
*/

if cAlias $ 'HLK/HLI/HLD' .and. !lIsDim
	aRet[nPLivre7][2] := "'"+SE2->E2_TIPO+"'"
	aRet[nPLivre8][2] := POSICIONE("CTT",1,XFILIAL("CTT")+SE2->E2_CCUSTO,"CTT_DESC01")
elseif cAlias $ 'HLE/HLJ/HLL' .and. !lIsDim
	aRet[nPLivre7][2] := "'"+SE1->E1_TIPO+"'"
	aRet[nPLivre8][2] := POSICIONE("CTT",1,XFILIAL("CTT")+SE1->E1_CCUSTO,"CTT_DESC01")
endif

Return aRet
