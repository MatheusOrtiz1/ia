#include "protheus.ch"
#include "rwmake.ch"
#include "topConn.ch"
#include "fwMBrowse.ch"
#include "fwMVCDef.ch"
#INCLUDE "TBICONN.CH"
#DEFINE TIT_AVISO  "## Requisição Contrato ##"
Static Super_nOpc
Static oModal, oDlgBrw, oCampos
Static cContrato, cRevisao, cTipo
/*
Autor: Daniel Gouvea
Data : 28/12/22
PROTOCOL - Inclusão de protocolo de recebimento 
           importando pedido de compras e gerando pré-nota de entrada
ALTERAR O PARAMETRO MV_2DUPNAT PRA
 IIF(EXISTBLOCK("NATSF1"),U_NATSF1(),SA2->A2_NATUREZ)
*/
USER FUNCTION PROTOCOL()

	Private cCadastro := "PROTOCOLO DE RECEBIMENTO"
	Private aRotina
	Private aCores := {}
	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	//Private lRemessa := .F.
	Private cString := "ZAG"
	Private ASizeFld   := {  TAMSX3("CN9_NUMERO")[1]  ,;  // 01-Contrato
	TAMSX3("CN9_REVISA")[1]  ,;  // 02-Revisão
	TAMSX3("CNP_CODIGO")[1]  ,;  // 03-Tipo
	20                       ,;  // 04-Valor
	20                        }  // 05-Saldo Restante

	cContrato  := Space( ASizeFld[1] )
	cRevisao   := Space( ASizeFld[2] )
	cTipo      := Space( ASizeFld[3] )

	aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;
		{ "Visualizar"   ,"U_VIXSZAG" , 0, 2},;
		{ "Visualizar 2"   ,"AxVisual" , 0, 2},;
		{ "Incluir"      ,"u_INCZAG" , 0, 3},;
		{ "Copiar"      ,"u_COPZAG" , 0, 3},;
		{ "Alterar"      ,"u_ALTZAG" , 0, 3},;
		{ "Excluir"      ,"u_excZAG" , 0, 3},;
		{ "Reprocessar"      ,"u_REPROZAG" , 0, 3},;
		{ "Legenda"      ,"u_LEGENZAG" , 0, 3}}

	dbSelectArea("ZAH")
	dbSelectArea("ZAG")
	dbSetOrder(1)

	AADD(aCores,{'ZAG_STATUS == "F"', 'BR_AZUL' 	 })
	AADD(aCores,{'ZAG_STATUS == "E"', 'BR_PRETO' 	 })
	AADD(aCores,{'ZAG_STATUS == " "', "BR_VERDE"  	 })
	AADD(aCores,{'ZAG_STATUS == "R"', "BR_VERMELHO" 	 })


	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString, , , , , ,aCores)

Return

User Function LEGENZAG()    // função para leenda colorida
//************************* 
	aLegenda := 	{ 	{"BR_AZUL"    , "Protocolo incluido"  },;
		{"BR_VERDE" 		, "Protocolo em processamento" },;
		{"BR_PRETO" 		, "Erro ao incluir pre-nota" },;
		{"BR_VERMELHO"   	, "Protocolo Rejeitado"  }}
	BrwLegenda("Status dos protocolos de recebimento!!!","Legenda",aLegenda)
return


user function excZAG()

	if exclui()

		dbselectarea("ZAH")
		dbsetorder(1)//ZAH_FILIAL+ZAH_DOC+ZAH_SERIE+ZAH_FORNEC+ZAH_LOJA+ZAH_PEDIDO+ZAH_ITEMPC
		if dbseek(xFilial()+ZAG->ZAG_DOC+ZAG->ZAG_SERIE+ZAG->ZAG_FORNEC+ZAG->ZAG_LOJA)
			while !eof() .and. xFilial()+ZAG->ZAG_DOC+ZAG->ZAG_SERIE+ZAG->ZAG_FORNEC+ZAG->ZAG_LOJA==ZAH->ZAH_FILIAL+ZAH->ZAH_DOC+ZAH->ZAH_SERIE+ZAH->ZAH_FORNEC+ZAH->ZAH_LOJA
				if reclock("ZAH",.F.)
					dbdelete()
					ZAH->(msunlock())
				endif
				dbselectarea("ZAH")
				dbskip()
			enddo
			dbselectarea("ZAG")
			if reclock("ZAG",.F.)
				dbdelete()
				ZAG->(msunlock())
			endif

			msginfo("Excluido com sucesso.","")
		endif

	endif

return

static function Exclui()
	local lRet := .F.
	Local _area := getarea()
	Local aItem1 := {}
	Local aCab1  := {}

	Private LMsHelpAuto := .t.
	Private LMsErroAuto := .f.


	dbselectarea("SF1")
	dbsetorder(1)//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	if dbseek(xFilial()+ZAG->ZAG_DOC+ZAG->ZAG_SERIE+ZAG->ZAG_FORNEC+ZAG->ZAG_LOJA)
		IF SF1->F1_STATUS=="A"
			ALERT("NF já foi classificada. Por favor solicitar ao setor fiscal excluir")
		else

			aCab1 := {	{"F1_FILIAL"    ,SF1->F1_FILIAL          ,NIL},;
				{"F1_DOC"		,SF1->F1_DOC	  ,NIL},;
				{"F1_SERIE"	    ,SF1->F1_SERIE    ,NIL},;
				{"F1_FORNECE"	,SF1->F1_FORNECE  ,NIL},;
				{"F1_LOJA"	    ,SF1->F1_LOJA     ,NIL},;
				{"F1_COND"   	,SF1->F1_COND	  ,NIL},;
				{"F1_EMISSAO"   ,SF1->F1_EMISSAO  ,NIL},;
				{"F1_TIPO"  	,SF1->F1_TIPO     ,NIL} }

			dbselectarea("SD1")
			dbsetorder(1)//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			if dbseek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
				while !eof() .and. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA==xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
					aadd(aItem1,{	{"D1_FILIAL" , SD1->D1_FILIAL   			  ,NIL},;
						{"D1_ITEM"	 , SD1->D1_ITEM			  ,NIL},;
						{"D1_COD"	 , SD1->D1_COD			  ,NIL},;
						{"D1_QUANT"  , SD1->D1_QUANT		  ,NIL},;
						{"D1_VUNIT"	 , SD1->D1_VUNIT 		  ,NIL},;
						{"D1_TOTAL"	 , SD1->D1_TOTAL	      ,NIL},;
						{"D1_LOCAL"  , SD1->D1_LOCAL    	  ,NIL}})
					dbselectarea("SD1")
					dbskip()
				enddo
			endif
			if len(aCab1)>0 .and. len(aItem1)
				MSExecAuto({|x,y,z| MATA140(x,y,z)},aCab1,aItem1,5)  //PRE-NOTA
				if LMsErroAuto
					alert("Não foi possível excluir a pre-nota")
					mostraerro()
				else
					//AQUI VAI EXCLUIR OS ARQUIVOS VINCULADOS
					cQuery := " SELECT AC9_CODOBJ,R_E_C_N_O_ AS REGIST,D_E_L_E_T_ AS DELETA FROM "+RetSqlName("AC9")+" AC9 "
					cQuery += " WHERE AC9_FILIAL='"+xFilial("AC9")+"' "
					cQuery += " AND AC9_FILENT='"+cFilAnt+"' "
					cQuery += " AND AC9_CODENT='"+ZAG->ZAG_DOC+ZAG->ZAG_SERIE+ZAG->ZAG_FORNEC+ZAG->ZAG_LOJA+"'"
					cQuery += " AND AC9_ENTIDA='SF1' "
					TCQUERY cQuery NEW ALIAS "TMP1"
					DBSELECTAREA("TMP1")
					IF !EOF()
						WHILE !EOF()
							_obj := alltrim(TMP1->AC9_CODOBJ)
							IF !EMPTY(_obj)
								dbselectarea("ACB")
								dbsetorder(1)//ACB_FILIAL+ACB_CODOBJ
								if dbseek(xFIlial()+_obj)
									ferase("\dirdoc\co"+cempant+"\shared\"+alltrim(ACB->ACB_OBJETO))
									if reclock("ACB",.F.)
										dbdelete()
										msunlock()
									endif
								endif
								IF EMPTY(TMP1->DELETA)
									dbselectarea("AC9")
									dbgoto(TMP1->REGIST)
									if reclock("AC9",.F.)
										dbdelete()
										msunlock()
									endif
								ENDIF
							ENDIF
							DBSELECTAREA("TMP1")
							DBSKIP()
						ENDDO
					ENDIF
					TMP1->(dbclosearea())
					lRet := .T.
				endif
			endif

		endif

	else
		if ZAG->ZAG_STATUS=="E"
			LRET := .T.
		ELSE
			alert("Não foi encontrada pre-nota")
			lRet := .T.
		ENDIF
	endif

	restarea(_area)
return lRet

User Function INCZAG

	if ddatabase >= DATE()//PARA NAO INCLUIR PROTOCOLO COM DATA RETROATIVA

		MNTZAG(3,.f.)

	ENDIF


return

User Function COPZAG

	if ddatabase >= DATE()//PARA NAO INCLUIR PROTOCOLO COM DATA RETROATIVA

		MNTZAG(3,.t.)

	ENDIF


return

User Function VISZAG
	Local _area := getarea()
	Local _aZAG := ZAG->(getarea())
	dbselectarea("ZAG")
	dbsetorder(2)//ZAG_FILIAL+ZAG_DOC+ZAG_SERIE+ZAG_FORNEC+ZAG_LOJA
	if dbseek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		MNTZAG(2,.f.)
	ENDIF
	restarea(_aZAG)
	restarea(_area)
return

User Function ALTZAG

	if exclui()
		MNTZAG(4,.f.)

	else
		alert("Não foi possível excluir a Pre-Nota. Não sera possivel alterar. Solicite ao setor fiscal a exclusao da classificação e volte pra alterar.")
	endif

return

static function MNTZAG(nOpc,lCopia)

	Local nX
	Private lRemessa	:= .F.
	Private lPriori     := .F.
	Private aFieldFill := {}
	Private oFolder
	Private oFolder1
	Private oFolder2
	Private oFolder3
	Private oFont16 := TFont():New("Arial",,016,,.F.,,,,,.F.,.F.)
	Private oFont18 := TFont():New("Arial",,018,,.F.,,,,,.F.,.F.)
	Private oFont20 := TFont():New("Arial",,020,,.F.,,,,,.F.,.F.)
	Private oFont22 := TFont():New("Arial",,022,,.F.,,,,,.F.,.F.)
	Private oFont24 := TFont():New("Arial",,024,,.F.,,,,,.F.,.F.)
	Private oFont26 := TFont():New("Arial",,026,,.F.,,,,,.F.,.F.)
	Private oFont28 := TFont():New("Arial",,028,,.F.,,,,,.F.,.F.)
	Private cDoc := space(9)
	Private cSerie := space(3)
	Private cFornece := space(9)
	Private cLoja := space(3)
	Private cEspecie := space(5)
	Private dEmissa  := ddatabase
	Private cNature  := space(10)
	Private cCond    := space(3)
	Private cObs     := space(100)
	Private cForma := ""
	Private aDados := {}
	Private oTotal
	Private aItens := {}
	Private cMemo := ""
	Private nTotal := 0
	Private nFrete := 0
	Private cEstoque := "N"
	Private aEstoque := {"S","N"}
	Private aHeaderEx := {}
	Private aColsEx := {}
	Private aFields := {"ZAH_TEMEST","ZAH_PEDIDO","ZAH_ITEMPC","ZAH_COD","B1_DESC","ZAH_QUANT","ZAH_VUNIT","ZAH_TOTAL","ZAH_VALDES","ZAH_LOCAL","ZAH_OBS","ZAH_CC","ZAH_CO","ZAH_CLVL","ZAH_ITEMCT","ZAH_FRETE","ZAH_CONTRA","ZAH_REVISAO","ZAH_TIPO"}
	Private aAlterFields := {"ZAH_TEMEST","ZAH_QUANT","ZAH_VUNIT","ZAH_TOTAL","ZAH_VALDES","ZAH_CONTRA","ZAH_REVISAO","ZAH_TIPO"}
	Private aFretePed := {}
	Private lFatDire := .F.

	if nOpc==3 .and. lCopia
		cFornece := ZAG->ZAG_FORNEC
		cLoja    := ZAG->ZAG_LOJA 
		cEspecie := ZAG->ZAG_ESPECI
		cNature  := ZAG->ZAG_NATURE
		cEstoque := ZAG->ZAG_TEMEST
	endif 

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			_titulo := AllTrim(X3Titulo())

			IF SX3->X3_CAMPO == "ZAH_QUANT " .OR. SX3->X3_CAMPO ==  "ZAH_VUNIT " .OR. SX3->X3_CAMPO ==  "ZAH_TOTAL "
				Aadd(aHeaderEx, {_titulo,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"U_xCalTot()",;
					SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			ELSE
				Aadd(aHeaderEx, {_titulo,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
					SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			ENDIF
		Endif

	Next nX

	IF nOpc==4  .or. nOpc==2 //alteração ou visualizacao
		DBSELECTAREA("ZAH")
		dbsetorder(1)//ZAH_FILIAL+ZAH_DOC+ZAH_SERIE+ZAH_FORNEC+ZAH_LOJA+ZAH_PEDIDO+ZAH_ITEMPC
		if dbseek(xFilial()+ZAG->ZAG_DOC+ZAG->ZAG_SERIE+ZAG->ZAG_FORNEC+ZAG->ZAG_LOJA)
			nTotal := 0
			nFrete := 0
			while !eof() .and. xFilial()+ZAG->ZAG_DOC+ZAG->ZAG_SERIE+ZAG->ZAG_FORNEC+ZAG->ZAG_LOJA==ZAH->ZAH_FILIAL+ZAH->ZAH_DOC+ZAH->ZAH_SERIE+ZAH->ZAH_FORNEC+ZAH->ZAH_LOJA
				aTmp := {}
				if nOpc==2 .and. EMPTY(ZAH->ZAH_PEDIDO)
					lRemessa := .T.
				endif
				if nOpc==2 .and. EMPTY(ZAH->ZAH_CONTRA)
					lFatDire := .F.
				endif
				aadd(aTmp,ZAH->ZAH_TEMEST)
				aadd(aTmp,ZAH->ZAH_PEDIDO)
				aadd(aTmp,ZAH->ZAH_ITEMPC)
				aadd(aTmp,ZAH->ZAH_COD)
				if !lRemessa
					aadd(aTmp,POSICIONE("SC7",1,XFILIAL("SC7")+ZAH->ZAH_PEDIDO+ZAH->ZAH_ITEMPC,"C7_DESCRI")) //5
				else
					aadd(aTmp,POSICIONE("SB1",1,XFILIAL("SB1")+ZAH->ZAH_COD,"B1_DESC")) //5
				ENDIF
				aadd(aTmp,ZAH->ZAH_QUANT)
				aadd(aTmp,ZAH->ZAH_VUNIT)
				aadd(aTmp,ZAH->ZAH_TOTAL)
				aadd(aTmp,ZAH->ZAH_VALDES)
				aadd(aTmp,ZAH->ZAH_LOCAL)//10
				aadd(aTmp,ZAH->ZAH_OBS)
				aadd(aTmp,ZAH->ZAH_CC)
				aadd(aTmp,ZAH->ZAH_CO)
				aadd(aTmp,ZAH->ZAH_CLVL)
				aadd(aTmp,ZAH->ZAH_ITEMCT) //15
				aadd(aTmp,ZAH->ZAH_FRETE)
				aadd(aTmp,cContrato)
				aadd(aTmp,cRevisao)
				aadd(aTmp,cTipo)
				aadd(aTmp,.F.)
				aadd(aDados,aClone(aTmp))
				nTotal += ZAH->ZAH_TOTAL-ZAH->ZAH_VALDES
				nPosFre := aScan(aFretePed,{|x| x==ZAH->ZAH_PEDIDO})
				IF nPosFre==0
					aadd(aFretePed,ZAH->ZAH_PEDIDO)
					nFrete += ZAH->ZAH_FRETE
				endif
				dbselectarea("ZAH")
				dbskip()
			enddo
		endif
		cDoc 		:= ZAG->ZAG_DOC
		cSerie 		:= ZAG->ZAG_SERIE
		cEspecie 	:= ZAG->ZAG_ESPECI
		dEmissa 	:= date()//ZAG->ZAG_EMISSA
		cCond 		:= ZAG->ZAG_COND
		cEstoque 	:= ZAG->ZAG_TEMEST
		cNature 	:= ALLTRIM(ZAG->ZAG_NATURE)
		cFornece 	:= ZAG->ZAG_FORNEC
		cLoja 		:= ZAG->ZAG_LOJA
		cObs  		:= ZAG->ZAG_OBS
		lPriori     := IIF(ZAG->ZAG_PRIORI=="1",.T.,.F.)
	else
		aDados := {{space(1),space(6),space(3),space(15),space(30),0,0,0,0,space(2),space(100),space(20),space(10),space(9),space(9),space(9),0,space(15),space(3),space(4),.F.}}
	endif



	DEFINE MSDIALOG oDlg TITLE "Protocolo de Recebimento" FROM 005, 005  TO 500, 1000 COLORS 0, 16777215 PIXEL
	@ 005, 003 SAY oSay1 PROMPT "Doc:" SIZE 050, 018 OF oDlg FONT oFont16 COLORS 0, 16777215 PIXEL
	@ 005, 018 MSGET oGet1 VAR cDoc SIZE 30, 010 OF oDlg PICTURE "@!" VALID U_VLDDOCP() COLORS 0, 16777215 FONT  oFont16 HASBUTTON WHEN nOpc==3 PIXEL

	@ 005, 060 SAY oSay2 PROMPT "Serie:" SIZE 063, 018 OF oDlg FONT oFont16 COLORS 0, 16777215 PIXEL
	@ 005, 078 MSGET oGet2 VAR cSerie SIZE 20, 010 OF oDlg PICTURE "@!" COLORS 0, 16777215 FONT oFont16 HASBUTTON WHEN nOpc==3 PIXEL

	@ 005, 105 SAY oSay3 PROMPT "Especie:" SIZE 063, 018 OF oDlg FONT oFont16 COLORS 0, 16777215 PIXEL
	@ 005, 130 MSGET oGet3 VAR cEspecie SIZE 30, 10 OF oDlg F3 "42" PICTURE "@!" VALID ExistCpo("SX5","42"+cEspecie) COLORS 0, 16777215 FONT oFont16 HASBUTTON WHEN nOpc==3 PIXEL

	@ 005, 173 SAY oSay4 PROMPT "Emissão:" SIZE 063, 018 OF oDlg FONT oFont16 COLORS 0, 16777215 PIXEL
	@ 005, 200 MSGET oGet4 VAR dEmissa SIZE 50, 10 OF oDlg COLORS 0, 16777215 FONT oFont16 HASBUTTON WHEN nOpc==3 PIXEL

	@ 005, 260 SAY oSay4 PROMPT "Obs Compl:" SIZE 063, 018 OF oDlg FONT oFont16 COLORS 0, 16777215 PIXEL
	@ 005, 300 MSGET oGet4 VAR cObs SIZE 100,10 OF oDlg PICTURE "@!" COLORS 0, 16777215 FONT oFont16 HASBUTTON WHEN nOpc<>2 PIXEL

	@ 030,320 SAY oSay4 PROMPT "Estoque?" SIZE 063, 018 OF oDlg FONT oFont16 COLORS 0, 16777215 PIXEL
	@ 030, 350 COMBOBOX oEstoque VAR cEstoque ITEMS aEstoque SIZE 25, 010 OF oDlg COLORS 0, 16777215 WHEN nOpc<>2  PIXEL

	@ 030, 003 SAY oSay4 PROMPT "Natureza:" SIZE 063, 018 OF oDlg FONT oFont16 COLORS 0, 16777215 PIXEL
	@ 030, 030 MSGET oGet4 VAR cNature SIZE 50,10 OF oDlg PICTURE "@!" F3 "SED" VALID ExistCpo("SED") COLORS 0, 16777215 FONT oFont16 HASBUTTON WHEN nOpc==3 PIXEL

	@ 030, 090 SAY oSay4 PROMPT "Fornecedor:" SIZE 063, 018 OF oDlg FONT oFont16 COLORS 0, 16777215 PIXEL
	@ 030, 125 MSGET oGet4 VAR cFornece SIZE 20, 10 OF oDlg PICTURE "@!" F3 "SA2" COLORS 0, 16777215 FONT oFont16 HASBUTTON WHEN nOpc==3 PIXEL

	@ 030, 180 SAY oSay4 PROMPT "Loja:" SIZE 063, 018 OF oDlg FONT oFont16 COLORS 0, 16777215 PIXEL
	@ 030, 200 MSGET oGet4 VAR cLoja SIZE 20, 10 OF oDlg PICTURE "@!" COLORS 0, 16777215 FONT oFont16 HASBUTTON WHEN nOpc==3 PIXEL

	@ 030,240 BUTTON OBTFEC PROMPT "Item Pedido" SIZE 040, 010 OF ODLG PIXEL ACTION itempedido()
	@ 030,290 BUTTON OBTFEC PROMPT "Pedido" SIZE 023, 010 OF ODLG PIXEL ACTION pedido()

	@ 005,410 CHECKBOX oFaturaD VAR lFatDire PROMPT "Faturamento Direto" SIZE 150,10 on CLICK FatDireto(lFatDire) OF oDlg PIXEL WHEN nOpc<>2

	@ 030,380 CHECKBOX oRemessa VAR lRemessa PROMPT "Remessa futura?" SIZE 150,10 OF oDlg PIXEL WHEN nOpc<>2

	@ 030,440 CHECKBOX oPriori VAR lPriori PROMPT "Priorizado?" SIZE 150,10 OF oDlg PIXEL WHEN nOpc<>2

	oMsGetd := MsNewGetDados():New( 050, 10, 150, 500, GD_INSERT+GD_DELETE+GD_UPDATE, "U_LINOKZAH()", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 30, "AllwaysTrue", "", "U_LINOKZAH()", oDlg, aHeaderEx, aDados)

	@ 210, 018 BUTTON oButton3 PROMPT "Selecione Arquivo" ACTION selArqui() SIZE 055, 012 OF oDlg PIXEL
	@ 230, 018 BUTTON oButton4 PROMPT "Excluir Arquivo" ACTION excArqui() SIZE 055, 012 OF oDlg PIXEL
	@ 210,100 GET oMemo VAR cMemo MEMO SIZE 100,030 OF oDlg WHEN .F. PIXEL

	@ 210, 210 SAY oSay4 PROMPT "Total:" SIZE 063, 018 OF oDlg FONT oFont16 COLORS 0, 16777215 PIXEL
	@ 210, 230 MSGET oTotal VAR nTotal SIZE 60, 10 OF oDlg COLORS 0, 16777215 PICTURE "@E 9,999,999.99" FONT oFont16 HASBUTTON WHEN .f. PIXEL
	@ 230, 210 SAY oSay4 PROMPT "Frete:" SIZE 063, 018 OF oDlg FONT oFont16 COLORS 0, 16777215 PIXEL
	@ 230, 230 MSGET oFrete VAR nFrete SIZE 60, 10 OF oDlg COLORS 0, 16777215 PICTURE "@E 9,999,999.99" FONT oFont16 HASBUTTON WHEN .f. PIXEL
	if nOpc<>2
		@ 210,300 BUTTON OBTFEC PROMPT "Gravar" SIZE 30, 012 OF ODLG PIXEL ACTION processa({ || botGrava()})
	endif
	@ 210,370 BUTTON OBTFEC PROMPT "Fechar" SIZE 030, 012 OF ODLG PIXEL ACTION fecha(nOpc)

	ACTIVATE MSDIALOG oDlg CENTERED

return

static function excArqui
	Local aAux := {}
	Local i
	Local lRet := .T.
	Local OLBXA
	Local ONO 	   		:= LOADBITMAP( GETRESOURCES(), "LBNO"  )
	Local OOK 	   		:= LOADBITMAP( GETRESOURCES(), "LBTIK" )

	if len(aItens)==0
		alert("Não existem itens")
	else
		for i:=1 to len(aItens)
			aadd(aAux,{.F.,aItens[i]})
		next
		DEFINE MSDIALOG ODLGX TITLE OEMTOANSI("Excluir Itens") FROM 0,0 TO 22,100 OF OMAINWND
		@ 2.5,0 LISTBOX OLBXA VAR CITBX FIELDS HEADER " ","Arquivo" SIZE 200,400 of ODLGX ON DBLCLICK (aAux[OLBXA:NAT,1]:=!aAux[OLBXA:NAT,1],OLBXA:REFRESH())
		OLBXA:SETARRAY(aAux)
		OLBXA:BLINE := { || {iif(aAux[OLBXA:NAT,1],OOK,ONO),aAux[OLBXA:NAT,2]}}
		@ 10, 010 BUTTON oButton4 PROMPT "Fechar" ACTION ODLGX:END() SIZE 055, 012 OF ODLGX PIXEL
		ACTIVATE MSDIALOG ODLGX CENTER
		aItens := {}
		cMemo := ""
		for i:=1 to len(aAux)
			if !aAux[i,1]
				aadd(aItens,aAux[i,2])
				cMemo += alltrim(aAux[i,2])+chr(13)+chr(10)
			endif
		next
		oMemo:refresh()
	endif


return lRet

user function LINOKZAH()
	Local _area := getarea()
	Local lRet := .T.
	Local i,f
	Local nTmpTOT := 0
	Local _cXnum	:= oMsGetd:aCols[n,2]
	Local _cXitem	:= oMsGetd:aCols[n,3]

	nTotal := 0
	IF len(oMsGetd:aCols) > 0  .AND. len(aHeaderEx) > 0
		for i:=1 to len(oMsGetd:aCols)
			if !(oMsGetd:aCols[i,len(aHeaderEx)+1])
				nTotal += oMsGetd:aCols[i,8] - oMsGetd:aCols[i,9]
				nPosFre := aScan(aFretePed,{|x| x==oMsGetd:aCols[i,2]})
				IF nPosFre==0
					aadd(aFretePed,oMsGetd:aCols[i,2])
					nFrete += oMsGetd:aCols[i,16]
				endif
				oTotal:Refresh()
				oFrete:Refresh()
			endif
		next i
	ENDIF
	//----------------------------------------------------------------------------------------------------------
	//ADICIONADO EVERTON FORTI
	//----------------------------------------------------------------------------------------------------------
	for f:=1 to len(oMsGetd:aCols)
		nTmpTOT:= ((oMsGetd:aCols[f,6] * oMsGetd:aCols[f,7]) - oMsGetd:aCols[f,9])-oMsGetd:aCols[f,16]
	next f

	IF nTmpTOT != nTmpTOT
		msginfo("Valor Total incorreto!.","Verifique")
		lRet := .F.
	ENDIF

	//----------------------------------------------------------------------------------------------------------
	//VALIDA CAMPOS PARA NAO SER DIFERENTE DO PEDIDO DE COPRA aDados
	//----------------------------------------------------------------------------------------------------------
	cQuery := " SELECT C7_NUM,C7_ITEM,C7_PRODUTO, C7_DESCRI, C7_QUANT-C7_QUJE AS QUANT, C7_PRECO, C7_LOCAL, C7_OBS, C7_CC, C7_CO,C7_CLVL,C7_ITEMCTA,C7_VLDESC,C7_FRETE  "
	cQuery += " FROM "+RetSqlName("SC7")+" SC7 WHERE D_E_L_E_T_='' AND C7_FILIAL='"+xFilial("SC7")+"' AND (C7_QUANT-C7_QUJE)>0 AND C7_RESIDUO='' "
	cQuery += " AND C7_NUM='"+_cXnum+"' AND C7_ITEM='"+_cXitem+"' AND C7_CONAPRO<>'B' "
	IF SELECT("SC7TMP")!=0
		SC7TMP->(DBCLOSEAREA())
	ENDIF
	TCQUERY cQuery NEW ALIAS "SC7TMP"
	dbselectarea("SC7TMP")
	if !eof()
		IF !(SC7TMP->QUANT 	 >= oMsGetd:aCols[n,6])
			msginfo("Quantidade nao confere com o Pedido.","Verifique")
			lRet := .F.
		ENDIF

		IF !(SC7TMP->C7_PRECO >= oMsGetd:aCols[n,7])
			msginfo("Valor não confere com o Pedido.","Verifique")
			lRet := .F.
		ENDIF
	ENDIF


	restarea(_area)
return lRet

User Function xCalTot()
	Local lRet := .T.
	if LEN(aDados) > 0
		oMsGetd:aCols[n,8] := ((oMsGetd:aCols[n,6] * oMsGetd:aCols[n,7]))
		nTotal := oMsGetd:aCols[n,8] - oMsGetd:aCols[n,9]
		oTotal:Refresh()
	ENDIF

return(lRet)

	//------------------------------------------------------------------------------------------------------------

user function DBCLPRO()
	Local _area := getarea()
/*
if aDados[oLbxP:NAT,14]=="S"
	aDados[oLbxP:NAT,14] := "N"
else 
	aDados[oLbxP:NAT,14] := "S"
endif 
oLbxP:REFRESH()
*/
	restarea(_area)
return .t.

user function VLDDOCP()
	Local _area := getarea()

	cDoc := strzero(val(cDoc),9)

	restarea(_area)
return .t.

static function fecha(nOpc)
	Local _area := getarea()

	lFecha := .T.
	ODLG:END()
	IF nOpc==4
		dbselectarea("ZAH")
		dbsetorder(1)//ZAH_FILIAL+ZAH_DOC+ZAH_SERIE+ZAH_FORNEC+ZAH_LOJA+ZAH_PEDIDO+ZAH_ITEMPC
		if dbseek(xFilial()+ZAG->ZAG_DOC+ZAG->ZAG_SERIE+ZAG->ZAG_FORNEC+ZAG->ZAG_LOJA)
			while !eof() .and. xFilial()+ZAG->ZAG_DOC+ZAG->ZAG_SERIE+ZAG->ZAG_FORNEC+ZAG->ZAG_LOJA==ZAH->ZAH_FILIAL+ZAH->ZAH_DOC+ZAH->ZAH_SERIE+ZAH->ZAH_FORNEC+ZAH->ZAH_LOJA
				if reclock("ZAH",.F.)
					dbdelete()
					ZAH->(msunlock())
				endif
				dbselectarea("ZAH")
				dbskip()
			enddo
			dbselectarea("ZAG")
			if reclock("ZAG",.F.)
				dbdelete()
				ZAG->(msunlock())
			endif
			msginfo("Excluido com sucesso.","")
		endif
	endif
	restarea(_area)
return

static function botGrava()

	if grava()
		ODLG:END()
	endif

return

static function grava()
	local i
	if oMsGetd:aCols[1,6]==0
		alert("Não existem dados.")
		return .F.
	endif

	if len(aItens)==0
		alert("Favor adicionar pelo menos um anexo.")
		return .F.
	endif

	BEGIN TRANSACTION
		dbselectarea("ZAG")
		dbsetorder(2)//ZAG_FILIAL+ZAG_DOC+ZAG_SERIE+ZAG_FORNEC+ZAG_LOJA
		if dbseek(xFilial()+cDoc+cSerie+cFornece+cLoja)
			if reclock("ZAG",.F.)
				ZAG->ZAG_STATUS := " "
				ZAG->ZAG_COND   := cCond
				ZAG->ZAG_OBS    := cObs
				ZAG->ZAG_TEMEST := cEstoque
				ZAG->ZAG_PRIORI := iif(lPriori,"1","2")
				msunlock()
			endif
			for i:=1 to len(oMsGetd:aCols)
				if !oMsGetd:aCols[i,len(aHeaderEx)+1] .and. !empty(alltrim(oMsGetd:aCols[i,4]))
					dbselectarea("ZAH")
					dbsetorder(1)//ZAH_FILIAL+ZAH_DOC+ZAH_SERIE+ZAH_FORNEC+ZAH_LOJA+ZAH_PEDIDO+ZAH_ITEMPC
					if dbseek(xFilial()+cDoc+cSerie+cFornece+cLoja+oMsGetd:aCols[i,2]+oMsGetd:aCols[i,3])
						if reclock("ZAH",.F.)
							ZAH->ZAH_COD    := oMsGetd:aCols[i,4]
							if !lRemessa
								ZAH->ZAH_PEDIDO := oMsGetd:aCols[i,2]
								ZAH->ZAH_ITEMPC := oMsGetd:aCols[i,3]
							endif
							ZAH->ZAH_QUANT  := oMsGetd:aCols[i,6]
							ZAH->ZAH_VUNIT  := oMsGetd:aCols[i,7]
							ZAH->ZAH_TOTAL  := oMsGetd:aCols[i,8]
							ZAH->ZAH_CC     := oMsGetd:aCols[i,12]
							ZAH->ZAH_CO     := oMsGetd:aCols[i,13]
							ZAH->ZAH_OBS    := oMsGetd:aCols[i,11]
							ZAH->ZAH_LOCAL  := oMsGetd:aCols[i,10]
							ZAH->ZAH_CLVL   := oMsGetd:aCols[i,14]
							ZAH->ZAH_ITEMCT := oMsGetd:aCols[i,15]
							ZAH->ZAH_TEMEST := oMsGetd:aCols[i,1]
							ZAH->ZAH_VALDES := oMsGetd:aCols[i,9]
							ZAH->ZAH_FRETE := oMsGetd:aCols[i,16]
							if lFatDire///{"ZAH_CONTRA","ZAH_REVISAO","ZAH_TIPO"}
								ZAH->ZAH_CONTRA	 := oMsGetd:aCols[i,16]
								ZAH->ZAH_REVISAO := oMsGetd:aCols[i,17]
								ZAH->ZAH_TIPO	 := oMsGetd:aCols[i,18]
							endif
							msunlock()
						endif
					else
						if reclock("ZAH",.T.)
							ZAH->ZAH_FILIAL := xFilial()
							ZAH->ZAH_DOC    := cDoc
							ZAH->ZAH_SERIE  := cSerie
							ZAH->ZAH_FORNEC := cFornece
							ZAH->ZAH_LOJA   := cLoja
							ZAH->ZAH_COD    := oMsGetd:aCols[i,4]
							if !lRemessa
								ZAH->ZAH_PEDIDO := oMsGetd:aCols[i,2]
								ZAH->ZAH_ITEMPC := oMsGetd:aCols[i,3]
							endif
							ZAH->ZAH_QUANT  := oMsGetd:aCols[i,6]
							ZAH->ZAH_VUNIT  := oMsGetd:aCols[i,7]
							ZAH->ZAH_TOTAL  := oMsGetd:aCols[i,8]
							ZAH->ZAH_CC     := oMsGetd:aCols[i,12]
							ZAH->ZAH_CO     := oMsGetd:aCols[i,13]
							ZAH->ZAH_OBS    := oMsGetd:aCols[i,11]
							ZAH->ZAH_LOCAL  := oMsGetd:aCols[i,10]
							ZAH->ZAH_CLVL   := oMsGetd:aCols[i,14]
							ZAH->ZAH_ITEMCT := oMsGetd:aCols[i,15]
							ZAH->ZAH_TEMEST := oMsGetd:aCols[i,1]
							ZAH->ZAH_VALDES := oMsGetd:aCols[i,9]
							ZAH->ZAH_FRETE  := oMsGetd:aCols[i,16]
							if lFatDire///{"ZAH_CONTRA","ZAH_REVISAO","ZAH_TIPO"}
								ZAH->ZAH_CONTRA := oMsGetd:aCols[i,16]
								ZAH->ZAH_REVISAO := oMsGetd:aCols[i,17]
								ZAH->ZAH_TIPO	 := oMsGetd:aCols[i,18]
							endif
							ZAH->(msunlock())
						endif
					endif
				endif
			next
			u_PROCZAG()
			if ZAG->ZAG_STATUS=="F" //FINALIZADO CORRETAMENTE
				gravaArq(aItens)
			endif
		else
			if reclock("ZAG",.T.)
				ZAG->ZAG_FILIAL := xFilial()
				ZAG->ZAG_STATUS := space(1)
				ZAG->ZAG_DOC    := cDoc
				ZAG->ZAG_SERIE  := cSerie
				ZAG->ZAG_FORNEC := cFornece
				ZAG->ZAG_LOJA   := cLoja
				ZAG->ZAG_ESPECI := cEspecie
				ZAG->ZAG_USUARI := UsrFullName(__cUserId)
				ZAG->ZAG_CODUSR := __cUserID
				ZAG->ZAG_DATA   := date()
				ZAG->ZAG_HORA   := time()
				ZAG->ZAG_EMISSA := dEmissa
				ZAG->ZAG_NATURE := ALLTRIM(cNature)
				ZAG->ZAG_COND   := cCond
				ZAG->ZAG_OBS    := cObs
				ZAG->ZAG_TEMEST := cEstoque
				ZAG->ZAG_PRIORI := iif(lPriori,"1","2")
				ZAG->(msunlock())
				for i:=1 to len(oMsGetd:aCols)
					if !oMsGetd:aCols[i,len(aHeaderEx)+1]  .and. !empty(alltrim(oMsGetd:aCols[i,4]))
						dbselectarea("ZAH")
						if reclock("ZAH",.T.)
							ZAH->ZAH_FILIAL := xFilial()
							ZAH->ZAH_DOC    := cDoc
							ZAH->ZAH_SERIE  := cSerie
							ZAH->ZAH_FORNEC := cFornece
							ZAH->ZAH_LOJA   := cLoja
							ZAH->ZAH_COD    := oMsGetd:aCols[i,4]
							if !lRemessa
								ZAH->ZAH_PEDIDO := oMsGetd:aCols[i,2]
								ZAH->ZAH_ITEMPC := oMsGetd:aCols[i,3]
							endif
							ZAH->ZAH_QUANT  := oMsGetd:aCols[i,6]
							ZAH->ZAH_VUNIT  := oMsGetd:aCols[i,7]
							ZAH->ZAH_TOTAL  := oMsGetd:aCols[i,8]
							ZAH->ZAH_CC     := oMsGetd:aCols[i,12]
							ZAH->ZAH_CO     := oMsGetd:aCols[i,13]
							ZAH->ZAH_OBS    := oMsGetd:aCols[i,11]
							ZAH->ZAH_LOCAL  := oMsGetd:aCols[i,10]
							ZAH->ZAH_CLVL   := oMsGetd:aCols[i,14]
							ZAH->ZAH_ITEMCT := oMsGetd:aCols[i,15]
							ZAH->ZAH_TEMEST := oMsGetd:aCols[i,1]
							ZAH->ZAH_VALDES := oMsGetd:aCols[i,9]
							ZAH->ZAH_FRETE  := oMsGetd:aCols[i,16]
							if lFatDire///{"ZAH_CONTRA","ZAH_REVISAO","ZAH_TIPO"}
								ZAH->ZAH_CONTRA  := oMsGetd:aCols[i,16]
								ZAH->ZAH_REVISAO := oMsGetd:aCols[i,17]
								ZAH->ZAH_TIPO	 := oMsGetd:aCols[i,18]
							endif
							ZAH->(msunlock())
						endif
					endif
				next
				u_PROCZAG()
				if ZAG->ZAG_STATUS=="F" //FINALIZADO CORRETAMENTE
					gravaArq(aItens)
				endif
			endif
		endif
	END TRANSACTION
return .T.

user function REPROZAG

	if ZAG->ZAG_STATUS=="E"
		dbselectarea("ZAG")
		IF RECLOCK('ZAG',.f.)
			ZAG->ZAG_STATUS := " "
			ZAG->(MSUNLOCK())
			cObs := ZAG->ZAG_OBS
			U_PROCZAG()
		ENDIF
	ELSE
		ALERT("Somente status com erro.")
	ENDIF

RETURN
static function gravaArq(aIte)
	Local i
	for i:=1 to len(aIte)
		if !empty(alltrim(aItens[i]))
			_caminho := "\dirdoc\co"+cEmpAnt+"\shared\"
			_pos := rat("\",aItens[i])
			cpyt2s(aItens[i],_caminho)
			_nome := strtran(substr(aItens[i],_pos,200),"\","")
			_novoNome := lower(_nome)
			_novoNome := strtran(_novoNome," ","_")
			_novoNome := strtran(_novoNome,"-","_")
			_novoNome := noAcento(_novoNome)
			nStatus2 := frename(_caminho+_nome , _caminho+_novoNome )
			dbselectarea("ACB")
			_cod := GetSxeNum("ACB","ACB_CODOBJ")
			confirmsX8()
			reclock("ACB",.T.)
			ACB->ACB_FILIAL := xFilial()
			ACB->ACB_OBJETO := Upper(_novoNome)
			ACB->ACB_DESCRI := "NF "+SF1->F1_DOC+" "+_novoNome
			ACB->ACB_CODOBJ := _cod
			ACB->(msunlock())
			dbselectarea("AC9")
			RECLOCK("AC9",.T.)
			AC9->AC9_FILIAL := XFILIAL()
			AC9->AC9_ENTIDA := "SF1"
			AC9->AC9_FILENT := cFilAnt
			AC9->AC9_CODENT := SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
			AC9->AC9_CODOBJ := _cod
			AC9->(MSUNLOCK())
		endif
	next
return

static function selArqui()
	if len(aItens)>=3
		alert("Somente 3 anexos permitidos.")
	else
		cFile := cGetFile("Arquivos|*.*","Selecione Arquivo",0,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.) //Tela para selecionar//cGetFile("*.*","Dialogo de Selecao de Arquivos",,,,.F.)
		_AUX := RAT("\",CFILE)
		tamAux := substr(cFile,_aux+1,len(cFile)-_aux)
		IF LEN(tamAux)>200
			alert("Nome do arquivo muito extenso. Por favor usar no maximo 35 caracteres.")
		else
			aadd(aItens,cFile)
			cMemo += alltrim(cFile)+chr(13)+chr(10)
			oMemo:refresh()
		endif
	endif

return

static function itempedido()
	Local i
	ONO 	   		:= LOADBITMAP( GETRESOURCES(), "LBNO"  )
	OOK 	   		:= LOADBITMAP( GETRESOURCES(), "LBTIK" )
	aPed := {}
	cQuery := " SELECT C7_NUM,C7_ITEM,C7_PRODUTO, C7_DESCRI, C7_QUANT-C7_QUJE AS QUANT, C7_PRECO, C7_LOCAL, C7_OBS, C7_CC, C7_CO,C7_CLVL,C7_ITEMCTA,C7_VLDESC,C7_FRETE  "
	cQuery += " FROM "+RetSqlName("SC7")+" SC7 WHERE D_E_L_E_T_='' AND C7_FILIAL='"+xFilial("SC7")+"' AND (C7_QUANT-C7_QUJE)>0 AND C7_RESIDUO='' "
	cQuery += " AND C7_FORNECE='"+cFornece+"' AND C7_LOJA='"+cLoja+"' AND C7_CONAPRO<>'B' "

	IF SELECT("TEMP")!=0
		TEMP->(DBCLOSEAREA())
	ENDIF

	TCQUERY cQuery NEW ALIAS "TEMP"
	dbselectarea("TEMP")
	if !eof()
		while !eof()
			nPos := aScan(oMsGetd:aCols,{|x| x[2]==TEMP->C7_NUM .and. x[3]==TEMP->C7_ITEM})
			if nPos==0
				aAux := {}
				aadd(aAux,.F.)
				aadd(aAux,TEMP->C7_NUM)
				aadd(aAux,TEMP->C7_ITEM)
				aadd(aAux,TEMP->C7_PRODUTO)
				aadd(aAux,TEMP->C7_DESCRI)//5
				aadd(aAux,TEMP->QUANT)
				aadd(aAux,TEMP->C7_PRECO)
				aadd(aAux,TEMP->C7_PRECO*TEMP->QUANT-TEMP->C7_VLDESC)
				aadd(aAux,TEMP->C7_VLDESC)
				aadd(aAux,TEMP->C7_LOCAL) //10
				aadd(aAux,TEMP->C7_OBS)
				aadd(aAux,TEMP->C7_CC)
				aadd(aAux,TEMP->C7_CO)
				aadd(aAux,TEMP->C7_CLVL)
				aadd(aAux,TEMP->C7_ITEMCTA)//15
				aadd(aAux,TEMP->C7_FRETE)
				aadd(aAux,cContrato)
				aadd(aAux,cRevisao)
				aadd(aAux,cTipo)
				aadd(aPed,aAux)
			endif

			dbselectarea("TEMP")
			dbskip()
		enddo
	else
		alert("Não existem pedidos em aberto pra esse fornecedor.")
	endif
	TEMP->(dbclosearea())
	if len(aPed)>0
		nItemL := 1
		DEFINE MSDIALOG oDlgL TITLE "Pedidos:" FROM 000,000 TO 300,800 PIXEL
		@ 10,10 LISTBOX oLbx3 FIELDS HEADER " ","Pedido","Item","Produto","Descrição","Quant","Unit","Total","Desconto","Armazem","Obs","C Custo","Conta Orc","CLVL","Item Cta","Frete" SIZE 380,095 OF oDlgL PIXEL ON DBLCLICK (aPed[oLbx3:NAT,1]:=!aPed[oLbx3:NAT,1],oLbx3:REFRESH())
		oLbx3:SetArray(aPed)
		oLbx3:bLine := {|| {IF(aPed[oLbx3:NAT,1],OOK,ONO),aPed[oLbx3:nAt,2],aPed[oLbx3:nAt,3],aPed[oLbx3:nAt,4],aPed[oLbx3:nAt,5],transform(aPed[oLbx3:nAt,6],;
			pesqpict("SC7","C7_QUANT")),transform(aPed[oLbx3:nAt,7],pesqpict("SC7","C7_TOTAL")),transform(aPed[oLbx3:nAt,8],;
			pesqpict("SC7","C7_TOTAL")),transform(aPed[oLbx3:nAt,9],pesqpict("SC7","C7_TOTAL")),aPed[oLbx3:nAt,10],aPed[oLbx3:nAt,11],aPed[oLbx3:nAt,12],aPed[oLbx3:nAt,13],aPed[oLbx3:nAt,14],aPed[oLbx3:nAt,15],transform(aPed[oLbx3:nAt,16],pesqpict("SC7","C7_TOTAL"))}}
		@ 107,113 BUTTON oButton1 PROMPT "Cancela" SIZE 030, 020 OF oDlgL ACTION (nIteml := 0,oDlgL:End()) PIXEL
		@ 107,213 BUTTON oButton2 PROMPT "OK" SIZE 030, 020 OF oDlgL ACTION (nItemL := oLBx3:nAt,oDlgL:End()) PIXEL
		ACTIVATE MSDIALOG oDlgL
		for i:=1 to len(aPed)
			if aPed[i,1]
				aTmp := {}
				aadd(aTmp,cEstoque)
				aadd(aTmp,aPed[i,2])
				aadd(aTmp,aPed[i,3])
				aadd(aTmp,aPed[i,4])
				aadd(aTmp,aPed[i,5])
				aadd(aTmp,aPed[i,6])
				aadd(aTmp,aPed[i,7])
				aadd(aTmp,aPed[i,8])
				aadd(aTmp,aPed[i,9])
				aadd(aTmp,aPed[i,10])
				aadd(aTmp,aPed[i,11])
				aadd(aTmp,aPed[i,12])
				aadd(aTmp,aPed[i,13])
				aadd(aTmp,aPed[i,14])
				aadd(aTmp,aPed[i,15])
				aadd(aTmp,aPed[i,16])
				aadd(aTmp,cContrato)
				aadd(aTmp,cRevisao)
				aadd(aTmp,cTipo)
				aadd(aTmp,.F.)
				nTotal += aPed[i,8]
				nPosFre := aScan(aFretePed,{|x| x==aPed[i,2]})
				IF nPosFre==0
					aadd(aFretePed,aPed[i,2])
					nFrete += aPed[i,16]
				endif
				oTotal:Refresh()
				oFrete:Refresh()
				IF oMsGetd:aCols[1,6]==0
					oMsGetd:aCols := {}
				endif
				aadd(oMsGetd:aCols,aClone(aTmp))
				oMsGetd:refresh()
			ENDIF
		next i

		if niteml>0


		endif

	else
		alert("Não existem pedidos em aberto pra esse fornecedor.")
	endif

return

static function pedido()
	Local i
	aPed := {}
	aPedAux := {}
	cQuery := " SELECT C7_NUM,C7_ITEM,C7_PRODUTO, C7_DESCRI, C7_QUANT-C7_QUJE AS QUANT, C7_PRECO, C7_LOCAL, C7_OBS, C7_CC, C7_CO,C7_CLVL,C7_ITEMCTA,C7_VLDESC,C7_FRETE, C7_VALFRE  "
	cQuery += " FROM "+RetSqlName("SC7")+" SC7 WHERE D_E_L_E_T_='' AND C7_FILIAL='"+xFilial("SC7")+"' AND (C7_QUANT-C7_QUJE)>0 AND C7_RESIDUO='' "
	cQuery += " AND C7_FORNECE='"+cFornece+"' AND C7_LOJA='"+cLoja+"' AND C7_CONAPRO<>'B' "
	IF SELECT("TEMP")!=0
		TEMP->(DBCLOSEAREA())
	ENDIF

	TCQUERY cQuery NEW ALIAS "TEMP"
	dbselectarea("TEMP")
	if !eof()
		while !eof()
			nPos := aScan(oMsGetd:aCols,{|x| x[2]==TEMP->C7_NUM .and. x[3]==TEMP->C7_ITEM})
			if nPos==0
				aAux := {}
				aadd(aAux,TEMP->C7_NUM)
				aadd(aAux,TEMP->C7_ITEM)
				aadd(aAux,TEMP->C7_PRODUTO)
				aadd(aAux,TEMP->C7_DESCRI)
				aadd(aAux,TEMP->QUANT)//5
				aadd(aAux,TEMP->C7_PRECO)
				aadd(aAux,TEMP->C7_PRECO*TEMP->QUANT-TEMP->C7_VLDESC)
				aadd(aAux,TEMP->C7_VLDESC)
				aadd(aAux,TEMP->C7_LOCAL)
				aadd(aAux,TEMP->C7_OBS) //10
				aadd(aAux,TEMP->C7_CC)
				aadd(aAux,TEMP->C7_CO)
				aadd(aAux,TEMP->C7_CLVL)
				aadd(aAux,TEMP->C7_ITEMCTA)//15
				aadd(aAux,TEMP->C7_FRETE+TEMP->C7_VALFRE)
				aadd(aAux,cContrato)
				aadd(aAux,cRevisao)
				aadd(aAux,cTipo)
				aadd(aPed,aAux)
				nPos2 := aScan(aPedAux,{|x| x[1]==TEMP->C7_NUM})
				if nPos2==0
					aAux := {}
					aadd(aAux,TEMP->C7_NUM)
					aadd(aPedAux,aAux)
				endif
			endif

			dbselectarea("TEMP")
			dbskip()
		enddo
	else
		alert("Não existem pedidos em aberto pra esse fornecedor.")
	endif
	TEMP->(dbclosearea())
	if len(aPed)>0
		nItemL := 1
		DEFINE MSDIALOG oDlgL TITLE "Pedidos:" FROM 000,000 TO 300,800 PIXEL
		@ 10,10 LISTBOX oLbx3 FIELDS HEADER "Pedido" SIZE 380,095 OF oDlgL PIXEL
		oLbx3:SetArray(aPedAux)
		oLbx3:bLine := {|| {aPedAux[oLbx3:nAt,1]}}
		@ 107,113 BUTTON oButton1 PROMPT "Cancela" SIZE 030, 020 OF oDlgL ACTION (nIteml := 0,oDlgL:End()) PIXEL
		@ 107,213 BUTTON oButton2 PROMPT "OK" SIZE 030, 020 OF oDlgL ACTION (nItemL := oLBx3:nAt,oDlgL:End()) PIXEL
		ACTIVATE MSDIALOG oDlgL
		if niteml>0
			cPedido := aPedAux[nItemL,1]
			for i:=1 to len(aPed)
				if cPedido== aPed[i,1]
					nPos := aScan(oMsGetd:aCols,{|x| x[1]==cPedido .and. x[2]==aPed[i,3]})
					if nPos==0
						//aDados := {{space(1),space(6),space(3),space(15),space(30),0,0,0,0,space(2),space(100),space(20),space(10),space(9),space(9),space(9),0,space(15),space(3),space(4),.F.}}
						aTmp := {}
						aadd(aTmp,cEstoque)
						aadd(aTmp,aPed[i,1])
						aadd(aTmp,aPed[i,2])
						aadd(aTmp,aPed[i,3])
						aadd(aTmp,aPed[i,4])
						aadd(aTmp,aPed[i,5])
						aadd(aTmp,aPed[i,6])
						aadd(aTmp,aPed[i,7])
						aadd(aTmp,aPed[i,8])
						aadd(aTmp,aPed[i,9])
						aadd(aTmp,aPed[i,10])
						aadd(aTmp,aPed[i,11])
						aadd(aTmp,aPed[i,12])
						aadd(aTmp,aPed[i,13])
						aadd(aTmp,aPed[i,14])
						aadd(aTmp,aPed[i,15])
						aadd(aTmp,aPed[i,16])
						aadd(aTmp,aPed[i,17])
						aadd(aTmp,aPed[i,18])
						aadd(aAux,cContrato)
						aadd(aAux,cRevisao)
						aadd(aAux,cTipo)
						aadd(aTmp,.F.)
						nTotal += aPed[i,7]
						nPosFre := aScan(aFretePed,{|x| x==aPed[i,1]})
						IF aPed[i,15] > 0
							aadd(aFretePed,aPed[i,1])
							nFrete += aPed[i,15]
						ENDIF
						oTotal:Refresh()
						oFrete:Refresh()
						IF oMsGetd:aCols[1,6]==0
							oMsGetd:aCols := {}
						endif
						aadd(oMsGetd:aCols,aClone(aTmp))
						oMsGetd:refresh()
					endif
				endif
			next
		endif

	else
		alert("Não existem pedidos em aberto pra esse fornecedor.")
	endif

return


User Function PROCZAG
	Local i
	Local nVFrete		:= 0
	Private aCabec      := {}
	Private aItens      := {}
	Private aLinha      := {}
	Private lMsErroAuto := .F.
	Private LMSHELPAUTO := .T.

	dbselectarea("ZAG")
	dbsetorder(1)//ZAG_FILIAL+ZAG_STATUS+ZAG_DOC+ZAG_SERIE+ZAG_FORNEC+ZAG_LOJA
	if dbseek(xFilial()+space(1))
		if reclock("ZAG",.F.)
			ZAG->ZAG_STATUS := "P"
			ZAG->(msunlock())
		endif
		aAdd(aCabec,{'F1_TIPO','N',NIL})
		aAdd(aCabec,{'F1_FORMUL','N',NIL})
		aAdd(aCabec,{'F1_DOC',ZAG->ZAG_DOC   ,NIL})
		aAdd(aCabec,{"F1_SERIE",ZAG->ZAG_SERIE,NIL})
		aAdd(aCabec,{"F1_EMISSAO",ZAG->ZAG_EMISSA,NIL})
		aAdd(aCabec,{'F1_FORNECE',ZAG->ZAG_FORNEC,NIL})
		aAdd(aCabec,{'F1_LOJA',ZAG->ZAG_LOJA,NIL})
		aAdd(aCabec,{"F1_ESPECIE",ZAG->ZAG_ESPECI,NIL})
		aAdd(aCabec,{"F1_COND",ZAG->ZAG_COND,NIL})
//		aAdd(aCabec,{"F1_FRETE",ZAG->ZAG_NATURE,NIL})
		aAdd(aCabec,{"F1_STATUS",'',NIL})
		aAdd(aCabec,{"F1_UPRIORI",ZAG->ZAG_PRIORI,NIL})
		cItem := "0000"
		cObsAux := cObs
		dbselectarea("ZAH")
		dbsetorder(1)//ZAH_FILIAL+ZAH_DOC+ZAH_SERIE+ZAH_FORNEC+ZAH_LOJA+ZAH_PEDIDO+ZAH_ITEMPC
		if dbseek(xFilial()+ZAG->ZAG_DOC+ZAG->ZAG_SERIE+ZAG->ZAG_FORNEC+ZAG->ZAG_LOJA)
			while !eof() .and. xFilial()+ZAG->ZAG_DOC+ZAG->ZAG_SERIE+ZAG->ZAG_FORNEC+ZAG->ZAG_LOJA==ZAH->ZAH_FILIAL+ZAH->ZAH_DOC+ZAH->ZAH_SERIE+ZAH->ZAH_FORNEC+ZAH->ZAH_LOJA
				aItens := {}
				cItem := soma1(cItem)
				nVFrete += ZAH->ZAH_FRETE
				aAdd(aItens,{'D1_ITEM',cItem,NIL})
				aAdd(aItens,{'D1_COD',ZAH->ZAH_COD,NIL})
				aAdd(aItens,{"D1_QUANT",ZAH->ZAH_QUANT,Nil})
				aAdd(aItens,{"D1_VUNIT",ZAH->ZAH_VUNIT,Nil})
//				aAdd(aItens,{"D1_TOTAL",ZAH->ZAH_TOTAL+ZAH->ZAH_VALDES,Nil})
				aAdd(aItens,{"D1_UTEMEST",ZAH->ZAH_TEMEST,NIL})
				if !lRemessa
					aAdd(aItens,{"D1_PEDIDO",ZAH->ZAH_PEDIDO,Nil})
					aAdd(aItens,{"D1_ITEMPC",ZAH->ZAH_ITEMPC,Nil})
				endif
				/*
				if lFatDire///{"ZAH_CONTRA","ZAH_REVISAO","ZAH_TIPO"}
					aAdd(aItens,{"D1_PEDIDO",ZAH->ZAH_CONTRA,Nil})
					aAdd(aItens,{"D1_PEDIDO",ZAH->ZAH_REVISAO,Nil})
					aAdd(aItens,{"D1_PEDIDO",ZAH->ZAH_TIPO,Nil})
				endif
				*/
				aAdd(aItens,{"D1_VALDESC",ZAH->ZAH_VALDES,Nil})
				aAdd(aItens,{"D1_CC",ZAH->ZAH_CC,NIL})
				aAdd(aItens,{"D1_CO",ZAH->ZAH_CO,NIL})
				aAdd(aItens,{"D1_LOCAL",ZAH->ZAH_LOCAL,NIL})
				aAdd(aItens,{"D1_OBS",alltrim(ZAH->ZAH_OBS)+" "+cObsAux,NIL})
				IF !EMPTY(ZAH->ZAH_CLVL)
					aAdd(aItens,{"D1_CLVL",ZAH->ZAH_CLVL,NIL})
				ENDIF
				IF !EMPTY(ZAH->ZAH_ITEMCT)
					aAdd(aItens,{"D1_ITEMCTA",ZAH->ZAH_ITEMCT,NIL})
				ENDIF
				aAdd(aLinha,aclone(aItens))

				dbselectarea("ZAH")
				dbskip()
			enddo
		endif

		aAdd(aCabec,{"F1_FRETE",nVFrete,NIL}) //ADICIONA FRETE

		nOpc := 3
		if len(aCabec)>0 .and. len(aLinha)>0
			lMsErroAuto := .f.
			LMSERROAUTO := .F.
			MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabec, aLinha, nOpc,,)

			If lMsErroAuto
				CDIRLOG := "\TEMP\"
				If !ExistDir(CDIRLOG)
                    MakeDir(CDIRLOG)
                EndIf
				CARQLOG := "LOG_" + FWUUIDV1() + ".TXT"
				CERROAUTO := ""
				MOSTRAERRO(CDIRLOG, CARQLOG)
				CERROAUTO += MEMOREAD(CDIRLOG+CARQLOG)
				CERROAUTO += CHR(10)+CHR(13)
				FERASE(CDIRLOG+CARQLOG)
				dbselectarea("ZAG")
				if reclock("ZAG",.F.)
					ZAG->ZAG_STATUS := "E"
					ZAG->ZAG_LOGERR := CERROAUTO
					ZAG->ZAG_DATA   := DATE()
					ZAG->ZAG_HORA   := TIME()
					ZAG->(msunlock())
				endif
				FWAlertError(CERROAUTO, "CARQLOG")
				alert(CERROAUTO)
			Else
				//aqui ta acusando erro de lock
				DBSELECTAREA("ZAG")
				if reclock("ZAG",.F.)
					ZAG->ZAG_STATUS := "F"
					ZAG->(msunlock())
				endif
				//aqui vai preencher o D1_UTEMEST que nao ta preenchendo pelo msexecauto
				for i:=1 to len(aLinha)
					DBSELECTAREA("SD1")
					DBSETORDER(1)//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
					if dbseek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+ALINHA[I,2,2]+ALINHA[I,1,2])
						if reclock("SD1",.F.)
							SD1->D1_UTEMEST := ALINHA[I,5,2]
							msunlock()
						endif
					endif
				next
			EndIf
		else
			DBSELECTAREA("ZAG")
			if reclock("ZAG",.F.)
				ZAG->ZAG_STATUS := "E"
				ZAG->(msunlock())
			endif
		endif
	endif

return

//	PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM" TABLES "SF1","SD1","SA1","SA2","SB1","SB2","SF4"
	RESET ENVIRONMENT

	DBSELECTAREA("ZAG")
	DBSELECTAREA("ZAH")
RETURN

user function NATSF1()
	Local _area := getarea()
	Local _aZAG := ZAG->(getarea())
	Local cRet := SA2->A2_NATUREZ

	dbselectarea("ZAG")
	dbsetorder(2)//ZAG_FILIAL+ZAG_DOC+ZAG_SERIE+ZAG_FORNEC+ZAG_LOJA
	if dbseek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		cRet := ZAG->ZAG_NATURE
		//ALERT(cRet)
	endif

	restarea(_aZAG)
	restarea(_area)

return cRet

//--------------------------------------------------------------------------------------------//
//FatDireto - Faturamento Direto
//--------------------------------------------------------------------------------------------//
Static Function FatDireto(lFatDire)

	Local aButtons   := { {"", "Salvar", { || fValidDlg() }, , , .T., .F.} }

	IF lFatDire
		Super_nOpc := 0
		oCampos    := Array( 04 )

		oModal:= FWDialogModal():New()
		oModal:SetEscClose(.F.)
		oModal:setTitle( TIT_AVISO )
		//Seta a largura e altura da janela em pixel
		oModal:SetSize(120, 210)

		oModal:CreateDialog()
		oModal:addCloseButton(nil, "Fechar")
		oModal:addButtons(aButtons)

		//### Dialog
		oDlgBrw := TPanel():New( ,,, oModal:GetPanelMain() )
		oDlgBrw:Align := CONTROL_ALIGN_ALLCLIENT

		@ 13, 002 Say "Contrato"   Size 22, 08 Of oDlgBrw Pixel
		@ 20, 002 MSGet oCampos[01] Var cContrato     F3 "CN9" SIZE 68,10 PIXEL of oDlgBrw

		@ 13, 072 Say "Revisão"    Size 40, 08 Of oDlgBrw Pixel
		@ 20, 072 MSGet oCampos[02] Var cRevisao                  SIZE 20,10 PIXEL of oDlgBrw When .F.


		@ 13, 105 Say "Tipo"       Size 50, 08 Of oDlgBrw Pixel
		@ 20, 105 MSGet oCampos[03] Var cTipo         F3 "CNP"    SIZE 20,10 PIXEL of oDlgBrw

		oModal:Activate()

		oCampos := Nil

	ELSE
		cContrato  := Space( ASizeFld[1] )
		cRevisao   := Space( ASizeFld[2] )
		cTipo      := Space( ASizeFld[3] )

	ENDIF

/*         cContrato  := Padr( AReqCtrl[1], ASizeFld[1] )
         cRevisao   := Padr( AReqCtrl[2], ASizeFld[2] )
         cTipo      := Padr( AReqCtrl[3], ASizeFld[3] )
*/

Return( Nil )


//+------------------------------------------------------------------------------------------------------------------------------------------------------+
//|  
//+------------------------------------------------------------------------------------------------------------------------------------------------------+
Static Function fValidDlg()

	if Empty( cContrato )
		MsgAlert("Atenção necessário preeencher o Nro do Contrato", TIT_AVISO)
		Return( Nil )
	Endif

	if Empty( cTipo )
		MsgAlert("Atenção necessário preeencher o Tipo desconto ", TIT_AVISO)
		Return( Nil )
	Endif

	Super_nOpc  := 1
	oModal:DeActivate()

Return( Nil )


User Function VIXSZAG()

	MNTZAG(2)

return
