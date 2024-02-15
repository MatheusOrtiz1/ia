/*±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MT410TOK   ³ Aut.  ³Everton Forti         ³ Data ³22.10.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao Conta Orçamentaria + Centro de Custo Tabela Z01   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Módulo: Faturamento			Rotina:Pedido de Venda                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´*/

User Function MT410TOK()

Local nPosCcus    := M->C5_UCCUSTO//+"       "
Local nPosClvl    := M->C5_CLVL//+"       "
Local nPosCo	  := M->C5_NATUREZ+"  "
Local nTamNat	  := 12
Local lValido 	  := .F.
Local MVPCOSDCT	  := SUPERGETMV("MV_UCOXCC",.F.,.F.)//Ativa validação tabela Z01 CO X CC
Local MVUCTTCTH	  := SUPERGETMV("MV_UCTTCTH",.F.,.F.)//Ativa validação tabela Z32 CLVL X CC  Adicionado 15/12/2022
Local xEmp1 	  := SuperGetMv("MV_UFILMX",.F.,"")

IF MVPCOSDCT == .F.
	lValido	:= .T.
ELSE
	dbSelectArea('Z01')
	dbSetOrder(1)
	If DBSEEK(xFilial('Z01')+substr(nPosCo,1,nTamNat)+nPosCcus)
		lValido := .T.
	Else
		msgAlert("Esta Conta Orçamentária não pode ser utilizada para este Centro de Custo, verifique relacionamento no acompanhamento orçamentário!","MT410TOK")
		lValido := .F.
		Return(lValido)	
	EndIf
ENDIF

IF MVUCTTCTH == .F.	//Adicionado 15/12/2022
	//lValido	:= .T.
ELSEIF  lValido
	dbSelectArea('Z32')
	dbSetOrder(1)
	If DBSEEK(xFilial('Z32')+nPosCcus+nPosClvl)
		lValido := .T.
	Else
		msgAlert("Esta Clase de Valor não pode ser utilizada para este Centro de Custo, verifique relacionamento no acompanhamento orçamentário!","MT410TOK")
		lValido := .F.
		Return(lValido)
	EndIf
ENDIF

//VALIDAÇÃO EMPRESAS 
IF cNumemp $ xEmp1
    IF !(EMPTY(SC5->C5_UGARANT)) .AND. SC5->C5_UGERGAR <> "1"
        MSGALERT( "SE EXISTE NOMERO ID DE GARANTIA O CAMPO 'GARANTIA' DEVERA ESTAR PREENCHIDO", "MT410TOK - INCONSISTENCIA NOS DADOS DA GARANTIA!" )
		lValido := .F.
    ENDIF
ENDIF

Return(lValido) 
