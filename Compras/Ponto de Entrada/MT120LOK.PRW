/*�����������������������������������������������������������������������Ŀ��
���Funcao    �MT120LOK   � Aut.  �Everton Forti         � Data �22.10.2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao Conta Or�amentaria + Centro de Custo Tabela Z01   ���
�������������������������������������������������������������������������Ĵ��
���M�dulo: Compras   			Rotina:Pedido de Compras 	              ���
�������������������������������������������������������������������������Ĵ*/

User Function MT120LOK()

Local nPosCcus    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_CC'})
Local nPosClvl    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_CLVL'})
Local nPosCo	  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_CO'})
Local nPospro	  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'})
Local nPosdIAS
Local nPosStat	  
Local lValido 	  := .F.
Local MVPCOSDCT	  := SUPERGETMV("MV_UCOXCC",.F.,.F.)//Ativa valida��o tabela Z01 CO X CC
Local MVUCTTCTH	  := SUPERGETMV("MV_UCTTCTH",.F.,.F.)//Ativa valida��o tabela Z32 CLVL X CC  Adicionado 15/12/2022
Local cTemTAg
Local xEmp1 := SuperGetMv("MV_UFILMX",.F.,"")
Local lRetCpo := .T.

IF MVPCOSDCT == .F.
	lValido	:= .T.
ELSE
	
	dbSelectArea('Z01')
	dbSetOrder(1)
	If dbseek(xFilial('Z01')+aCols[n][nPosCo]+aCols[n][nPosCcus])
		lValido := .T.
	Else
		msgAlert("Esta Conta Or�ament�ria n�o pode ser utilizada para este Centro de Custo, verifique relacionamento no acompanhamento or�ament�rio!","MT120LOK")
		lValido := .F.
		Return(lValido)
	EndIf
ENDIF

IF MVUCTTCTH == .F.	//Adicionado 15/12/2022
	//NAO FAZ NADA
ELSEIF  lValido
	
	dbSelectArea('Z32')
	dbSetOrder(1)
	If dbseek(xFilial('Z32')+aCols[n][nPosCcus]+aCols[n][nPosClvl])
		lValido := .T.
	Else
		msgAlert("Esta Classe de Valor n�o pode ser utilizada para este Centro de Custo, verifique relacionamento no acompanhamento or�ament�rio!","MT120LOK")
		lValido := .F.
		Return(lValido)
	EndIf
ENDIF



IF cNumemp $ xEmp1

	cTemTAg := POSICIONE("SB1",1,xFilial("SB1")+aCols[n][nPospro],"B1_UGERTAG")

	nPosdIAS	  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_UDIASGA'})
	nPosStat	  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_USTATUS'})

	if nPosdIAS <= 0
		ALERT("Campo C7_UDIASGA Inexistente na base de dados!")
		lValido := .F.
		Return(lValido)
	ENDIF

	if nPosStat <= 0 
		ALERT("Campo C7_USTATUS Inexistente na base de dados!")
		lValido := .F.
	ENDIF

	IF lRetCpo
		IF cTemTAg =="S" .AND. aCols[n][nPosStat] =="N" .AND. EMPTY(aCols[n][nPosdIAS]) 
			ALERT("Necess�rio informar quantidade de Dias de Garantia para produtos que controlam TAG!")
		ENDIF
	ENDIF


ENDIF


Return(lValido)
