#include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
 
/*±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MT100LOK   ³ Aut.  ³Everton Forti         ³ Data ³22.10.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao Conta Orçamentaria + Centro de Custo Tabela Z01   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Módulo: Compras   			Rotina:Documento de Entrada               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´*/

User Function MT100LOK()

Local nPosCcus    := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_CC'})
Local nPosClvl    := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_CLVL'})
Local nPosCo	  := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_CO'})
Local nPosTes	  := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_TES'})
Local nPoscod	  := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_COD'})
Local nPosiss     := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_VALISS'})
Local nPosciss    := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_CODISS'})
Local nPosQtda    := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_QUANT'})
Local nPosNumPC   := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_PEDIDO'})
Local nPosItPC    := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_ITEMPC'})
Local nValiss	  := ""
Local cCodiss	  := ""
Local CQUERY01	  := ""
Local lQtDPCD1	  := SUPERGETMV("MV_UQTPCD1",.F.,.F.)//PARAMETRO PARA HABILITAR VALIDAÇÃO DE QUANTIDADE A MAIOR QUE O PEDIDO DE COMPRAS

Local cGarant	  	
Local cIDGar	  
Local lExecuta 	  := ParamIxb[1]// .T.
Local MVPCOSDCT	  := SUPERGETMV("MV_UCOXCC",.F.,.F.)//Ativa validação tabela Z01 CO X CC 
Local MVUCTTCTH	  := SUPERGETMV("MV_UCTTCTH",.F.,.F.)//Ativa validação tabela Z32 CLVL X CC  Adicionado 15/12/2022
Local Tipo		  := cTipo //Tipo da nota fiscal
local xEmp1
Local cTemTAg

// Ponto de chamada ConexãoNF-e sempre como primeira instrução
	lExecuta := U_GTPE004()

// Restrição para validações não serem chamadas duas vezes ao utilizar o importador da ConexãoNF-e, 
	// mantendo a chamada apenas no final do processo, quando a variável l103Auto estiver .F.
If lExecuta .And. !FwIsInCallStack('U_GATI001') .Or. IIf(Type('l103Auto') == 'U',.T.,!l103Auto)
	if lQtDPCD1 .and. !EMPTY(aCols[n][nPosNumPC])

		//SELECT C7_QUANT FROM SC7230 SC7 WHERE C7_NUM ='016830' AND C7_ITEM = '0001'
		CQUERY01 := " SELECT C7_QUANT"
		CQUERY01 += " FROM "+RETSQLNAME("SC7")+" SC7 "
		CQUERY01 += " WHERE  C7_NUM = '"+aCols[n][nPosNumPC]+"' AND  C7_ITEM = '"+aCols[n][nPosItPC]+"' AND SC7.D_E_L_E_T_='' " //DAND Z23_COD='"+xPar07+"' "
		
		IF SELECT("TRB03")!=0
			TRB03->(DBCLOSEAREA())
		ENDIF
		TCQUERY CQUERY01 NEW ALIAS "TRB03" 
		DBSELECTAREA("TRB03")
		DBGOTOP()
		If TRB03->(!eof())
			IF aCols[n][nPosQtda] > TRB03->C7_QUANT
				MSGALERT( "MT100LOK - Não é possivel alterar a quantidade do item, favor rever o pedido de compras!", "ATENÇÃO - Quantidade maior que o pedido de compra!" )
			ENDIF
		ENDIF
	ENDIF

	IF Tipo="N"
		IF MVPCOSDCT == .F.
			lExecuta	:= .T.
		ELSE
			dbSelectArea('Z01')
			dbSetOrder(1)
			If dbseek(xFilial('Z01')+aCols[n][nPosCo]+aCols[n][nPosCcus])
				lExecuta := .T.
			Else
				msgAlert("Esta Conta Orçamentária não pode ser utilizada para este Centro de Custo, verifique relacionamento no acompanhamento orçamentário!","MT100LOK")
				lExecuta := .F.
				Return(lExecuta)
			EndIf
		ENDIF

		IF MVUCTTCTH == .F.//Adicionado 15/12/2022
			//lExecuta	:= .T.
		ELSEIF lExecuta
			dbSelectArea('Z32')
			dbSetOrder(1)
			If dbseek(xFilial('Z32')+aCols[n][nPosCcus]+aCols[n][nPosClvl])
				lExecuta := .T.
			Else
				msgAlert("Esta Classe de Valor não pode ser utilizada para este Centro de Custo, verifique relacionamento no acompanhamento orçamentário!","MT100LOK")
				lExecuta := .F.
				Return(lExecuta)
			EndIf
		ENDIF

	ENDIF
	/*ÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄ
	ÄÄÄÄÄGRAVA CONTROLE DE GARANTIA TABELA Z22 - INTEGMAX															           ÄÄÄÄÄ
	ÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄ*/
	xEmp1 := SuperGetMv("MV_UFILMX",.F.,"")

	IF cNumemp $ xEmp1 

		cGarant	  := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_USTATUS'})	
		cIDGar	  := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_UIDGARA'})
		cDiasga	  := aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_UDIASGA'})	

		cTemTAg := POSICIONE("SB1",1,xFilial("SB1")+aCols[n][nPoscod],"B1_UGERTAG")

		IF cTemTAg == "S".and. empty(aCols[n][cGarant])
			msginfo("Favor informar o STATUS do material N-Novo, G-Garantia ou R-Reparado",aCols[n][nPoscod])
			lExecuta := .F.
		endif

		IF CSERIE != "INT"
			if cTemTAg =="S" .and. empty(aCols[n][cDiasga]) .and. aCols[n][cGarant] == "N"
				msginfo("Produto novo que controla TAG deve ser informado dias de Garantia!","D1_UDIASGA")
				lExecuta := .F.
			EndIf
		ENDIF

		IF aCols[n][cGarant] $ "R/G"
			IF EMPTY(aCols[n][cIDGar])
				ALERT("Favor Informar ID de Garantia")
				lExecuta := .F.
			ELSE
				DBSELECTAREA("Z22")
				DBSETORDER(1)
				IF DBSEEK(xFilial("Z22")+aCols[n][cIDGar])
					lExecuta := .T.
				ELSE
					lExecuta := .F.
				ENDIF
			ENDIF
		ENDIF

	ENDIF
		
	IF cSerie=="INT"
	aCols[n][nPosTes]:= "011"
	ENDIF	

	If (AllTrim(cEspecie) == 'NFS ' .OR. AllTrim(cEspecie) == 'NFSE'.OR. AllTrim(cEspecie) == 'RPS ') .AND. (ALLTRIM(funname()) == "MATA103" .OR. ALLTRIM(funname()) == "MATA100")
		//IF nPosiss > 0 .AND. nPosciss > 0 

			nValiss	  :=aCols[n][nPosiss]
			cCodiss	  :=aCols[n][nPosciss]

			if nValiss > 0 .and. alltrim(cCodiss) == ""
				msginfo("Favor Digitar o codigo de Servico!","Codigo de Servico")
				lExecuta := .F.
				DEFINE MSDIALOG oDlg TITLE "Definir Codigo de Servico" FROM 000, 000  TO 200, 300 COLORS 0, 16777215 PIXEL

				@ 037, 053 MSGET oGet1 VAR cCodiss SIZE 060, 010 OF oDlg F3 "60" PICTURE "@!" VALID ExistCpo("SX5","60"+cCodiss) COLORS 0, 16777215 PIXEL
				@ 023, 053 SAY oSay1 PROMPT "Codigo de Servico    " SIZE 064, 007 OF oDlg COLORS 0, 16777215 PIXEL// OF F3 "60" //PIXEL VALID(GetDescProd())
				//@ 005, 130 MSGET oGet3 VAR cEspecie SIZE 30, 10 OF oDlg F3 "42" PICTURE "@!" VALID ExistCpo("SX5","42"+cEspecie) COLORS 0, 16777215 FONT oFont16 HASBUTTON WHEN nOpc==3 

			// @ 082, 092 BUTTON oButton1 PROMPT "Confirmar" SIZE 053, 012 OF oDlg  ACTION (_CDISGRV(),oDlg:End()) PIXEL
				@ 082, 092 BUTTON oButton1 PROMPT "Confirmar" SIZE 053, 012 OF oDlg  ACTION oDlg:end() PIXEL
				@ 081, 007 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION oDlg:end() PIXEL

			ACTIVATE MSDIALOG oDlg CENTERED

			aCols[n][nPosciss]:=cCodiss
			ENDIF

		//ENDIF
	ENDIF
ENDIF
Return (lExecuta)                                                                                                      


/*
STATIC FUNCTION _CDISGRV()
	aCols[n][nPosciss]:=cCodiss
	
	//if RecLock("SE2", .F.)
	//	SE2->E2_VENCREA := cGet1
	//MsUnLock("SE2")
    //ENDIF
RETURN()
