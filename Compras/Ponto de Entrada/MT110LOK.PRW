/*±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MT110LOK   ³ Aut.  ³Everton Forti         ³ Data ³22.10.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao Conta Orçamentaria + Centro de Custo Tabela Z01   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Módulo: Compras   			Rotina:Solicitação de Compraas            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´*/

User Function MT110LOK()

Local nPosCcus    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CC'})
Local nPosClvl   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CLVL'})
Local nPosCo	  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CO'})
Local lValido 	  := .F.
Local MVPCOSDCT	  := SUPERGETMV("MV_UCOXCC",.F.,.F.)//Ativa validação tabela Z01 CO X CC
Local MVUCTTCTH	  := SUPERGETMV("MV_UCTTCTH",.F.,.F.)//Ativa validação tabela Z32 CLVL X CC  Adicionado 15/12/2022

IF MVPCOSDCT == .F.
	lValido	:= .T.
ELSE
	
	dbSelectArea('Z01')
	dbSetOrder(1)
	If dbseek(xFilial('Z01')+aCols[n][nPosCo]+aCols[n][nPosCcus])
		lValido := .T.
	Else
		msgAlert("Esta Conta Orçamentária não pode ser utilizada para este Centro de Custo, verifique relacionamento no acompanhamento orçamentário!","MT110LOK")
		lValido := .F.
		Return(lValido)
	EndIf
ENDIF

IF MVUCTTCTH == .F. //Adicionado 15/12/2022
	//lValido	:= .T.
ELSEif lValido
	
	dbSelectArea('Z32')
	dbSetOrder(1)
	If dbseek(xFilial('Z32')+aCols[n][nPosCcus]+aCols[n][nPosClvl])
		lValido := .T.
	Else
		msgAlert("Esta Classe de Valor não pode ser utilizada para este Centro de Custo, verifique relacionamento no acompanhamento orçamentário!","MT110LOK")
		lValido := .F.
		Return(lValido)
	EndIf
ENDIF

Return(lValido) 
