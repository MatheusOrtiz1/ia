/*±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CT20EXCD   ³ Aut.  ³Everton	            ³ Data ³20/04/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exclusão da conta contabil para excluir tambem a CVD        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Módulo: CONASA  			Rotina: CTBA020                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´*/

User Function CT20EXCD()

Local aArea := GetArea()
Local aAreaCVD := CVD->( GetArea() )
Local cSvFilAnt := cFilAnt //Salva a Filial Anterior
Local cSvEmpAnt := cEmpAnt //Salva a Empresa Anterior
Local cSvArqTab := cArqTab //Salva os arquivos de //trabalho
Local cModo //Modo de acesso do arquivo aberto //"E" ou "C"
Local cNewAls := GetNextAlias() //Obtem novo Alias
Local lRet := .F.

	IF EmpOpenFile(cNewAls,"CVD",1,.T.,"07",@cModo)
		//...coloque aqui o seu código
		
		dbSelectArea(cNewAls)
		IF DBSEEK(xFilial()+CT1->CT1_CONTA)
			RecLock(cNewAls, .F.)
			dbDelete()
			MsUnLock()
		ENDIF
		( cNewAls )->( dbCloseArea() )
		
	EndIF
	
	IF EmpOpenFile(cNewAls,"CVD",1,.T.,"27",@cModo)
		//...coloque aqui o seu código
		dbSelectArea(cNewAls)
		IF DBSEEK(xFilial()+CT1->CT1_CONTA)
			RecLock(cNewAls, .F.)
			dbDelete()
			MsUnLock()
		ENDIF
		( cNewAls )->( dbCloseArea() )
	EndIF
	
	//Restaura os Dados de Entrada ( Ambiente )
	cFilAnt := cSvFilAnt
	cEmpAnt := cSvEmpAnt
	cArqTab := cSvArqTab
	
	//Restaura os ponteiros das Tabelas
	RestArea( aAreaCVD )
	RestArea( aArea )
	
	lRet:= .T.
	

Return lRet
